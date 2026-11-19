import { readFileSync } from 'node:fs';
export function imageInfo(path) {
  const b = readFileSync(path);
  if (b.subarray(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) return { width:b.readUInt32BE(16), height:b.readUInt32BE(20), bytes:b.length };
  if (b[0] !== 255 || b[1] !== 216) throw new Error(`Not JPEG/PNG: ${path}`);
  let i=2;
  while (i < b.length) {
    if (b[i++] !== 255) throw new Error('Invalid JPEG marker');
    while (b[i] === 255) i++;
    const marker=b[i++];
    if (marker === 217 || marker === 218) break;
    const len=b.readUInt16BE(i);
    if ([192,193,194].includes(marker)) return { width:b.readUInt16BE(i+5), height:b.readUInt16BE(i+3), bytes:b.length };
    if (len<2) throw new Error('Invalid JPEG segment');
    i+=len;
  }
  throw new Error(`Missing JPEG dimensions: ${path}`);
}
