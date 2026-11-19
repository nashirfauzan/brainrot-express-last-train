# Brainrot Express

Catch wandering creatures at a floating night market and bank them on your train. Banked creatures earn cash each second; a wave washes away unbanked cargo if you are off the train. Departures restock the market.

- **E** catches; **F** deposits at the glowing podium.
- **1** buys a bag slot, **2** buys +4 speed, and **3** or **R** rebirths. The HUD buttons also work.
- Rebirth clears cash and cargo but raises the income multiplier. Upgrades survive respawns within the server.

Build with `rojo build default.project.json --output game.rbxl`, open the file in Roblox Studio and press Play. Catch and bank a creature, check the income, and try holding cargo off the train through a wave. Run `node tests/run-luau.mjs` with Node 22.18+ to verify the built place and media. Set `MAKEFUN_OUTPUT_DIR` and run `node main.ts` to package.

[Play on Roblox](https://www.roblox.com/games/135985390641801)
