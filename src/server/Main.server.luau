local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Catalog = require(ReplicatedStorage.Shared.Catalog)
local Models = require(ReplicatedStorage.Shared.Models)
local World = require(script.Parent.World)
local Station = require(script.Parent.Station)
local Economy = require(script.Parent.Economy)
local yard,podium,spawn = World.build()
local wild = Instance.new("Folder",yard)
wild.Name = "Wild"
local remote = Instance.new("RemoteEvent",ReplicatedStorage)
remote.Name = "Express"
local states = {}
local clock
local rng = Random.new()
local function rootOf(p)
    local c = p.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") or nil
end
local function push(p,message)
    local s = states[p]
    if not s then return end
    if message then s.note = message end
    local names = {}
    for _, item in s.bag do table.insert(names,Catalog[item.index][1]) end
    remote:FireClient(p,{cash=s.cash.Value,income=Economy.income(s),multiplier=s.multiplier,banked=#s.bank,
        capacity=s.capacity,speed=s.speed,bag=names,clock=clock,prices=Economy.prices(s),note=s.note})
end
local function clearBag(s)
    for _,item in s.bag do item.model:Destroy() end
    table.clear(s.bag)
end
local function attach(p,index)
    local s,root = states[p],rootOf(p)
    if not s or not root or #s.bag >= s.capacity then return false end
    local model = Models.create(index,.7)
    model.Parent = p.Character
    local slot = #s.bag
    model:PivotTo(root.CFrame*CFrame.new((slot%3-1)*.65,-.5+math.floor(slot/3)*1.4,1.18)*CFrame.Angles(0,math.pi,0))
    local weld = Instance.new("WeldConstraint",model.PrimaryPart)
    weld.Part0,weld.Part1 = root,model.PrimaryPart
    model.PrimaryPart.Anchored = false
    table.insert(s.bag,{index=index,model=model})
    push(p,"Cargo secured. Head for the podium!")
    return true
end
local function deposit(p)
    local s,root = states[p],rootOf(p)
    if not s or not root or not Station.onTrain(root) or (root.Position-podium.Position).Magnitude > 9 then return end
    if #s.bag == 0 then push(p,"Catch a creature in the market first."); return end
    for _,item in s.bag do
        local n = #s.bank
        table.insert(s.bank,item.index)
        local model = Models.create(item.index,.73)
        model:PivotTo(CFrame.new((n%3-1)*4.8,20.64+math.floor(n/9)*2.85,-24.9-math.floor(n%9/3)*1.55))
        model.Parent = s.display
    end
    clearBag(s)
    push(p,"Banked! Your cargo is earning cash.")
end
local prompt = Instance.new("ProximityPrompt",podium)
prompt.KeyboardKeyCode,prompt.ActionText,prompt.ObjectText = Enum.KeyCode.F,"Bank cargo","Express Podium"
prompt.RequiresLineOfSight,prompt.MaxActivationDistance = false,8
prompt.Triggered:Connect(deposit)
local function populate(index,x,z)
    local model = Models.create(index)
    model:PivotTo(CFrame.new(x,20,z))
    model.Parent = wild
    local catch = Instance.new("ProximityPrompt",model.PrimaryPart)
    catch.ActionText,catch.ObjectText = "Catch",Catalog[index][1] .. " / " .. Catalog[index][2]
    catch.MaxActivationDistance,catch.RequiresLineOfSight = 8,false
    catch.Triggered:Connect(function(p)
        local root = rootOf(p)
        if model.Parent ~= wild or not root or (root.Position-model.PrimaryPart.Position).Magnitude > 9 then return end
        if attach(p,index) then model:Destroy() else push(p,"Bag full. Bank your cargo or buy more space.") end
    end)
    task.spawn(function()
        while model.Parent == wild do
            local current = model:GetPivot().Position
            local goal = Vector3.new(math.clamp(x+rng:NextNumber(-4,4),-33,33),20,math.clamp(z+rng:NextNumber(-3,3),-10,5))
            local distance = (goal-current).Magnitude
            if distance > .15 then
                local body = model.PrimaryPart
                local target = CFrame.lookAt(goal,goal+(goal-current).Unit)*body.PivotOffset:Inverse()
                local tween = TweenService:Create(body,TweenInfo.new(distance/2.2,Enum.EasingStyle.Linear),{CFrame=target})
                tween:Play()
                tween.Completed:Wait()
            end
            task.wait(.7)
        end
    end)
end
local function restock()
    wild:ClearAllChildren()
    for index in Catalog do populate(index,(index-5.5)*6.3,index%2==0 and 2 or -5) end
end
clock = Station.run(function()
    for p,s in states do
        if #s.bag > 0 and not Station.onTrain(rootOf(p)) then
            clearBag(s)
            push(p,"WAVE HIT! Unbanked cargo washed away.")
        else push(p,"Wave passed. Your cargo is safe.") end
    end
end,function()
    restock()
    for p in states do push(p,"Express departed. New stock at the market!") end
end)
local function join(p)
    if states[p] then return end
    local s = Economy.new(p)
    states[p] = s
    s.display = Instance.new("Folder",yard)
    s.display.Name = "Cargo_" .. p.UserId
    local function spawned(c)
        local humanoid = c:WaitForChild("Humanoid")
        c:WaitForChild("HumanoidRootPart")
        if p.Character ~= c then return end
        c:PivotTo(spawn.CFrame*CFrame.new(0,3,0))
        humanoid.WalkSpeed = s.speed
        humanoid.Died:Connect(function() clearBag(s); push(p,"Dropped unbanked cargo.") end)
        push(p)
    end
    p.CharacterAdded:Connect(spawned)
    if p.Character then task.spawn(spawned,p.Character) end
end
Players.PlayerAdded:Connect(join)
for _,p in Players:GetPlayers() do join(p) end
Players.PlayerRemoving:Connect(function(p)
    local s = states[p]
    if s then clearBag(s); s.display:Destroy(); states[p] = nil end
end)
remote.OnServerEvent:Connect(function(p,action)
    local s = states[p]
    if not s or typeof(action) ~= "string" then return end
    local now = os.clock()
    if s.last and now-s.last < .18 then return end
    s.last = now
    if action == "sync" then push(p); return end
    if action ~= "bag" and action ~= "boots" and action ~= "rebirth" then return end
    local ok,message = Economy.buy(s,action)
    if ok then
        if action == "rebirth" then clearBag(s); s.display:ClearAllChildren() end
        local root = rootOf(p)
        if root then p.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = s.speed end
    end
    push(p,ok and "Upgrade purchased!" or message)
end)
-- Test photography hooks exist only in local Studio sessions.
if RunService:IsStudio() then
    local seed = Instance.new("BindableFunction",script)
    seed.Name = "PhotoSeed"
    seed.OnInvoke = function(p,shot)
        local s = states[p]
        if not s or not rootOf(p) then return false end
        clearBag(s)
        if shot == "play" then
            p.Character:PivotTo(CFrame.lookAt(Vector3.new(-7,23,-5),Vector3.new(0,23,-18)))
            attach(p,5)
        elseif shot == "cargo" then
            p.Character:PivotTo(CFrame.new(0,23,-22))
            for _,i in {1,3,7,8,9,10} do attach(p,i); deposit(p) end
        end
        return true
    end
end
restock()
Economy.run(states,push)
