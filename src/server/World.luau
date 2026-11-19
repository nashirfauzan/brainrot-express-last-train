local World = {}
local v = Vector3.new
function World.build()
	local root = Instance.new("Folder")
	root.Name,root.Parent = "Express",workspace
	local function part(name,size,pos,color,material)
		local p = Instance.new("Part")
		p.Name,p.Size,p.Position,p.Color = name,size,pos,Color3.fromHex(color)
		p.Anchored,p.Material,p.Parent = true,material or Enum.Material.SmoothPlastic,root
		return p
	end
	local function sign(text,size,pos,color)
		local p = part("Sign",size,pos,color)
		local g = Instance.new("SurfaceGui")
		g.Face,g.PixelsPerStud,g.SizingMode,g.Parent = Enum.NormalId.Front,40,Enum.SurfaceGuiSizingMode.PixelsPerStud,p
		local t = Instance.new("TextLabel")
		t.Size,t.BackgroundTransparency,t.Text,t.TextColor3 = UDim2.fromScale(1,1),1,text,Color3.fromHex("fff3bc")
		t.Font,t.TextScaled,t.Parent = Enum.Font.GothamBlack,true,g
	end
	part("Platform",v(90,2,46),v(0,-1,0),"52667d")
	part("PlatformTrim",v(92,.5,48),v(0,-2,0),"f7bb55")
	part("SafetyLine",v(88,.04,.35),v(0,.04,19),"ffdb4c",Enum.Material.Neon)
	for x=-44,44,4 do
		part("Sleeper",v(1,.45,13),v(x,-1,33),"6b4c42",Enum.Material.Wood)
	end
	for _,z in {29,37} do part("Rail",v(96,.5,.45),v(0,-.5,z),"b8cce0",Enum.Material.Metal) end
	for x=-42,42,7 do
		part("RailingPost",v(.25,3,.25),v(x,1.5,-22),"cce6e8")
	end
	part("BackRail",v(88,.25,.25),v(0,3,-22),"cce6e8")
	local colors = {"49bd88","9766dc","e9b94b","4eace4","a65a4c"}
	for i,c in colors do
		local x = (i-3)*16
		part("StallCounter",v(12,3,5),v(x,1.5,-15),c)
		for _,dx in {-5.5,5.5} do part("StallPost",v(.3,8,.3),v(x+dx,4,-16),"fff3d4") end
		for j=1,8 do part("CanopyStripe",v(1.6,.4,8),v(x+(j-4.5)*1.6,8,-15),if j%2==0 then c else "fff1d2") end
		sign(({"ODDITIES","RARE FINDS","GOLD RUSH","DEEP FRIED","MYTHIC CLUB"})[i],v(11,1.4,.3),v(x,5,-12),c)
	end
	for _,x in {-40,-20,20,40} do
		part("LampPost",v(.35,9,.35),v(x,4.5,15),"23334d")
		local globe = part("Globe",v(1.6,1.6,1.6),v(x,9.2,15),"ffffff",Enum.Material.Neon)
		globe.Shape = Enum.PartType.Ball
		local light = Instance.new("PointLight")
		light.Range,light.Brightness,light.Parent = 18,1.5,globe
	end
	sign("BRAINROT EXPRESS",v(47,5,.7),v(0,14,-21),"182840")
	for _,x in {-23,23} do part("SignPillar",v(.5,14,.5),v(x,7,-21),"f3c259") end
	sign("DEPARTURES  /  ALL ABOARD  /  THE EXPRESS",v(29,2,.5),v(0,10,19),"17293d")
	for i,x in {-28,0,28} do
		part("WagonDeck",v(25,1,12),v(x,1,33),"263f59")
		part("WagonTrim",v(25,.3,12.3),v(x,1.7,33),"efb947")
		for _,dx in {-8,8} do
			for _,z in {27,39} do
				local wheel = part("Wheel",v(3,3,1),v(x+dx,-.15,z),"172330",Enum.Material.Metal)
				wheel.Shape = Enum.PartType.Cylinder
				wheel.Orientation = v(0,90,0)
			end
		end
		if i==1 then
			part("Engine",v(12,5,8),v(x-3,4,33),"32958d")
			part("Cab",v(7,8,10),v(x+6,5.5,33),"d5624c")
			part("Window",v(5,3,.2),v(x+6,7,27.9),"a7ebff",Enum.Material.Neon)
			part("Chimney",v(2,4,2),v(x-7,8,33),"23334d")
			local beacon = part("Beacon",v(1.5,1.5,1.5),v(x+6,10.2,33),"ffbf42",Enum.Material.Neon)
			beacon.Shape = Enum.PartType.Ball
		elseif i==3 then
			for j=1,4 do part("CargoCrate",v(4,4,6),v(x-9+j*4,4,34),"b88b54",Enum.Material.WoodPlanks) end
		end
	end
	part("BoardingBridge",v(10,.5,10),v(0,1,23),"b3c5c6")
	local podium = part("DepositPodium",v(4,1.5,3),v(0,2.7,29),"55ffd1",Enum.Material.Neon)
	part("CollectionShelf",v(22,.5,5),v(0,3,35),"f6d58a")
	sign("YOUR WAGON  /  BANK TO EARN",v(22,1.5,.3),v(0,6,39),"246e70")
	local spawn = Instance.new("SpawnLocation")
	spawn.Name,spawn.Size,spawn.CFrame = "StationSpawn",v(4,.2,4),CFrame.lookAt(v(0,.2,8),v(0,.2,-12))
	spawn.Anchored,spawn.Transparency,spawn.Neutral,spawn.Parent = true,1,true,root
	game:GetService("Lighting").ClockTime = 15
	game:GetService("Lighting").Ambient = Color3.fromRGB(145,160,190)

	World.root,World.podium = root,podium
	return World
end
function World.onTrain(player)
	local r = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	return r ~= nil and r.Position.Z > 26 and r.Position.Z < 40 and math.abs(r.Position.X)<42
end
function World.slot(index, lane)
	return CFrame.new(-8+((index-1)%3)*8,3.3+(math.floor((index-1)/3))*4.5,35+(lane or 0))
end
return World
