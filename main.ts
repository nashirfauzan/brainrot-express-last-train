import { copyFileSync, cpSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';
import { imageInfo } from './tests/image-info.mjs';

// Resolve inputs beside this module, independently of the caller's working directory.
const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
const manifest = JSON.parse(readFileSync(join(here, 'PLAY.json'), 'utf8')) as { url: string; place_id: number; universe_id: number };
if (manifest.place_id !== 135985390641801 || manifest.universe_id !== 10777563112 || manifest.url !== `https://www.roblox.com/games/${manifest.place_id}`) throw new Error('PLAY.json does not match the target experience');
const filter = (path: string): boolean => {
  const name = basename(path);
  if (name.startsWith('.')) return false;
  if (!/^[A-Za-z0-9_][A-Za-z0-9._-]*$/.test(name)) throw new Error(`Invalid output name: ${name}`);
  return true;
};
const shots = join(here, 'screenshots');
const captures = readdirSync(shots, { withFileTypes: true }).filter(e => !e.name.startsWith('.'));
if (captures.length < 3 || captures.length > 4) throw new Error('Expected 3 or 4 screenshots');
for (const entry of captures) {
  const p = join(shots, entry.name);
  if (!entry.isFile() || !/\.(jpe?g|png)$/i.test(entry.name) || statSync(p).size > 262144) throw new Error(`Invalid screenshot: ${entry.name}`);
  const {width, height} = imageInfo(p);
  if (Math.max(width,height) > 1280 || Math.min(width,height) < 480) throw new Error(`Screenshot dimensions out of bounds: ${entry.name}`);
}
mkdirSync(out, { recursive: true });
for (const file of ['game.rbxl', 'PLAY.json']) copyFileSync(join(here, file), join(out, file));
for (const dir of ['src', 'screenshots']) cpSync(join(here, dir), join(out, dir), { recursive: true, filter });
// Build the dossier from the copied payload so validation describes the deliverable.
writeFileSync(join(out, 'dossier.json'), buildDossier(out, {
  text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576,
}));
