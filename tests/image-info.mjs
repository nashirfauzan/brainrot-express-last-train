import { readFileSync, statSync } from 'node:fs';

export function imageInfo(path) {
  const size = statSync(path).size;
  if (size > 262144) throw new Error(`${path}: ${size} bytes exceeds 256 KiB`);
  const b = readFileSync(path);
  if (b.length >= 45 && b.subarray(0, 8).toString('hex') === '89504e470d0a1a0a' &&
      b.toString('ascii', 12, 16) === 'IHDR' && b.toString('ascii', b.length - 8, b.length - 4) === 'IEND') {
    return {width: b.readUInt32BE(16), height: b.readUInt32BE(20), size, format: 'png'};
  }
  if (b.length > 4 && b.readUInt16BE(0) === 0xffd8 && b.readUInt16BE(b.length - 2) === 0xffd9) {
    let i = 2;
    while (i + 4 <= b.length && b[i++] === 255) {
      while (b[i] === 255) i++;
      const marker = b[i++];
      if (marker === 0xda || marker === 0xd9 || i + 2 > b.length) break;
      const length = b.readUInt16BE(i);
      if (length < 2 || i + length > b.length) break;
      if ([0xc0,0xc1,0xc2,0xc3,0xc5,0xc6,0xc7,0xc9,0xca,0xcb,0xcd,0xce,0xcf].includes(marker) && length >= 8) {
        return {width: b.readUInt16BE(i+5), height: b.readUInt16BE(i+3), size, format: 'jpg'};
      }
      i += length;
    }
  }
  throw new Error(`${path}: invalid JPEG/PNG framing`);
}
