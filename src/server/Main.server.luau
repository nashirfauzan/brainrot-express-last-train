local Players=game:GetService('Players')
local Rep=game:GetService('ReplicatedStorage')
local DSS=game:GetService('DataStoreService')
local Run=game:GetService('RunService')
local Economy=require(script.Parent.Economy)
local World=require(script.Parent.World)
local Missions=require(script.Parent.Missions)
local Catalog=require(Rep.Shared.Catalog)
local Models=require(Rep.Shared.Models)
local remote=Instance.new('RemoteEvent');remote.Name='ExpressEvent';remote.Parent=Rep
local root=Instance.new('Folder');root.Name='ExpressWorld';root.Parent=workspace
local profiles,racks,calls,sprints,loaded={},{},{},{},{}
local world,mission
local function toast(p,msg)remote:FireClient(p,'toast',msg)end
local function stat(p,s)
 p:SetAttribute('Cash',s.cash);p:SetAttribute('CarryCount',#s.carry);p:SetAttribute('CarryCap',1+s.Bag)
 p:SetAttribute('Income',Economy.rate(s));p:SetAttribute('Rebirth',s.rebirth);p:SetAttribute('BankCount',#s.bank);p:SetAttribute('BankCap',3+s.Racks)
 for _,name in {'Bag','Boots','Racks'}do p:SetAttribute(name,s[name]);p:SetAttribute(name..'Price',s[name]>=4 and 0 or math.floor(80*2.3^s[name]))end
 p:SetAttribute('RebirthPrice',math.floor(1500*3^s.rebirth))
end
local function near(p,pos,d)
 local c=p.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
 return h and h.Health>0 and r and (r.Position-pos).Magnitude<=d
end
local function showCarry(p,s)
 local c=p.Character;local r=c and c:FindFirstChild('HumanoidRootPart');if not r then return end
 local old=c:FindFirstChild('CarriedBrainrots');if old then old:Destroy()end
 local folder=Instance.new('Folder');folder.Name='CarriedBrainrots';folder.Parent=c
 for i,item in s.carry do
  local m=Models.build(folder,Catalog.get(item.id),item.id,item.mutation);m:ScaleTo(.6);m:PivotTo(r.CFrame*CFrame.new(2.3+(i-1)*1.7,.1,0))
  local label=m.PrimaryPart:FindFirstChild('BrainrotLabel');if label then label:Destroy()end
  for _,part in m:GetDescendants()do if part:IsA('BasePart')then part.Anchored=false;part.CanCollide=false;part.Massless=true;local weld=Instance.new('WeldConstraint');weld.Part0=r;weld.Part1=part;weld.Parent=part end end
 end
end
local function refresh(p,s)stat(p,s);showCarry(p,s);if racks[p]then World.showBank(racks[p],s)end end
local function bank(p,podium)
 local s=profiles[p];local rack=racks[p]
 if not s or not rack or podium~=rack.podium or podium:GetAttribute('Owner')~=p.UserId or not near(p,podium.Position,12)then return end
 local n=Economy.bank(s);toast(p,n>0 and 'Banked '..n..'! Your visible cargo now earns income.' or 'Rack full or bag empty. Upgrade Racks for more space.');refresh(p,s)
end
local function caught(p,m)
 if workspace:GetAttribute('Phase')~='STOP' or m.Parent~=world.wild or not m.PrimaryPart or m:GetAttribute('Claimed')then return end
 if not near(p,m.PrimaryPart.Position,12)then return end
 local s=profiles[p];if not s then return end
 local id=m:GetAttribute('Species');local item=Catalog.get(id);if not item then return end
 local mutation=m:GetAttribute('Mutation');local rate=item[3]*(mutation==2 and 3 or mutation==3 and 6 or 1)
 if Economy.catch(s,{id=id,mutation=mutation,rate=rate})then
  m:SetAttribute('Claimed',true);mission.caught(p,id,m.PrimaryPart);m:Destroy();showCarry(p,s);toast(p,'Caught '..item[1]..'! Return to YOUR glowing wagon.')
 else toast(p,'Bag full! Deposit at your train wagon.')end
 stat(p,s)
end
world=World.build(root,caught,bank)
mission=Missions.attach(root,remote,function(p,amount)local s=profiles[p];if s then s.cash=math.min(1e12,s.cash+amount);stat(p,s)end end,world.conductor)
local store
pcall(function()store=DSS:GetDataStore('LastTrainHome_v1')end)
local function bounded(v,max)
 if type(v)~='number' or v~=v or v==math.huge or v==-math.huge then return 0 end
 return math.clamp(math.floor(v),0,max)
end
local function save(p,s)
 if not s or not store or not loaded[p]then return end
 local ok=pcall(function()store:UpdateAsync('u'..p.UserId,function()return {cash=s.cash,bank=s.bank,bag=s.Bag,boots=s.Boots,racks=s.Racks,rebirth=s.rebirth}end)end)
 if not ok then warn('Brainrot Express: save unavailable; current session remains playable')end
end
local function speed(p)
 local s=profiles[p];local c=p.Character;local h=c and c:FindFirstChildOfClass('Humanoid')
 if s and h then h.WalkSpeed=16+s.Boots*2+((sprints[p]or 0)>os.clock() and 12 or 0)end
end
local function spawn(p,c)
 local r=c:WaitForChild('HumanoidRootPart',10);if not r or not profiles[p]then return end
 local s=profiles[p];Economy.depart(s);mission.cancel(p)
 c:PivotTo(racks[p].deck.CFrame*CFrame.new(0,4,0)*CFrame.Angles(0,-math.pi*.36,0));speed(p);showCarry(p,s);stat(p,s)
 -- Studio and live spawning may apply the engine's initial spawn after CharacterAdded.
 task.delay(.35,function()
  if p.Character==c and racks[p] and (r.Position-racks[p].deck.Position).Magnitude>22 then
   c:PivotTo(racks[p].deck.CFrame*CFrame.new(0,4,0)*CFrame.Angles(0,-math.pi*.36,0))
  end
 end)
 local h=c:FindFirstChildOfClass('Humanoid');if h then h.Died:Connect(function()Economy.depart(s);mission.cancel(p);stat(p,s)end)end
end
local function join(p)
 if profiles[p]then return end
 local s=Economy.new();profiles[p]=s;racks[p]=World.addPlayer(world,p)
 p.CharacterAdded:Connect(function(c)spawn(p,c)end)
 if p.Character then task.spawn(spawn,p,p.Character)end
 stat(p,s);mission.update(p)
 -- Studio uses the guarded in-memory fallback; no production data is touched by tests.
 if not Run:IsStudio() and store then
  local ok,v=pcall(function()return store:GetAsync('u'..p.UserId)end);loaded[p]=ok
  if ok and type(v)=='table' and profiles[p]==s then
   s.cash=bounded(v.cash,1e12);s.Bag=bounded(v.bag,4);s.Boots=bounded(v.boots,4);s.Racks=bounded(v.racks,4);s.rebirth=bounded(v.rebirth,20)
   if type(v.bank)=='table'then for _,item in v.bank do
    if #s.bank>=3+s.Racks then break end
    if type(item)=='table' and type(item.id)=='number' and Catalog.get(item.id)then local mutation=bounded(item.mutation,3);if mutation<1 then mutation=1 end;table.insert(s.bank,{id=item.id,mutation=mutation,rate=Catalog.get(item.id)[3]*(mutation==2 and 3 or mutation==3 and 6 or 1)})end
   end end
   refresh(p,s);speed(p)
  end
 end
end
Players.PlayerAdded:Connect(join);for _,p in Players:GetPlayers()do task.spawn(join,p)end
Players.PlayerRemoving:Connect(function(p)save(p,profiles[p]);mission.remove(p);World.removePlayer(world,racks[p]);profiles[p]=nil;racks[p]=nil;calls[p]=nil;sprints[p]=nil;loaded[p]=nil end)
remote.OnServerEvent:Connect(function(p,action,arg)
 local now=os.clock();if now-(calls[p]or 0)<.2 then return end;calls[p]=now
 local s=profiles[p];if not s then return end
 if action=='upgrade' and type(arg)=='string' and ({Bag=true,Boots=true,Racks=true})[arg]then
  local ok,price=Economy.upgrade(s,arg);toast(p,ok and arg..' upgraded for $'..price or 'Need $'..price..' (or upgrade is MAX)');speed(p)
 elseif action=='rebirth'then
  local ok,price=Economy.rebirth(s);toast(p,ok and 'REBIRTH! Permanent income +50%. Start your new collection.' or 'Rebirth needs $'..price..' and 3 banked creatures.');if ok then refresh(p,s);speed(p)end
 elseif action=='sprint'then
  if now<(p:GetAttribute('SprintReadyAt')or 0)then return end
  local c=p.Character;local h=c and c:FindFirstChildOfClass('Humanoid');if not h or h.Health<=0 then return end
  sprints[p]=now+3;p:SetAttribute('SprintReadyAt',now+9);speed(p);toast(p,'SPRINT! 3 seconds • 9 second cooldown');task.delay(3,function()speed(p)end)
 end
 stat(p,s)
end)
local function phase(value)workspace:SetAttribute('Phase',value);remote:FireAllClients('cycle',value)end
local function aboard(p)
 local c=p.Character;if not c then return false end
 local pos=c:GetPivot().Position
 for _,rack in racks do local v=rack.deck.CFrame:PointToObjectSpace(pos);if math.abs(v.X)<=4.42 and math.abs(v.Z)<=6.6 and v.Y>=1.8 and v.Y<11 then return true end end
 local v=world.train:GetPivot():PointToObjectSpace(pos);return math.abs(v.X)<=3.75 and v.Z>=-71.5 and v.Z<=-55 and v.Y>=3.8 and v.Y<14
end
local function moveTrain(distance)
 local delta=CFrame.new(0,0,distance);world.train:PivotTo(delta*world.train:GetPivot())
 for p in profiles do if p.Character then p.Character:PivotTo(delta*p.Character:GetPivot())end end
end
local stop=0
-- Income runs through travel too, independently of the station countdown.
task.spawn(function()while task.wait(1)do for p,s in profiles do Economy.tick(s);stat(p,s)end end end)
task.spawn(function()
 while true do
  stop+=1;workspace:SetAttribute('TrainStop',stop);World.replenish(world);phase('STOP')
  for t=40,1,-1 do workspace:SetAttribute('Countdown',t);task.wait(1)end
  phase('WHISTLE');mission.depart();task.wait(2)
  for p,s in profiles do
   if not aboard(p)then local lost=Economy.depart(s);toast(p,'MISSED TRAIN! Lost '..lost..' unsecured catches. Rescue return.');if p.Character then p.Character:PivotTo(racks[p].deck.CFrame*CFrame.new(0,4,2))end;showCarry(p,s);stat(p,s)
   else toast(p,'All aboard! Cargo and passengers are safe.')end
  end
  phase('MOVING');workspace:SetAttribute('Countdown',0)
  for i=1,100 do moveTrain(i<=50 and -1.4 or 1.4);task.wait(.04)end
 end
end)
game:BindToClose(function()for p,s in profiles do save(p,s)end end)
