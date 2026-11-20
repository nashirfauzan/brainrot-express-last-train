import assert from 'node:assert/strict';
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { readPlace, matchSources } from '../vendor/makefun-roblox.ts';
import { imageInfo } from './image-info.mjs';

const pass = text => console.log(`PASS ${text}`);
const place = readPlace(readFileSync('game.rbxl'));
const sources = [];
function walk(dir) {
  for (const entry of readdirSync(dir,{withFileTypes:true})) {
    const path = join(dir,entry.name);
    if (entry.isDirectory()) walk(path);
    else if (/\.lua[u]?$/.test(path)) sources.push({path:path.replaceAll('\\','/'),bytes:readFileSync(path)});
  }
}
walk('src');
assert.ok(sources.length > 0);
const matches = matchSources(place,sources);
assert.deepEqual(matches.unmatched,[]);
assert.equal(matches.matched.length,sources.length);
pass(`all ${sources.length} source files equal place scripts`);
assert.equal(matches.coveredBytes,matches.scriptBytes);
assert.equal(matches.coverage,1);
assert.ok(matches.scriptMatched.every(Boolean));
pass(`all ${matches.scriptBytes} script bytes covered`);
assert.ok(place.scripts.every(script => script.source && Buffer.from(script.source).toString('utf8').trim().length > 0));
pass('every embedded script is non-empty');
for (const name of ['World','Station','Economy','Main']) {
  assert.ok(place.scripts.some(script => script.path === `ServerScriptService.Server.${name}`),name);
}
pass('World, Station, Economy and Main mounted under ServerScriptService.Server');
assert.deepEqual(JSON.parse(readFileSync('PLAY.json','utf8')),{
  url:'https://www.roblox.com/games/135985390641801',place_id:135985390641801,universe_id:10777563112,
});
pass('PLAY.json exactly matches the destination');
const names = readdirSync('screenshots').filter(name => !name.startsWith('.')).sort();
assert.ok(names.length === 3 || names.length === 4);
for (const name of names) {
  assert.match(name,/\.(png|jpe?g)$/i);
  const info=imageInfo(join('screenshots',name));
  assert.equal(info.width,1280); assert.equal(info.height,720); assert.ok(info.bytes<=262144);
  pass(`screenshot ${name}: ${info.width}x${info.height}, ${info.bytes} bytes`);
}
const tour=JSON.parse(readFileSync('TOUR.json','utf8'));
assert.equal(tour.steps.length,3);
assert.equal(new Set(tour.steps.map(step => step.screenshot)).size,3);
for (const step of tour.steps) {
  assert.ok(names.includes(step.screenshot));
  assert.ok(existsSync(join('screenshots',step.screenshot)));
  assert.ok(Array.isArray(step.keys));
}
pass('three tour steps reference existing screenshots and key instructions');
