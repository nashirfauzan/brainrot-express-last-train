# Brainrot Express — Last Train Home

[![make.fun bounty](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/badge/roblox-brainrot-01/nashirfauzan/brainrot-express-last-train/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Reward](https://make.fun/badge/roblox-brainrot-01/nashirfauzan/brainrot-express-last-train/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

A 3D Roblox collecting game aboard an emerald-and-cream train. Catch creatures, return to your assigned wagon and bank them for income before departure. Upgrade your bag, boots and racks, complete station jobs and work toward rebirth.

Play: https://www.roblox.com/games/135985390641801
Universe: 10777563112. Publication of the final local build and reviewed icon/thumbnail remain to be verified.

## Controls

Use standard Roblox movement and camera controls. E or a proximity prompt catches, deposits and interacts. Shift sprints. Keys 1, 2 and 3 buy bag, boots and racks upgrades. R requests rebirth; the HUD shows its requirements. HUD buttons provide the same upgrade, sprint and rebirth actions.

## Build and tests

Use Node 22.18 or newer and Rojo 7.7:

    rojo build default.project.json --output game.rbxl
    node tests/run-luau.mjs
    node tests/regressions.mjs
    MAKEFUN_OUTPUT_DIR=out node main.ts

The Luau runner requires luau-web. Set LUAU_WEB_MODULE to its installed src/index.js file URL on another machine. The grader entrypoint uses only Node's standard library and the unchanged vendored dossier library.

main.ts copies game.rbxl, PLAY.json, src/ and screenshots/ and writes dossier.json. Art outside these paths is not packaged. screenshots/1-start.jpg is the intended first Roblox thumbnail.

## Provenance and remaining verification

Game source, binary and screenshots were inherited from earlier agent sessions before this recording. This final pass documents every game module, corrects the screenshot tour, excludes development debris from Rojo, and makes packaging reject stale output and invalid screenshot sets. These changes do not establish original authorship of inherited lines; acceptance of earlier provenance remains a separate gate. The official starter retains its attribution.

Automated tests compile all nine Luau scripts and exercise economy and contract behavior. The runner also executes tests/manifest.luau to check bank preservation at departure. Structural regressions check seven integration seams. These checks do not replace Studio play-tests.

Departure and rebirth on the exact final live build remain pending. This pass does not publish or submit. PLAY.json preserves the existing place and universe IDs; its link does not assert that the newly rebuilt local artifact is live. Packaging requires a fresh output directory and includes only game.rbxl, PLAY.json, src/, the three reviewed screenshots and dossier.json. The art/ icon and development tests remain outside the output.
