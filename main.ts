import { readFileSync, readdirSync, mkdirSync, copyFileSync, writeFileSync, lstatSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { isDeepStrictEqual } from 'node:util';
import { buildDossier } from './vendor/makefun-roblox.ts';
import { imageInfo } from './tests/image-info.mjs';

const root = fileURLToPath(new URL('.', import.meta.url));
const output = resolve(process.env.MAKEFUN_OUTPUT_DIR ?? '/output');
const expected = { url: 'https://www.roblox.com/games/135985390641801', place_id: 135985390641801, universe_id: 10777563112 };
// Reject a different place, extra metadata, or a mismatched play link before copying any files.
if (!isDeepStrictEqual(JSON.parse(readFileSync(join(root,'PLAY.json'),'utf8')), expected)) throw new Error('PLAY.json is not the required published destination');
if (output === resolve(root)) throw new Error('Output cannot replace the source repository');
// Dotfiles never reach the submission; other unsafe names and symlinks are refused, not silently renamed.
function entries(directory: string): string[] {
  return readdirSync(directory).filter(name => !name.startsWith('.')).sort().map(name => {
    if (!/^[A-Za-z0-9_.-]+$/.test(name)) throw new Error(`Unsafe entry name: ${name}`);
    return name;
  });
}
const images = entries(join(root,'screenshots'));
if (images.length < 3 || images.length > 4) throw new Error('Need three or four screenshots');
for (const name of images) {
  if (!/\.(png|jpe?g)$/i.test(name)) throw new Error(`Not an image: ${name}`);
  if (!lstatSync(join(root,'screenshots',name)).isFile() || lstatSync(join(root,'screenshots',name)).isSymbolicLink()) throw new Error(`Screenshot must be a regular file: ${name}`);
  const info = imageInfo(join(root,'screenshots',name));
  // Header dimensions guard the judge's image budget; byte cap guards upload and dossier size.
  if (info.bytes > 262144 || Math.max(info.width,info.height)>1280 || Math.min(info.width,info.height)<480) throw new Error(`Screenshot outside caps: ${name}`);
}
function copy(source: string, destination: string): void {
  const stat = lstatSync(source);
  if (stat.isSymbolicLink()) throw new Error(`Symlink rejected: ${source}`);
  if (stat.isDirectory()) {
    mkdirSync(destination,{recursive:true});
    for (const name of entries(source)) copy(join(source,name),join(destination,name));
  } else if (stat.isFile()) copyFileSync(source,destination);
  else throw new Error(`Unsupported file type: ${source}`);
}
mkdirSync(output,{recursive:true});
for (const name of ['game.rbxl','PLAY.json','src','screenshots']) copy(join(root,name),join(output,name));
// Mirror the bounty caps so an oversized place fails locally rather than at submission time.
writeFileSync(join(output,'dossier.json'),buildDossier(output,{
  text_max_bytes:65536, screenshots:{max:4,max_bytes:262144}, max_instances:500000,
  scripts_max_source_bytes:8388608, scripts_max_path_chars:1048576,
}));
console.log(`PASS packaged game.rbxl, PLAY.json, src/, ${images.length} screenshots and dossier.json into ${output}`);
