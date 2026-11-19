import { copyFileSync, cpSync, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';
import { imageInfo } from './tests/image-info.mjs';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
const allowed = (path: string) => {
  const name = basename(path);
  if (name.startsWith('.')) return false;
  if (!/^[A-Za-z0-9_][A-Za-z0-9_.-]*$/.test(name)) throw new Error(`Invalid entry name: ${name}`);
  return true;
};
const shots = join(here, 'screenshots');
const images = readdirSync(shots, { withFileTypes: true }).filter(entry => allowed(entry.name));
if (images.length < 3 || images.length > 4) throw new Error(`Expected 3 or 4 screenshots; got ${images.length}`);
for (const entry of images) {
  if (!entry.isFile()) throw new Error(`Not a screenshot file: ${entry.name}`);
  const { width, height } = imageInfo(join(shots, entry.name));
  if (Math.max(width, height) > 1280 || Math.min(width, height) < 480) {
    throw new Error(`${entry.name}: ${width}x${height} exceeds the screenshot size limits`);
  }
}
mkdirSync(out, { recursive: true });
for (const file of ['game.rbxl', 'PLAY.json']) copyFileSync(join(here, file), join(out, file));
for (const dir of ['src', 'screenshots']) cpSync(join(here, dir), join(out, dir), { recursive: true, filter: allowed });
writeFileSync(join(out, 'dossier.json'), buildDossier(out, {
  text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576,
}));
