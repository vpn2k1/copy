# 06 — Assets and Audio Pipeline

## Principle
Game must work with **vector placeholder characters/props** even if PNG assets do not exist. The generated reference concept art is an art-direction document, **not a spritesheet** or license to claim it has been integrated.

## Desired files (later)
```
assets/images/classroom/bg_wall.png
assets/images/classroom/mid_desks.png
assets/images/classroom/front_desk.png
assets/images/player/player_idle.png
assets/images/player/player_write.png
assets/images/player/player_peek.png
assets/images/player/player_hide.png
assets/images/player/player_nervous.png
assets/images/player/player_caught.png
assets/images/player/player_celebrate.png
assets/images/teacher/teacher_walk.png
assets/images/teacher/teacher_look.png
assets/images/teacher/teacher_inspect.png
assets/images/ui/skill_icons.png
assets/audio/ambient_classroom.ogg
assets/audio/footsteps.ogg
assets/audio/alert.ogg
assets/audio/paper.ogg
assets/audio/win.ogg
assets/audio/lose.ogg
```

## Sprite contract
Transparent PNG, consistent anchor: bottom center at feet for people; desk anchor at bottom center; avoid baked-in HUD/text; name animations in code-to-asset mapping. Record frame width/height, FPS, collision/hitbox and draw offset per animation. Use consistent lighting and visible facial expressions.

## Placeholder implementation
Render layered 2D figures via Canvas components with separate head/eye/arm props; minimal animate via angle/position/opacity. Use static scenery only for genuinely static elements. Teacher look direction visibly changes on screen.

## Audio
Loop subtle room tone/fan at low volume; SFX pencil, shoe steps, danger, fall paper, bell; obey mute settings; no autoplay before first user gesture on web. Use locally licensed/original clips and document provenance; avoid copyrighted TV/movie sounds.

## Asset acceptance
- First-frame composition passes visual camera document.
- Pixel ratio scaling does not blur key face/HUD on 720p/1080p.
- No memory leaks / unloaded sound errors in rapid replay.
- Placeholders remain if assets absent; no red screen or runtime asset-not-found crash.
