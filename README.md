# Brainrot Express

[![make.fun bounty](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Repository rank](https://make.fun/badge/roblox-brainrot-01/nashirfauzan/brainrot-express-last-train/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Repository reward](https://make.fun/badge/roblox-brainrot-01/nashirfauzan/brainrot-express-last-train/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

Catch ten kinds of absurd creatures at a floating railway market. Carry them to the glowing mint podium to bank them on your collection shelf. Only banked creatures earn dollars each second. Rarities range from Common to Mythic, with distinct shapes, eyes and accessories.

A sky wave crosses the station every 45 seconds. Bank cargo or shelter aboard the Express to keep it safe. Every 90 seconds a departure rewards passengers with ten seconds of double banked income. Countdown colours warn during the final ten seconds. Spend earnings on bag capacity and capped speed upgrades, or rebirth to clear your collection and add one to your permanent session multiplier.

## Controls

WASD: move; Space: jump; E near a creature: catch; F at the podium: bank everything carried.
1: bag +1; 2: boots +4 (maximum 40); 3 or R: rebirth. The HUD purchase buttons also work by click or touch. Rebirth keeps purchased bag capacity and boots, but destroys banked and carried creatures.

## Build and verify

Use Rojo 7.7.1 and Node 22.18 or later; no npm packages are needed.

    rojo build default.project.json -o game.rbxl
    node tests/run-luau.mjs
    node tests/image-info.mjs

Open game.rbxl in Roblox Studio and press Play. Source modules generate all station geometry and the HUD at runtime. The tests compare every source file against the binary place, verify the script mounts, destination manifest, screenshot limits and tour references.

Play: https://www.roblox.com/games/135985390641801

## Package

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts .

The entrypoint validates PLAY.json, checks image headers and limits, excludes dotfiles, rejects unsafe names and symlinks, copies the submission payload, and writes dossier.json through the unchanged vendored library. Without MAKEFUN_OUTPUT_DIR it writes /output. Screenshots are real Studio captures resized to 1280x720 JPEG where needed. TOUR.json describes the three views.

Progress is intentionally server-session-only: leaving clears cash, collection and upgrades. Publishing, making the experience public, and uploading its icon and first thumbnail are separate Roblox account actions; a successful local build does not prove publication.
