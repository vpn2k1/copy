import 'dart:math' as math;

import 'skill_config.dart';
import 'skill_puzzles.dart';
import 'skill_runtime.dart';

/// Hệ số hồi phục khi cô đang nhìn (giả vờ kém thuyết phục), hoặc khi diễn
/// "Oscar" mà cô không nhìn (diễn lố, phí công).
const weakRecoveryFactor = 0.4;

/// Nghi ngờ cộng thêm khi kỹ năng thất bại ngay lúc cô đang nhìn.
const failInSightRisk = 5.0;

/// Thời gian thao tác tối thiểu trước khi kỹ năng chọn đáp án có kết quả,
/// để trả lời nhanh cũng phải chịu rủi ro một lúc.
const minChoiceSeconds = 0.6;

/// Hồi được ít nhất phần này của [SkillConfig.value] thì tính là thành công.
const fullRecoveryShare = 0.9;

/// Quản lý kỹ năng của một ván: chọn, mở khóa, hồi chiêu, giữ / thi triển,
/// câu đố, ngẫu nhiên có seed. Không biết gì về giao diện.
class SkillController {
  SkillController({required this.random, required List<SkillConfig> available})
    : _available = available,
      _selected = available.first;

  final math.Random random;
  final List<SkillConfig> _available;
  final Map<String, double> _cooldowns = {};
  SkillConfig _selected;
  bool _isHolding = false;
  bool _wasSeenWhileHolding = false;
  _Cast? _cast;
  SkillFeedback? _feedback;
  int _serial = 0;

  /// Kết quả đã quyết (thả nút / chọn đáp án), áp dụng ở tick kế tiếp.
  (_Cast, bool)? _finishPending;

  SkillConfig get selected => _selected;

  SkillSnapshot get snapshot => SkillSnapshot(
    selectedId: _selected.id,
    availableIds: [for (final skill in _available) skill.id],
    cooldowns: Map.unmodifiable(_cooldowns),
    isHolding: _isHolding,
    active: _cast?.view,
    feedback: _feedback,
  );

  bool get isBusy => _isHolding || _cast != null;

  /// Kỹ năng đang giữ hoặc đang thi triển.
  String? get activeSkillId {
    if (_isHolding) return _selected.id;
    return _cast?.skill.id;
  }

  /// Xóa hồi chiêu của [id] (sự kiện hoàn lại lượt dùng).
  void refund(String id) {
    _cooldowns.remove(id);
  }

  /// Chọn kỹ năng. Kỹ năng không có ở màn này báo `locked`.
  void select(String id) {
    for (final skill in _available) {
      if (skill.id != id) continue;
      if (!isBusy) _selected = skill;
      return;
    }
    _report(id, SkillOutcome.locked);
  }

  /// Nhấn nút kỹ năng. [isWatching]: cô đang quan sát lớp lúc bấm.
  void press({required bool isWatching}) {
    final skill = _selected;
    if (_cast != null) return _report(skill.id, SkillOutcome.busy);
    final cooldown = _cooldowns[skill.id] ?? 0;
    if (cooldown > 0) {
      return _report(skill.id, SkillOutcome.notReady, amount: cooldown);
    }
    if (skill.isHold) {
      _isHolding = true;
      _wasSeenWhileHolding = false;
      return;
    }
    _cast = _Cast(
      skill: skill,
      choice: puzzleFor(skill, random),
      isPressed: skill.trigger == SkillTrigger.timedRelease,
      factor: _recoveryFactor(skill, isWatching),
      isConditionMet: _conditionAtPress(skill, isWatching),
    );
  }

  /// Thả nút kỹ năng.
  void release() {
    if (_isHolding) {
      _isHolding = false;
      _startCooldown(_selected);
      return;
    }
    final cast = _cast;
    if (cast == null || !cast.isPressed) return;
    cast.isPressed = false;
    final (from, to) = cast.skill.timingWindow;
    final isOnTime = cast.elapsed >= from && cast.elapsed <= to;
    _finishPending = (cast, isOnTime);
  }

  /// Chọn đáp án [index] cho câu đố đang mở.
  void answer(int index) {
    final cast = _cast;
    final choice = cast?.choice;
    if (cast == null || choice == null) return;
    _finishPending = (cast, index == choice.correctIndex);
  }

  /// Hủy mọi kỹ năng đang dùng (tạm dừng, hết ván, đổi sang viết bài).
  /// [keepCooldown] = false hoàn hồi chiêu cho kỹ năng thi triển dở.
  void cancel({required bool keepCooldown}) {
    if (_isHolding) {
      _isHolding = false;
      _startCooldown(_selected);
    }
    final cast = _cast;
    _cast = null;
    _finishPending = null;
    if (cast != null && keepCooldown) _startCooldown(cast.skill);
  }

