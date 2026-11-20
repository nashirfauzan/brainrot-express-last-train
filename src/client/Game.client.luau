local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local remote=game:GetService("ReplicatedStorage"):WaitForChild("ExpressState")
local gui=Instance.new("ScreenGui")
gui.Name,gui.ResetOnSpawn="ExpressHUD",false
gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
local ink=Color3.fromRGB(233,244,249)
local mint=Color3.fromRGB(92,239,196)
local function panel(name,pos,size)
	local frame=Instance.new("Frame")
	frame.Name,frame.Position,frame.Size=name,pos,size
	frame.BackgroundColor3,frame.BackgroundTransparency=Color3.fromRGB(16,32,51),.09
	frame.BorderSizePixel=0 frame.Parent=gui
	local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,12) corner.Parent=frame
	local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(68,103,120) stroke.Parent=frame
	return frame
end
local function label(parent,text,y,height,size)
	local l=Instance.new("TextLabel")
	l.BackgroundTransparency=1 l.Position=UDim2.new(0,16,0,y)
	l.Size=UDim2.new(1,-32,0,height) l.Text=text
	l.Font,l.TextSize,l.TextColor3=Enum.Font.GothamBold,size or 17,ink
	l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=parent
	return l
end
-- Top corners keep the catching lane visible; bottom strip groups all purchases.
local left=panel("Collection",UDim2.fromOffset(18,18),UDim2.fromOffset(355,166))
label(left,"BRAINROT EXPRESS",10,30,23).TextColor3=mint
local money=label(left,"$0  /  $0 per sec  /  x1",47,26,20)
local stats=label(left,"BANKED 0  |  BAG 0/1  |  SPEED 16",80,24,14)
local hands=label(left,"IN YOUR HANDS: nothing",110,42,14)
hands.TextWrapped=true
local right=panel("Timetable",UDim2.new(1,-300,0,18),UDim2.fromOffset(282,148))
local departure=label(right,"DEPARTURE  90s",12,28,21)
local track=Instance.new("Frame") track.Position=UDim2.fromOffset(16,52) track.Size=UDim2.new(1,-32,0,8)
track.BackgroundColor3=Color3.fromRGB(49,65,84) track.BorderSizePixel=0 track.Parent=right
local progress=Instance.new("Frame") progress.Size=UDim2.fromScale(0,1) progress.BackgroundColor3=mint progress.BorderSizePixel=0 progress.Parent=track
local wave=label(right,"SKY WAVE  45s",72,25,19)
label(right,"Board train to shelter carried cargo",108,22,12)
local bottom=panel("Upgrades",UDim2.new(.5,-330,1,-106),UDim2.fromOffset(660,88))
local buttons={}
for i,action in {"bag","boots","rebirth"} do
	local b=Instance.new("TextButton")
	b.Name=action b.Position=UDim2.new((i-1)/3,9,0,9) b.Size=UDim2.new(1/3,-18,1,-18)
	b.BackgroundColor3=Color3.fromRGB(37,70,86) b.TextColor3=ink b.Font=Enum.Font.GothamBold b.TextSize=16
	b.Text=action b.Parent=bottom
	local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,8) corner.Parent=b
	b.Activated:Connect(function() remote:FireServer(action) end)
	buttons[action]=b
end
local notice=label(gui,"E catch  /  F bank  /  1 bag  /  2 boots  /  3 or R rebirth",0,36,16)
notice.AnchorPoint=Vector2.new(.5,1) notice.Position=UDim2.new(.5,0,1,-112) notice.Size=UDim2.new(.85,0,0,38)
notice.TextXAlignment=Enum.TextXAlignment.Center notice.TextStrokeTransparency=.3
local state=nil
remote.OnClientEvent:Connect(function(snapshot)
	state=snapshot
	money.Text=string.format("$%d  /  $%d per sec  /  x%d",snapshot.cash,snapshot.income,snapshot.multiplier)
	stats.Text=string.format("BANKED %d  |  BAG %d/%d  |  SPEED %d",snapshot.banked,#snapshot.carried,snapshot.capacity,snapshot.speed)
	hands.Text="IN YOUR HANDS: "..(#snapshot.carried>0 and table.concat(snapshot.carried,", ") or "nothing — catch with E")
	notice.Text=snapshot.message
	if snapshot.bonusUntil>workspace:GetServerTimeNow() then money.Text..="  BONUS x2" end
	buttons.bag.Text="[1] BAG +1\n$"..snapshot.costs.bag
	buttons.boots.Text=snapshot.speed>=40 and "[2] BOOTS MAX" or "[2] BOOTS +4\n$"..snapshot.costs.boots
	buttons.rebirth.Text="[3 / R] REBIRTH\n$"..snapshot.costs.rebirth
end)
RunService.RenderStepped:Connect(function()
	if not state then return end
	local now=workspace:GetServerTimeNow()
	local d,w=math.max(0,state.departureAt-now),math.max(0,state.waveAt-now)
	departure.Text=string.format("DEPARTURE  %02ds",math.ceil(d))
	wave.Text=string.format("SKY WAVE  %02ds",math.ceil(w))
	wave.TextColor3=w<=10 and Color3.fromRGB(255,133,115) or ink
	departure.TextColor3=d<=10 and Color3.fromRGB(255,213,108) or ink
	progress.Size=UDim2.fromScale(math.clamp(1-d/90,0,1),1)
end)
Input.InputBegan:Connect(function(input,processed)
	if processed then return end
	local action=({[Enum.KeyCode.One]="bag",[Enum.KeyCode.Two]="boots",[Enum.KeyCode.Three]="rebirth",[Enum.KeyCode.R]="rebirth"})[input.KeyCode]
	if action then remote:FireServer(action) end
end)
remote:FireServer("snapshot")
