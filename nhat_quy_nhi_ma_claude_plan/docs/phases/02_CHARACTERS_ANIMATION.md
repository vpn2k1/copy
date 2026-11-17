# Phase 02 — Character Components and Animation

## Steps
1. Create reusable student component and player appearance, with defined layer order and anchor points.
2. Support states idle, writing, cheating, nervous, hiding, caught, celebrating. Each changes visible eyes/head/hands (not just label).
3. Build teacher component with walk/turn/lookLeft/lookRight/inspect/caught; add other students subtle write/blink animations.
4. Animator accepts state changes and delta time; no asset required (vector placeholder allowed).
5. Expose teacher directional indicators and player reaction to suspicion. Provide animation state test and GIF/screenshot if available.

## Done when
- [ ] All required poses visibly differ, no overlapping limbs or hidden faces.
- [ ] Transition to caught/win stops previous animations.
- [ ] Animation works in same camera frame on phone layout.
- [ ] Tests and progress updated.