  SkillTick tick(double dt, {required bool isSeen}) {
    _cooldowns.updateAll((_, left) => left - dt);
    _cooldowns.removeWhere((_, left) => left <= 0);
    if (_isHolding) return _holdTick(isSeen);
    final cast = _cast;
    if (cast == null) return SkillTick.none;
    final pending = _finishPending;
    if (pending != null && cast.elapsed >= minChoiceSeconds) {
      return _finish(cast, pending.$2, isSeen);
    }
    cast.elapsed += dt;
    if (cast.elapsed < cast.skill.castSeconds) {
      return _castTick(cast, dt, isSeen);
    }
    return _finish(cast, pending?.$2 ?? _isSuccessAtEnd(cast), isSeen);
  }

  SkillTick _holdTick(bool isSeen) {
    final skill = _selected;
    if (!isSeen) {
      return SkillTick(
        progressRate: skill.value,
        riskMultiplier: skill.riskMultiplier,
      );
    }
    if (!_wasSeenWhileHolding) {
      _wasSeenWhileHolding = true;
      _report(skill.id, SkillOutcome.failure);
    }
    return SkillTick(riskMultiplier: skill.riskMultiplier);
  }

  SkillTick _castTick(_Cast cast, double dt, bool isSeen) {
    final skill = cast.skill;
    if (!skill.isRecovery) {
      return SkillTick(riskMultiplier: skill.riskMultiplier);
    }
    var factor = cast.factor;
    if (isSeen && skill.condition != SkillCondition.teacherWatching) {
      factor = weakRecoveryFactor;
    }
    final rate = skill.value / skill.castSeconds * factor;
    cast.recovered += rate * dt;
    return SkillTick(recoverRate: rate);
  }

  bool _isSuccessAtEnd(_Cast cast) {
    final skill = cast.skill;
    if (skill.trigger == SkillTrigger.timedRelease) return false;
    if (skill.trigger == SkillTrigger.choice) return false;
    return true;
  }

  SkillTick _finish(_Cast cast, bool isSuccess, bool isSeen) {
    final skill = cast.skill;
    _cast = null;
    _finishPending = null;
    _startCooldown(skill);
    if (skill.isRecovery) {
      final isFull = cast.recovered >= skill.value * fullRecoveryShare;
      _report(skill.id, _outcome(isFull), amount: cast.recovered);
      return SkillTick.none;
    }
    final gain = _gainFor(cast, isSuccess && !isSeen);
    if (gain <= 0) {
      _report(skill.id, SkillOutcome.failure);
      if (isSeen) return const SkillTick(extraRisk: failInSightRisk);
      return SkillTick.none;
    }
    _report(skill.id, SkillOutcome.success, amount: gain);
    return SkillTick(instantGain: gain, sourceId: skill.id);
  }

  double _gainFor(_Cast cast, bool isSuccess) {
    if (!isSuccess || !cast.isConditionMet) return 0;
    final skill = cast.skill;
    switch (skill.condition) {
      case SkillCondition.chance:
        if (random.nextDouble() >= skill.successChance) return 0;
      case SkillCondition.none:
      case SkillCondition.teacherNotWatching:
      case SkillCondition.teacherWatching:
        break;
    }
    if (skill.effectKind == SkillEffectKind.randomProgress) {
      final outcomes = skill.randomOutcomes;
      return outcomes[random.nextInt(outcomes.length)];
    }
    return skill.value;
  }

  SkillOutcome _outcome(bool isSuccess) {
    if (isSuccess) return SkillOutcome.success;
    return SkillOutcome.failure;
  }

  bool _conditionAtPress(SkillConfig skill, bool isWatching) {
    if (skill.condition == SkillCondition.teacherNotWatching) {
      return !isWatching;
    }
    return true;
  }

  double _recoveryFactor(SkillConfig skill, bool isWatching) {
    if (skill.condition != SkillCondition.teacherWatching) return 1;
    if (isWatching) return 1;
    return weakRecoveryFactor;
  }

  void _startCooldown(SkillConfig skill) {
    _cooldowns[skill.id] = skill.cooldownSeconds;
  }

  void _report(String id, SkillOutcome outcome, {double amount = 0}) {
    _serial++;
    _feedback = SkillFeedback(
      skillId: id,
      outcome: outcome,
      amount: amount,
      serial: _serial,
    );
  }
}

class _Cast {
  _Cast({
    required this.skill,
    required this.choice,
    required this.isPressed,
    required this.factor,
    required this.isConditionMet,
  });

  final SkillConfig skill;
  final SkillChoice? choice;
  final double factor;
  final bool isConditionMet;
  bool isPressed;
  double elapsed = 0;
  double recovered = 0;

  ActiveSkill get view => ActiveSkill(
    skillId: skill.id,
    elapsed: elapsed,
    castSeconds: skill.castSeconds,
    choice: choice,
    isPressed: isPressed,
  );
}
