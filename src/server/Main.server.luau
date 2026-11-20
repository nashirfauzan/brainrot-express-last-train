local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Catalog=require(ReplicatedStorage.Shared.Catalog)
local Models=require(ReplicatedStorage.Shared.Models)
local World=require(script.Parent.World).build()
local Economy=require(script.Parent.Economy)
local Station=require(script.Parent.Station)
local remote=Instance.new("RemoteEvent")
remote.Name,remote.Parent="ExpressState",ReplicatedStorage
local wild={}
local lastCall={}
local nextLane=0
local function push(player)
	local s=Economy.states[player]
	if not s or not player.Parent then return end
	local names={}
	for _,item in s.carried do table.insert(names,item.entry.name) end
	remote:FireClient(player,{cash=s.cash,income=Economy.rate(s),multiplier=s.rebirth+1,banked=#s.banked,capacity=s.capacity,speed=s.speed,carried=names,costs=Economy.costs(s),waveAt=Station.waveAt,departureAt=Station.departureAt,imminent=Station.imminent,message=s.message,bonusUntil=s.bonusUntil})
end
local function rootOf(player)
	local character=player.Character
	local hum=character and character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health<=0 then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end
local function clearCargo(player)
	local s=Economy.states[player]
	if not s then return end
	for _,item in s.carried do item.model:Destroy() end
	s.carried={}
end
local function catch(player,item)
	-- Server membership, live character, capacity, unclaimed item and distance are checked before any weld.
	local s=Economy.states[player]
	local root=rootOf(player)
	if not s or not root or not wild[item] or #s.carried>=s.capacity then return end
	if (root.Position-item.model.PrimaryPart.Position).Magnitude>12 then return end
	wild[item]=nil
	if item.tween then item.tween:Cancel() end
	item.prompt:Destroy()
	item.model:PivotTo(root.CFrame*CFrame.new((#s.carried%3-1)*2.2,0,-3-math.floor(#s.carried/3)*2))
	for _,p in item.model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored,p.CanCollide,p.Massless=false,false,true
			local weld=Instance.new("WeldConstraint")
			weld.Name,weld.Part0,weld.Part1="CarryWeld",root,p
			weld.Parent=p
		end
	end
	table.insert(s.carried,item)
	s.message="Caught "..item.entry.name..". Take it to the mint podium!"
	push(player)
end
local function bank(player)
	local s=Economy.states[player]
	local root=rootOf(player)
	if not s or not root or (root.Position-World.podium.Position).Magnitude>14 then return end
	for _,item in s.carried do
		for _,p in item.model:GetDescendants() do
			if p:IsA("WeldConstraint") then p:Destroy()
			elseif p:IsA("BasePart") then p.Anchored=true end
		end
		table.insert(s.banked,item)
		local slot=World.slot(#s.banked,s.lane)
		local support=Instance.new("Part")
		support.Name,support.Size,support.CFrame="PersonalShelf",Vector3.new(8,.5,6),item.model:GetPivot()*CFrame.new(0,-.25,0)
		support.Anchored=true support.Color=Color3.fromRGB(122,94,67)
		support.Parent=item.model
		item.model:PivotTo(slot)
	end
	s.carried={}
	s.message="Cargo secured. Your shelf now earns $"..Economy.rate(s).." every second."
	push(player)
end
local function spawnCreature(index)
	local entry=Catalog[index]
	local model=Models.build(entry)
	model.Parent=workspace.ExpressStation
	model:PivotTo(CFrame.new(-54+(index-1)%5*25,.1, index<=5 and 3 or 16))
	local prompt=Instance.new("ProximityPrompt")
	prompt.ActionText,prompt.ObjectText="Catch",entry.name
	prompt.KeyboardKeyCode=Enum.KeyCode.E
	prompt.MaxActivationDistance,prompt.RequiresLineOfSight=10,false
	prompt.Parent=model.PrimaryPart
	local item={entry=entry,model=model,prompt=prompt}
	wild[item]=true
	prompt.Triggered:Connect(function(player) catch(player,item) end)
end
local deposit=Instance.new("ProximityPrompt")
deposit.ActionText,deposit.ObjectText="Bank all cargo","SAFE DEPOSIT"
deposit.KeyboardKeyCode,deposit.MaxActivationDistance=Enum.KeyCode.F,12
deposit.RequiresLineOfSight=false
deposit.Parent=World.podium
deposit.Triggered:Connect(bank)
remote.OnServerEvent:Connect(function(player,action)
	-- Only known upgrade strings or a snapshot request are accepted; all prices remain server-owned.
	if typeof(action)~="string" then return end
	local now=os.clock()
	if now-(lastCall[player] or -1)<.25 then return end
	lastCall[player]=now
	if action=="bag" or action=="boots" or action=="rebirth" then Economy.buy(player,action) end
	push(player)
end)
local function joined(player)
	if Economy.states[player] then return end
	local s=Economy.add(player)
	nextLane+=1 s.lane=nextLane
	player.CharacterAdded:Connect(function(character)
		clearCargo(player)
		character:WaitForChild("Humanoid",10)
		Economy.apply(player)
		push(player)
	end)
	if player.Character then Economy.apply(player) end
	push(player)
end
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
	clearCargo(player)
	local s=Economy.states[player]
	if s then for _,item in s.banked do item.model:Destroy() end end
	Economy.states[player],lastCall[player]=nil,nil
end)
for _,player in Players:GetPlayers() do joined(player) end
for i=1,10 do spawnCreature(i) end
Station.start(Economy,World,push)
Economy.start(push)
task.spawn(function()
	while task.wait(4) do
		local count=0
		for item in wild do
			if not item.model.Parent then wild[item]=nil else
				count+=1

				-- Move the complete anchored model rather than separating its face from its body.
				local start=item.model:GetPivot()
				local target=CFrame.new(math.clamp(start.X+math.random(-5,5),-62,62),.1,math.clamp(start.Z+math.random(-4,4),-3,23))
				local value=Instance.new("CFrameValue") value.Value=start
				local connection=value.Changed:Connect(function(cf) if wild[item] then item.model:PivotTo(cf) end end)
				item.tween=TweenService:Create(value,TweenInfo.new(3.5,Enum.EasingStyle.Sine),{Value=target})
				item.tween:Play()
				task.delay(3.6,function() connection:Disconnect() value:Destroy() end)
			end
		end
		for _=count+1,10 do spawnCreature(math.random(1,#Catalog)) end
	end
end)
