local player=game:GetService("Players").LocalPlayer
local remote=game:GetService("ReplicatedStorage"):WaitForChild("ExpressState")
local gui=Instance.new("ScreenGui")
gui.Name,gui.ResetOnSpawn,gui.Parent="ExpressHUD",false,player:WaitForChild("PlayerGui")
local navy=Color3.fromHex("14283e")
local gold=Color3.fromHex("ffd16b")
local mint=Color3.fromHex("59edc4")
local function box(class,parent,x,y,w,h,color)
	local o=Instance.new(class)
	o.Size,o.Position,o.BackgroundColor3=UDim2.fromOffset(w,h),UDim2.fromOffset(x,y),color
	o.BorderSizePixel,o.Parent=0,parent
	local corner=Instance.new("UICorner")
	corner.CornerRadius,corner.Parent=UDim.new(0,8),o
	return o
end
local function text(parent,x,y,w,h,caption,color,size)
	local l=box("TextLabel",parent,x,y,w,h,navy)
	l.BackgroundTransparency,l.Text,l.TextColor3,l.TextSize=1,caption,color,size
	l.Font,l.TextXAlignment=Enum.Font.GothamBold,Enum.TextXAlignment.Left
	return l
end
local title=box("Frame",gui,20,18,286,148,navy)
text(title,14,7,260,17,"SKY TERMINAL   //   PLATFORM 01",mint,12)
text(title,14,25,270,28,"BRAINROT EXPRESS",gold,23)
local cash=text(title,14,58,260,26,"$0  /  $0 per second",Color3.new(1,1,1),20)
local stats=text(title,14,88,272,20,"Awaiting train manifest...",mint,14)
local hands=text(title,14,110,258,30,"IN YOUR HANDS: Empty",gold,13)
hands.TextTruncate=Enum.TextTruncate.AtEnd
local clocks=box("Frame",gui,0,18,220,94,navy)
clocks.AnchorPoint,clocks.Position=Vector2.new(1,0),UDim2.new(1,-20,0,18)
local depart=text(clocks,14,9,195,23,"DEPARTURE",gold,16)
local track=box("Frame",clocks,14,39,192,6,Color3.fromHex("35475b"))
local meter=box("Frame",track,0,0,192,6,gold)
local wave=text(clocks,14,53,192,24,"SKY WAVE",mint,16)
local footer=box("Frame",gui,20,0,468,86,navy)
footer.AnchorPoint,footer.Position=Vector2.new(0,1),UDim2.new(0,20,1,-18)
local message=text(footer,12,5,445,25,"E Catch   /   F Bank",mint,13)
message.TextTruncate=Enum.TextTruncate.AtEnd
local buttons={}
local names={bag="1  BAG +1",boots="2  BOOTS +4",rebirth="3  REBIRTH"}
for i,k in {"bag","boots","rebirth"} do
	local b=box("TextButton",footer,10+(i-1)*152,36,143,37,Color3.fromHex("284261"))
	b.Text,b.Font,b.TextColor3,b.TextSize=names[k],Enum.Font.GothamBold,gold,13
	b.Activated:Connect(function() remote:FireServer(k) end)
	buttons[k]=b
end
local key={[Enum.KeyCode.One]="bag",[Enum.KeyCode.Two]="boots",[Enum.KeyCode.Three]="rebirth",[Enum.KeyCode.R]="rebirth"}
game:GetService("UserInputService").InputBegan:Connect(function(input,handled)
	if not handled and key[input.KeyCode] then remote:FireServer(key[input.KeyCode]) end
end)
local snapshot
remote.OnClientEvent:Connect(function(s)
	snapshot=s
	cash.Text=string.format("$%d   /   $%d/s   x%d",s.cash,s.income,s.multiplier)
	stats.Text=string.format("BANKED %d     BAG %d     SPEED %d",s.banked,s.capacity,s.speed)
	hands.Text="IN YOUR HANDS: "..(if s.hands=="" then "Empty" else s.hands)
	message.Text=s.message
	for k,b in buttons do b.Text=names[k].."  $"..s.costs[k] end
end)
game:GetService("RunService").RenderStepped:Connect(function()
	if not snapshot or not snapshot.departureAt then return end
	local now=workspace:GetServerTimeNow()
	local d,w=math.max(0,snapshot.departureAt-now),math.max(0,snapshot.waveAt-now)
	depart.Text=string.format("DEPARTURE   %02ds",math.ceil(d))
	wave.Text=string.format("SKY WAVE       %02ds",math.ceil(w))
	wave.TextColor3=if w<=10 then Color3.fromHex("ff887c") else mint
	meter.Size=UDim2.fromScale(math.clamp(d/90,0,1),1)
end)
remote:FireServer("sync")
