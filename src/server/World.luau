local World = {}
local Lighting = game:GetService("Lighting")
local root = Instance.new("Folder")
root.Name, root.Parent = "ExpressStation", workspace
local function part(name,size,pos,hex,material)
	local p=Instance.new("Part")
	p.Name,p.Size,p.Position,p.Color=name,size,pos,Color3.fromHex(hex)
	p.Anchored=true
	p.Material=material or Enum.Material.SmoothPlastic
	p.Parent=root
	return p
end
local function sign(text,pos,size)
	local p=part("Sign",size or Vector3.new(22,5,.5),pos,"152A44")
	local gui=Instance.new("SurfaceGui")
	gui.Face=Enum.NormalId.Front
	gui.CanvasSize=Vector2.new(1000,220)
	gui.Parent=p
	local label=Instance.new("TextLabel")
	label.Size,label.BackgroundTransparency=UDim2.fromScale(1,1),1
	label.Text,label.Font,label.TextScaled=text,Enum.Font.GothamBold,true
	label.TextColor3=Color3.fromHex("FFE79A")
	label.Parent=gui
	return label
end
function World.build()
	Lighting.ClockTime=17.2
	Lighting.Brightness=2.5
	Lighting.Ambient=Color3.fromRGB(125,132,170)
	Lighting.OutdoorAmbient=Color3.fromRGB(145,154,185)

	-- 140x76 studs leaves a broad central catching lane; track is offset 44 studs for readable boarding.
	part("SkyPlatform",Vector3.new(140,3,76),Vector3.new(0,-1.5,0),"597884",Enum.Material.Slate)
	for x=-68,68,4 do part("DeckSeam",Vector3.new(.1,.03,74),Vector3.new(x,.02,0),"78939C") end
	part("SafetyLine",Vector3.new(138,.08,1),Vector3.new(0,.06,31),"FFD35B",Enum.Material.Neon)
	part("TrackBed",Vector3.new(150,2,18),Vector3.new(0,-2,46),"293E56")
	for x=-72,72,4 do part("Sleeper",Vector3.new(1,.5,15),Vector3.new(x,-.7,46),"815B43",Enum.Material.Wood) end
	for _,z in {41,51} do part("Rail",Vector3.new(150,.6,.5),Vector3.new(0,-.2,z),"CBD6DD",Enum.Material.Metal) end
	World.train=Instance.new("Model")
	World.train.Name,World.train.Parent="ExpressTrain",root
	local function trainPart(name,size,pos,hex)
		local p=part(name,size,pos,hex,Enum.Material.Metal)
		p.Parent=World.train
		return p
	end
	for wagon=1,3 do
		local x=(wagon-2)*28
		trainPart("WagonDeck",Vector3.new(26,1,14),Vector3.new(x,3,46),"234659")
		for _,side in {-1,1} do
			for _,dx in {-8,8} do
				local wheel=trainPart("Wheel",Vector3.new(1,4,4),Vector3.new(x+dx,1,46+side*7),"172537")
				wheel.Shape=Enum.PartType.Cylinder
				wheel.Orientation=Vector3.new(0,90,0)
			end
		end
		if wagon==1 then
			trainPart("Engine",Vector3.new(14,6,10),Vector3.new(x-3,6.5,46),"E7AD47")
			trainPart("Cab",Vector3.new(8,10,12),Vector3.new(x+8,8.5,46),"286B78")
			trainPart("CabWindow",Vector3.new(5,3,.2),Vector3.new(x+8,10,39.9),"B3F1F6")
			trainPart("Chimney",Vector3.new(3,5,3),Vector3.new(x-6,11,46),"24394F")
		elseif wagon==2 then
			trainPart("Roof",Vector3.new(27,.7,15),Vector3.new(x,12,46),"3C8A98")
			for _,dx in {-11,11} do for _,z in {40,52} do trainPart("Support",Vector3.new(.5,9,.5),Vector3.new(x+dx,7.5,z),"FFD176") end end
		else
			for dx=-8,8,8 do trainPart("CargoCrate",Vector3.new(5,5,6),Vector3.new(x+dx,6,47),"AD7849") end
		end
	end
	part("BoardingBridge",Vector3.new(12,1,12),Vector3.new(0,3,35),"D4BD8A",Enum.Material.WoodPlanks)
	part("BoardingStep",Vector3.new(14,1.5,4),Vector3.new(0,.75,29),"BAA473")
	World.podium=part("Deposit",Vector3.new(9,2,7),Vector3.new(-27,1,-7),"49EBC0",Enum.Material.Neon)
	sign("F  /  BANK CARGO",Vector3.new(-27,6,-4),Vector3.new(17,3,.4))
	-- Each player gets a separate 12-stud shelf lane; 12 columns prevent overlapping creatures.
	part("CollectionShelf",Vector3.new(134,1,10),Vector3.new(0,2,-31),"D1A470",Enum.Material.WoodPlanks)
	sign("SAFE DEPOSIT  /  YOUR COLLECTION",Vector3.new(0,9,-36),Vector3.new(46,4,.5))
	for i=1,5 do
		local x=(i-3)*25
		part("MarketCounter",Vector3.new(17,4,6),Vector3.new(x,2,-20),"AB7556",Enum.Material.WoodPlanks)
		for _,dx in {-8,8} do part("StallPost",Vector3.new(.5,9,.5),Vector3.new(x+dx,4.5,-20),"FFE4B1") end
		for stripe=1,8 do part("Canopy",Vector3.new(2.2,.5,9),Vector3.new(x-9+stripe*2.2,9,-20),stripe%2==0 and "FAD898" or "D16C74") end
		sign(({"BAG SHOP","SKY BOOTS","REBIRTH","RARE FINDS","EXPRESS CAFE"})[i],Vector3.new(x,6.7,-16.7),Vector3.new(16,2,.4))
	end
	for _,x in {-60,-15,30,60} do
		part("LampPost",Vector3.new(.5,13,.5),Vector3.new(x,6.5,24),"233A50",Enum.Material.Metal)
		local globe=part("LampGlobe",Vector3.new(2.3,2.3,2.3),Vector3.new(x,13,24),"FFE8AC",Enum.Material.Neon)
		globe.Shape=Enum.PartType.Ball
		local light=Instance.new("PointLight")
		light.Color,light.Range,light.Brightness=globe.Color,24,2
		light.Parent=globe
	end
	for _,x in {-30,30} do part("SignPillar",Vector3.new(2,20,2),Vector3.new(x,10,28),"284558") end
	sign("BRAINROT EXPRESS",Vector3.new(0,19,28),Vector3.new(64,6,1))
	World.board=sign("DEPARTURES  /  EVERY 90s",Vector3.new(43,9,20),Vector3.new(27,6,.7))
	local spawn=Instance.new("SpawnLocation")
	spawn.Name,spawn.Size,spawn.Position="Arrival",Vector3.new(9,.3,9),Vector3.new(0,.2,5)
	spawn.Anchored,spawn.Neutral,spawn.Duration=true,true,0
	spawn.Color,spawn.Material=Color3.fromHex("69C8D7"),Enum.Material.Neon
	spawn.Parent=root
	return World
end
function World.onTrain(player)
	local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local p=hrp.Position
	return math.abs(p.X)<=41 and p.Z>=39 and p.Z<=53 and p.Y>=3 and p.Y<=19
end
function World.slot(index,lane)
	local row=math.floor((index-1)/12)
	return CFrame.new(-60+((index-1)%12)*10,2.5,-31-(lane-1)*12-row*6)
end
return World
