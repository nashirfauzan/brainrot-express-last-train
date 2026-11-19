import assert from 'node:assert/strict';
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { readPlace, matchSources } from '../vendor/makefun-roblox.ts';
import { imageInfo } from './image-info.mjs';
// Preserve relative paths while collecting source bytes for the place matcher.
function sources(dir, prefix='') {
  return readdirSync(dir,{withFileTypes:true}).flatMap(e => e.isDirectory() ? sources(join(dir,e.name),prefix+e.name+'/') : /\.luau?$/.test(e.name) ? [{path:prefix+e.name,bytes:readFileSync(join(dir,e.name))}] : []);
}
const place=readPlace(readFileSync('game.rbxl'));
assert(place.scripts.length>0);
for (const s of place.scripts) assert(s.source && s.source.length>0,`Empty script ${s.path}`);
const match=matchSources(place,sources('src'));
assert.equal(match.coverage,1);
assert(match.scriptMatched.every(Boolean));
console.log(`PASS source coverage: ${match.coveredBytes}/${match.scriptBytes} bytes; ${place.scripts.length} non-empty scripts`);
for (const name of ['World','Station','Economy','Main']) assert(place.scripts.some(s=>s.path===`ServerScriptService.Server.${name}`),name);
console.log('PASS ServerScriptService.Server: World, Station, Economy, Main');
// Exact object equality also rejects unexpected manifest fields.
const play=JSON.parse(readFileSync('PLAY.json','utf8'));
assert.deepEqual(play,{url:'https://www.roblox.com/games/135985390641801',place_id:135985390641801,universe_id:10777563112});
console.log('PASS PLAY.json: place 135985390641801 / universe 10777563112 / matching URL');
const shots=readdirSync('screenshots');
assert(shots.length>=3 && shots.length<=4);
for (const shot of shots) {
  assert(/\.(jpe?g|png)$/i.test(shot));
  const i=imageInfo(join('screenshots',shot));
  assert.equal(i.width,1280); assert.equal(i.height,720); assert(i.bytes<=262144);
  console.log(`PASS screenshot ${shot}: ${i.width}x${i.height}, ${i.bytes} bytes`);
}
const tour=JSON.parse(readFileSync('TOUR.json','utf8'));
assert.equal(tour.steps.length,3);
for (const step of tour.steps) assert(shots.includes(step.screenshot) && existsSync(join('screenshots',step.screenshot)));
console.log('PASS TOUR.json: all 3 screenshot references exist');
console.log('ALL CHECKS PASSED');
