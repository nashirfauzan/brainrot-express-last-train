# Brainrot Express

A 3D creature collection game on a railway platform in the sky. Catch wandering brainrots, carry them to the train, and bank them for income every second. Waves destroy loose cargo off the train. Departures award a bonus aboard. Upgrades buy larger bags and faster boots; rebirth resets the collection for an income multiplier. Progress lasts for the current server session.

Controls: WASD move, E catch, F deposit, 1 buy bag, 2 buy boots, 3 or R rebirth. HUD buttons are clickable.

Carrying a creature does not generate income: deposit it at the glowing wagon podium to add it to the earning collection.

Build: rojo build default.project.json --output game.rbxl
Test: node tests/run-luau.mjs; open game.rbxl in Studio, press Play, catch and bank a creature, and verify cash increases.
Play: https://www.roblox.com/games/135985390641801

- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and
  `PLAY.json` to `/output`, leaving out every name that starts with a dot (such as `.gitkeep` or `.DS_Store`, which
  fail an entry), and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.
- `game.rbxl` is built from `src/` and `default.project.json`; `screenshots/` holds running-game captures and `PLAY.json` identifies the target experience.
- One of your screenshots must also be your game's first thumbnail on Roblox: the same picture, uploaded on the
  Creator Dashboard with your game's icon.
- `TOUR.json` is an example of the optional tour: for each screenshot, the keys that bring the game to that screen.

Run it as the grader does, writing `out/` in place of `/output`:

Packaging validates the target play manifest and screenshot limits before copying the payload; it does not rebuild the place file.

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

The rules are on the bounty's page (/bounty/roblox-brainrot-01) and in the kit's RULES.txt,
which gives every command in order (Before you submit, then Enter).
