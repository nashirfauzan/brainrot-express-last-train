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

Game source, binary and screenshots were inherited from earlier agent sessions before this repository's new recording; they are not claimed as newly authored here. Earlier sealed recordings must be accepted for this repository before witnessed authorship can be claimed. The official starter retains its original attribution.

Automated tests cover economy and contract behavior and compile Luau; they do not replace Studio play-tests. In this recording all nine Luau scripts compiled, the behavior assertions and seven source regressions passed, and two fresh packaging runs produced identical SHA-256 hashes for all 15 output files. The vendored library matches the official starter byte for byte.

Departure and rebirth on the exact final live build remain pending. The live service announced kit level 23 during this session; use the refreshed kit for further intake checks. The CLI documents keypair signing but no API-credential signer. The existing keypair is deliberately untouched, and no submission is claimed.
