// Brainrot Express packages its Rojo-built binary and matching Luau sources.
// Only the four required artifact paths are copied; art and development tests stay out.
// The unchanged kit library derives the dossier from the actual packaged bytes.
//
// Every name under /output starts with a letter, a digit or _ and holds only letters, digits, . _ and -: the
// grader fails an entry whose output holds any other, so a file such as .gitkeep or .DS_Store copied in fails it.
// So src/ and screenshots/ are copied without any name that starts with a dot, at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, lstatSync, mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Package genuine game artifacts; never follow links outside this repository.
const notDotted = (path: string): boolean => {
  const name = basename(path);
  if (name.startsWith('.')) return false;
  if (name === 'node_modules' || name === 'Thumbs.db' || name.endsWith('.lock')) return false;
  if (!/^[A-Za-z0-9_][A-Za-z0-9._-]*$/.test(name)) throw new Error(`Unsafe artifact name: ${name}`);
  if (lstatSync(path).isSymbolicLink()) throw new Error(`Symbolic link refused: ${name}`);
  return true;
};

mkdirSync(out, { recursive: true });
// Stale artifacts would change the dossier; require a fresh output every run.
if (readdirSync(out).length) throw new Error('Output directory must be empty');
const shots = ['1-start.jpg', '2-play.jpg', '3-cargo.jpg'];
if (JSON.stringify(readdirSync(join(here, 'screenshots')).sort()) !== JSON.stringify(shots)) {
  throw new Error('Expected exactly the three reviewed JPEG screenshots');
}
for (const name of ['game.rbxl', 'PLAY.json', ...shots.map(s => `screenshots/${s}`)]) {
  const stat = lstatSync(join(here, name));
  if (!stat.isFile()) throw new Error(`Expected regular file: ${name}`);
  if (name.endsWith('.jpg') && stat.size > 262144) throw new Error(`Screenshot too large: ${name}`);
}
copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
