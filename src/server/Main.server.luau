local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Catalog = require(RS.Shared.Catalog)
local Models = require(RS.Shared.Models)
local World = require(script.Parent.World).build()
local Economy = require(script.Parent.Economy)
local Station = require(script.Parent.Station)
local remote = Instance.new("RemoteEvent")
remote.Name,remote.Parent = "ExpressState",RS
local wild = {}
local function push(p)
	local s = Economy.states[p]
	if not s then return end
	local hands = {}
	for _,item in s.carried do table.insert(hands,item.data.name) end
	remote:FireClient(p,{cash=s.cash.Value,income=Economy.rate(s),multiplier=1+s.rebirths,banked=#s.banked,
		capacity=s.capacity,speed=s.speed,hands=table.concat(hands,", "),costs=Economy.costs(s),
		waveAt=Station.waveAt,departureAt=Station.departureAt,imminent=Station.imminent,message=s.message})
end
-- Validate ownership availability, capacity, and distance before changing cargo state.
local function catch(p,item)
	local s = Economy.states[p]
	local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	if not s or not r or not wild[item.model] or #s.carried>=s.capacity then return false end
	if (r.Position-item.model:GetPivot().Position).Magnitude>14 then return false end
	wild[item.model]=nil
	item.model.PrimaryPart:FindFirstChildOfClass("ProximityPrompt"):Destroy()
	item.model:PivotTo(r.CFrame*CFrame.new((#s.carried)*2,0,2.5))
	for _,part in item.model:GetDescendants() do if part:IsA("BasePart") then part.Anchored=false end end
	local w = Instance.new("WeldConstraint")
	w.Name,w.Part0,w.Part1,w.Parent = "CarryWeld",r,item.model.PrimaryPart,item.model.PrimaryPart
	table.insert(s.carried,item)
	s.message="Bring your cargo to the glowing wagon podium [F]."
	push(p)
	return true
end
local function spawnCreature(index,position)
	local d = Catalog[index]
	local m = Models.build(d)
	m.Parent=World.root
	m:PivotTo(CFrame.new(position))
	local item={data=d,model=m}
	wild[m]=item
	local prompt=Instance.new("ProximityPrompt")
	prompt.ActionText,prompt.ObjectText,prompt.KeyboardKeyCode = "Catch",d.name,Enum.KeyCode.E
	prompt.HoldDuration,prompt.MaxActivationDistance,prompt.RequiresLineOfSight,prompt.Parent=.15,10,false,m.PrimaryPart
	prompt.Triggered:Connect(function(p) catch(p,item) end)
	return item
end
-- Detach carried models before anchoring them into their earning collection slots.
local function bank(p)
	local s = Economy.states[p]
	local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	if not s or not r or (r.Position-World.podium.Position).Magnitude>14 then return false end
	for _,item in s.carried do
		item.model.PrimaryPart.CarryWeld:Destroy()
		for _,part in item.model:GetDescendants() do if part:IsA("BasePart") then part.Anchored=true end end
		table.insert(s.banked,item)
		item.model:PivotTo(World.slot(#s.banked))
	end
	s.carried={} s.message="Cargo banked. Your collection earns every second!"
	push(p)
	return true
end
local prompt=Instance.new("ProximityPrompt")
prompt.ActionText,prompt.ObjectText,prompt.KeyboardKeyCode="Bank cargo","YOUR WAGON",Enum.KeyCode.F
prompt.MaxActivationDistance,prompt.RequiresLineOfSight,prompt.Parent=12,false,World.podium
prompt.Triggered:Connect(bank)
local function joined(p)
	Economy.add(p)
	p.CharacterAdded:Connect(function(char)
		local s=Economy.states[p]
		for _,item in s.carried do item.model:Destroy() end
		s.carried={}
		local r=char:WaitForChild("HumanoidRootPart")
		r.CFrame=CFrame.lookAt(Vector3.new(0,4,8),Vector3.new(0,4,-12))
		Economy.apply(p) push(p)
	end)
	if p.Character then Economy.apply(p) end
end
Players.PlayerAdded:Connect(joined)
for _,p in Players:GetPlayers() do joined(p) end
Players.PlayerRemoving:Connect(function(p)
	local s=Economy.states[p]
	if s then for _,list in {s.banked,s.carried} do for _,item in list do item.model:Destroy() end end end
	Economy.states[p]=nil
end)
local last={}
remote.OnServerEvent:Connect(function(p,action)
	if typeof(action)~="string" then return end
	local now=os.clock()
	if now-(last[p] or 0)<.2 then return end
	last[p]=now
	if action~="sync" then Economy.buy(p,action) end
	push(p)
end)
for i=1,10 do spawnCreature(i,Vector3.new(-36+(i-1)*8,0,-3+(i%2)*7)) end
Economy.start(push)
Station.start(Economy,World,push)
task.spawn(function()
	while task.wait(3) do
		local count=0
		for m in wild do
			count+=1
			local pos=m:GetPivot().Position
			local target=Vector3.new(math.clamp(pos.X+math.random(-4,4),-40,40),0,math.clamp(pos.Z+math.random(-3,3),-7,11))
			m:PivotTo(CFrame.lookAt(target,target+Vector3.new(0,0,-1)))
		end
		if count<10 then spawnCreature(math.random(1,10),Vector3.new(math.random(-36,36),0,math.random(-5,10))) end
	end
end)
-- Studio-only harness uses the same validated gameplay functions as prompts.
if game:GetService("RunService"):IsStudio() then
	local harness=Instance.new("BindableFunction")
	harness.Name="ExpressStudio"
	harness.OnInvoke=function(player,index,deposit)
		local r=player.Character.HumanoidRootPart
		r.CFrame=CFrame.new(0,4,8)
		local caught=catch(player,spawnCreature(index,Vector3.new(1,0,8)))
		if deposit then
			r.CFrame=CFrame.new(0,5,29)
			bank(player)
		end
		local s=Economy.states[player]
		return caught,#s.banked,Economy.rate(s)
	end
	harness.Parent=script.Parent
end
