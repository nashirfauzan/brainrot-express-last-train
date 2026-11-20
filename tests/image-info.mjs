import { readFileSync, readdirSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { pathToFileURL } from 'node:url';

// PNG stores dimensions in its first IHDR; JPEG requires walking length-prefixed segments to a SOF.
export function imageInfo(path) {
  const data = readFileSync(path);
  const result = (width, height) => {
    if (!width || !height) throw new Error(`Zero image dimension: ${path}`);
    return { width, height, bytes: data.length };
  };
  if (data.length >= 33 && data.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) {
    if (data.readUInt32BE(8) !== 13 || data.toString('ascii',12,16) !== 'IHDR') throw new Error('Invalid PNG IHDR');
    return result(data.readUInt32BE(16), data.readUInt32BE(20));
  }
  if (data.length >= 4 && data[0] === 255 && data[1] === 216) {
    let offset = 2;
    while (offset < data.length) {
      if (data[offset++] !== 255) throw new Error('Malformed JPEG marker');
      while (data[offset] === 255) offset++;
      const marker = data[offset++];
      if (marker === 217 || marker === 218) break;
      if (marker === 1 || (marker >= 208 && marker <= 215)) continue;
      if (offset + 2 > data.length) throw new Error('Truncated JPEG length');
      const length = data.readUInt16BE(offset);
      if (length < 2 || offset + length > data.length) throw new Error('Truncated JPEG segment');
      if ([192,193,194].includes(marker)) {
        if (length < 8) throw new Error('Short JPEG frame');
        return result(data.readUInt16BE(offset+5), data.readUInt16BE(offset+3));
      }
      offset += length;
    }
  }
  throw new Error(`Unsupported or corrupt PNG/JPEG: ${path}`);
}
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const paths = process.argv.slice(2);
  if (!paths.length) paths.push(...readdirSync('screenshots').filter(n => !n.startsWith('.')).sort().map(n => join('screenshots', n)));
  if (!paths.length) throw new Error('No images to verify');
  for (const path of paths) {
    const info = imageInfo(path);
    if (info.bytes > 262144 || Math.max(info.width,info.height)>1280 || Math.min(info.width,info.height)<480) throw new Error(`Image exceeds caps: ${path}`);
    console.log(`PASS image ${path}: ${info.width}x${info.height}, ${info.bytes} bytes`);
  }
}
