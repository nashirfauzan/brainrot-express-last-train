import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { matchSources, readPlace } from '../vendor/makefun-roblox.ts';
import { imageInfo } from './image-info.mjs';

process.chdir(fileURLToPath(new URL('..', import.meta.url)));
function sources(path = '') {
  return readdirSync(join('src', path), {withFileTypes: true}).flatMap(entry => {
    const name = path ? `${path}/${entry.name}` : entry.name;
    return entry.isDirectory() ? sources(name) : /\.luau$/.test(name) ? [{path:name,bytes:readFileSync(join('src',name))}] : [];
  });
}
const place = readPlace(readFileSync('game.rbxl'));
assert(place.scripts.length > 0);
for (const script of place.scripts) assert(script.source && Buffer.from(script.source).toString().trim(), `Empty: ${script.path}`);
const match = matchSources(place, sources());
assert.equal(match.coverage, 1);
assert(match.scriptMatched.every(Boolean));
console.log(`PASS: ${place.scripts.length} nonempty scripts, ${match.coveredBytes}/${match.scriptBytes} source bytes covered`);
for (const name of ['Main','Station','Economy','World']) {
  assert(place.scripts.some(script => script.path === `ServerScriptService.Server.${name}` && script.class === (name === 'Main' ? 'Script' : 'ModuleScript')));
}
console.log('PASS: Main, Station, Economy and World under ServerScriptService.Server');
const json = path => JSON.parse(readFileSync(path, 'utf8'));
assert.deepEqual(json('PLAY.json'), {place_id:135985390641801, universe_id:10777563112, url:'https://www.roblox.com/games/135985390641801'});
console.log('PASS: PLAY.json place, universe and URL');
const shots = readdirSync('screenshots').filter(name => !name.startsWith('.')).sort();
assert(shots.length === 3 || shots.length === 4, `Expected 3 or 4 screenshots; got ${shots.length}`);
for (const name of shots) {
  const image = imageInfo(join('screenshots', name));
  assert(name.endsWith(`.${image.format}`) || (image.format === 'jpg' && name.endsWith('.jpeg')));
  assert.equal(image.width, 1280, name);
  assert.equal(image.height, 720, name);
  console.log(`PASS: ${name} ${image.width}x${image.height}, ${image.size} bytes`);
}
const tour = json('TOUR.json');
assert.deepEqual(tour.steps.map(step => step.screenshot), ['1-start.jpg','2-play.jpg','3-cargo.jpg']);
assert(tour.steps.every(step => shots.includes(step.screenshot)));
console.log('PASS: all three TOUR.json screenshots exist');
