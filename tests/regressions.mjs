import fs from 'node:fs';
import assert from 'node:assert/strict';
const read=p=>fs.readFileSync(new URL('../'+p,import.meta.url),'utf8');
const checks=[
 ['Models imports its catalog',()=>assert.match(read('src/shared/Models.luau'),/local C\s*=\s*require\(script.Parent.Catalog\)/)],
 ['avatars spawn',()=>assert.equal(JSON.parse(read('default.project.json')).tree.Players.$properties.CharacterAutoLoads,true)],
 ['project identity',()=>assert.equal(JSON.parse(read('default.project.json')).name,'brainrot-express')],
 ['physical bank seam',()=>assert.match(read('src/server/Main.server.luau'),/podium.Position/)],
 ['tested economy is used',()=>{assert.match(read('src/server/Main.server.luau'),/Economy.upgrade\(/);assert.match(read('src/server/Main.server.luau'),/Economy.rebirth\(/)}],
 ['delivery state machine exists',()=>assert.ok(fs.existsSync(new URL('../src/server/Contracts.luau',import.meta.url)))],
 ['per-stop replenishment',()=>assert.match(read('src/server/World.luau'),/function W.replenish/)],
];
let failed=0;for(const [name,fn]of checks){try{fn();console.log('PASS',name)}catch(e){failed++;console.error('FAIL',name,e.message)}}
console.log(`${checks.length-failed}/${checks.length} structural checks passed`);
process.exitCode=failed?1:0;
