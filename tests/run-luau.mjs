import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {LuauState}=await import(process.env.LUAU_WEB_MODULE || pathToFileURL('C:/Users/USER/AppData/Local/hermes/cache/scratch/brainrot-tools/node_modules/luau-web/src/index.js').href);
const state=await LuauState.createAsync({print:console.log});
const files=fs.readdirSync('src',{recursive:true}).filter(p=>p.endsWith('.luau')).sort();
for(const file of files){state.loadstring(fs.readFileSync(path.join('src',file),'utf8'),file,true);console.log('COMPILE PASS',file)}
const module=p=>`(function()\n${fs.readFileSync(p,'utf8')}\nend)()`;
const source=`local E=${module('src/server/Economy.luau')}
local C=${module('src/server/Contracts.luau')}
local manifest=${module('tests/manifest.luau')}
manifest(E)
local s=E.new()
assert(not E.upgrade(s,'Bag'))
assert(not E.rebirth(s))
assert(E.catch(s,{id=1,mutation=1,rate=5}))
assert(not E.catch(s,{id=1,mutation=1,rate=5}))
assert(E.tick(s)==0)
assert(E.bank(s)==1 and E.tick(s)==5)
s.cash=80;assert(E.upgrade(s,'Bag') and s.cash==0 and s.Bag==1)
assert(not E.upgrade(s,'Bogus'))
for i=1,2 do assert(E.catch(s,{id=i,mutation=1,rate=5}))end
assert(E.bank(s)==2 and #s.bank==3)
s.cash=1499;assert(not E.rebirth(s))
s.cash=1500;assert(E.rebirth(s) and s.cash==0 and s.rebirth==1 and #s.bank==0 and s.Bag==0)
assert(E.catch(s,{id=1,mutation=1,rate=10}));E.bank(s);assert(E.rate(s)==15)
assert(E.catch(s,{id=2,mutation=1,rate=6}));assert(E.depart(s)==1 and #s.bank==1)
local a=C.accept(0,1)
assert(a.kind==1 and not C.act(a,'deliver',1))
assert(not C.act(a,'parcel',1) and a.stage==1)
assert(not C.act(a,'parcel',1))
assert(C.act(a,'deliver',1))
assert(not C.act(a,'deliver',1),'duplicate reward')
local stale=C.accept(0,1);C.act(stale,'parcel',1);assert(not C.act(stale,'deliver',2),'expired reward')
local target=C.accept(3,1);assert(target.target==1);assert(not C.act(target,'caught',1,2));assert(C.act(target,'caught',1,1))
local rescue=C.accept(1,1);assert(not C.act(rescue,'passenger',1));assert(C.act(rescue,'deliver',1))
local repair=C.accept(2,1);assert(C.act(repair,'repair',1));assert(not C.act(repair,'repair',1))
print('BEHAVIOR PASS: capacity, unsecured income, banking, upgrade prices, invalid upgrade, rebirth threshold/reset/multiplier, loss, delivery sequence, once-only reward, expiry, species target, escort, repair')
return true`;
try { await state.loadstring(source,'behavior',true)(); } finally { state.destroy(); }
