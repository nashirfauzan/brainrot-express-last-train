local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Input = game:GetService("UserInputService")
local remote = game.ReplicatedStorage:WaitForChild("Express")
local gui = Instance.new("ScreenGui")
gui.Name,gui.ResetOnSpawn = "ExpressHUD",false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local C = Color3.fromHex
local function panel(name,x,y,w,h,ax,ay)
    local f = Instance.new("Frame",gui)
    f.Name,f.Size,f.AnchorPoint = name,UDim2.fromOffset(w,h),Vector2.new(ax,ay)
    f.Position = UDim2.new(x,ax == 1 and -18 or 18,y,ay == 1 and -18 or 12)
    f.BackgroundColor3,f.BackgroundTransparency = C("111B30"),.12
    local c = Instance.new("UICorner",f); c.CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke",f); stroke.Color,stroke.Transparency = C("84ABC9"),.45
    return f
end
local function text(parent,x,y,w,h,content,color,size,button)
    local t = Instance.new(button and "TextButton" or "TextLabel",parent)
    t.Position,t.Size = UDim2.fromOffset(x,y),UDim2.fromOffset(w,h)
    t.BackgroundTransparency,t.BackgroundColor3 = button and 0 or 1,C("253B54")
    t.Font,t.Text,t.TextColor3,t.TextSize = Enum.Font.GothamBold,content,C(color),size
    t.TextXAlignment = button and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    if button then local c = Instance.new("UICorner",t); c.CornerRadius = UDim.new(0,6) end
    return t
end
local left = panel("Ledger",0,0,248,132,0,0)
text(left,12,8,224,20,"BRAINROT EXPRESS  /  01","FFD87D",16)
local cash = text(left,12,30,224,33,"$0","F6F6FF",29)
local income = text(left,12,67,224,19,"+$0/sec  ·  x1 income","65F2CE",15)
local cargo = text(left,12,95,224,25,"0 banked  ·  Bag 0/1  ·  SPD 16","B9CEEB",14)
local clockPanel = panel("Clocks",1,0,211,99,1,0)
local depart = text(clockPanel,12,8,187,25,"DEPARTURE  --","FFD87D",16)
local track = Instance.new("Frame",clockPanel)
track.Position,track.Size,track.BackgroundColor3 = UDim2.fromOffset(12,42),UDim2.fromOffset(187,5),C("354969")
track.BorderSizePixel = 0
local bar = Instance.new("Frame",track)
bar.Size,bar.BorderSizePixel,bar.BackgroundColor3 = UDim2.fromScale(1,1),0,C("FFCA64")
local wave = text(clockPanel,12,61,187,23,"WAVE  --","7CE7FF",17)
local hands = panel("Cargo",0,1,300,78,0,1)
text(hands,12,6,276,18,"IN YOUR HANDS","FFD87D",13)
local held = text(hands,12,27,276,22,"Empty · E catch / F bank","FFFFFF",15)
held.TextTruncate = Enum.TextTruncate.AtEnd
local note = text(hands,12,53,276,18,"Catch a creature at the market.","B9CEEB",12)
note.TextTruncate = Enum.TextTruncate.AtEnd
local shop = panel("Upgrades",1,1,303,57,1,1)
local buttons = {}
for i,row in {{"bag","BAG +1"},{"boots","BOOTS +4"},{"rebirth","REBIRTH"}} do
    local id,label = table.unpack(row)
    local b = text(shop,8+(i-1)*97,8,92,41,label,"DFF8FF",12,true)
    buttons[id] = {b,label,i}
    b.Activated:Connect(function() remote:FireServer(id) end)
end
local keys = {[Enum.KeyCode.One]="bag",[Enum.KeyCode.Two]="boots",[Enum.KeyCode.Three]="rebirth",[Enum.KeyCode.R]="rebirth"}
Input.InputBegan:Connect(function(input,processed)
    if not processed and keys[input.KeyCode] then remote:FireServer(keys[input.KeyCode]) end
end)
local clocks
remote.OnClientEvent:Connect(function(s)
    cash.Text = "$" .. s.cash
    income.Text = ("+$%d/sec  ·  x%d income"):format(s.income,s.multiplier)
    cargo.Text = ("%d banked  ·  Bag %d/%d  ·  SPD %d"):format(s.banked,#s.bag,s.capacity,s.speed)
    held.Text = #s.bag > 0 and table.concat(s.bag,", ") or "Empty · E catch / F bank"
    if s.note then note.Text = s.note end
    for id,row in buttons do row[1].Text = ("%d  %s\n$%d"):format(row[3],row[2],s.prices[id]) end
    clocks = s.clock
end)
RunService.RenderStepped:Connect(function()
    if not clocks then return end
    local now = workspace:GetServerTimeNow()
    local d,w = math.max(0,clocks.depart-now),math.max(0,clocks.wave-now)
    depart.Text = ("DEPARTURE  %02ds"):format(math.ceil(d))
    bar.Size = UDim2.fromScale(math.clamp(d/clocks.period,0,1),1)
    wave.Text = (w <= clocks.imminent and "WAVE IMMINENT  %02ds" or "NEXT WAVE  %02ds"):format(math.ceil(w))
    wave.TextColor3 = C(w <= clocks.imminent and "FF866D" or "7CE7FF")
end)
remote:FireServer("sync")
