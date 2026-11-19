local World = {}
local V = Vector3.new
local C = Color3.fromHex
function World.build()
    local yard = Instance.new("Folder", workspace)
    yard.Name = "ExpressTerminal"
    local function block(name,x,y,z,sx,sy,sz,color,material)
        local p = Instance.new("Part")
        p.Name, p.Position, p.Size, p.Color = name,V(x,y,z),V(sx,sy,sz),C(color)
        p.Anchored, p.Material = true, material or Enum.Material.SmoothPlastic
        p.Parent = yard
        return p
    end
    local neon = Enum.Material.Neon
    local function board(name,x,y,z,width,height,text)
        local p = block(name,x,y,z,width,height,.45,"171E34")
        local gui = Instance.new("SurfaceGui",p)
        gui.Face, gui.CanvasSize = Enum.NormalId.Back,Vector2.new(900,math.floor(900*height/width))
        local label = Instance.new("TextLabel",gui)
        label.Size, label.BackgroundTransparency = UDim2.fromScale(1,1),1
        label.Font, label.Text, label.TextColor3, label.TextScaled = Enum.Font.GothamBold,text,C("FFE285"),true
        return p
    end
    block("Platform",0,19,0,76,2,32,"384565",Enum.Material.Slate)
    block("Foundation",0,17.5,0,74,1,30,"232B46")
    block("Safety stripe",0,20.025,-14,75,.05,.38,"FFCF4C",neon)
    block("Track bed",0,17.7,-25,76,1,14,"232B40")
    for x=-36,36,3 do block("Sleeper",x,18.35,-25,1.1,.36,11,"684659",Enum.Material.Wood) end
    for _,z in {-28,-22} do block("Rail",0,18.7,z,76,.35,.38,"B7C9DD",Enum.Material.Metal) end
    for i,color in {"36BB83","9953DE","DFAD40","42A9E8","A85B54"} do
        local x = (i-3)*14
        block("Counter",x,21.3,10,10,2.6,2.2,color)
        block("Countertop",x,22.65,10,10.7,.22,2.6,"F0D5AF")
        for _,dx in {-4.7,4.7} do
            for _,z in {7,13} do block("Canopy post",x+dx,22.5,z,.3,5,.3,"2E253A") end
        end
        for j=-5,5 do
            local p = block("Canvas stripe",x+j,25,10,1,.26,7.4,j%2==0 and color or "FFF1D2")
            p.CFrame *= CFrame.Angles(math.rad(8),0,0)
        end
        for j=-1,1 do block("Parcel",x+j*2,23.12,10,1.15,.7,1,color,Enum.Material.Wood) end
    end
    for x=-34,34,17 do
        block("Lamp",x,23.1,-11,.27,6.2,.27,"252C43",Enum.Material.Metal)
        local globe = block("Globe",x,26.35,-11,1.2,1.2,1.2,"FFFAEB",neon)
        globe.Shape = Enum.PartType.Ball
        local light = Instance.new("PointLight",globe)
        light.Range,light.Brightness,light.Color = 19,1.6,C("FFE1B0")
    end
    for _,x in {-37.6,37.6} do
        for z=-12,12,6 do block("Railing post",x,21.5,z,.25,3,.25,"B5B9DA") end
        for y=21,23 do block("Railing",x,y,0,.25,.16,26,"B5B9DA") end
    end
    for x=-36,36,6 do block("Back railing post",x,21.3,15.7,.2,2.6,.2,"939FBA") end
    block("Back railing",0,22.5,15.7,75,.22,.28,"939FBA")
    block("Sign gantry",0,25.2,14,21,10.4,.5,"222C47")
    local title = board("Title",0,29,13.65,26,3.4,"BRAINROT EXPRESS")
    title.SurfaceGui.Face = Enum.NormalId.Front
    local departures = board("Departures",30,24,-6,8,4.5,"DEPARTURES
ALL ABOARD
THE EXPRESS")
    departures.CFrame *= CFrame.Angles(0,math.rad(-18),0)
    for i,color in {"C8495C","177F80","5A548E"} do
        local x = (i-2)*23
        block("Wagon deck",x,19.6,-25,21,.8,9,color)
        block("Gold trim",x,19.6,-29.55,21,.2,.16,"EDBF64")
        for _,dx in {-7,7} do
            for _,z in {-28,-22} do
                local wheel = block("Wheel",x+dx,18.9,z,.42,2.2,2.2,"1C2337",Enum.Material.Metal)
                wheel.Shape = Enum.PartType.Cylinder
                wheel.CFrame *= CFrame.Angles(0,math.pi/2,0)
            end
        end
    end
    block("Locomotive hood",-24,21.8,-25,16,3.6,7,"B73D59",Enum.Material.Metal)
    block("Cab",-16,23,-25,5.5,6,7.4,"7C2E48")
    block("Cab window",-16,24.2,-28.75,3.8,1.7,.12,"9DDDE5",neon)
    block("Beacon",-16,26.28,-25,1,.55,1,"FFAE51",neon)
    block("Bridge",0,19.82,-18.45,8,.36,4.2,"9B7B5D",Enum.Material.WoodPlanks)
    for _,x in {-4.05,4.05} do block("Bridge edge",x,20.15,-18.4,.18,.32,4.2,"FFC34F") end
    local podium = block("Deposit",0,20.75,-22.1,2,1.5,1.7,"236462")
    block("Podium glow",0,21.56,-22.1,2.1,.16,1.8,"5FFFD0",neon)
    block("Display shelf",0,20.32,-26.5,18,.64,4.8,"233D50")
    block("Display strip",0,20.48,-24.05,18,.11,.12,"61F0CF",neon)
    for _,x in {17,23,29} do block("Cargo",x,21.25,-25,4.2,2.5,5.5,"8B72AD",Enum.Material.WoodPlanks) end
    local spawn = Instance.new("SpawnLocation")
    spawn.Name,spawn.Anchored,spawn.Neutral,spawn.Duration = "PlatformSpawn",true,true,0
    spawn.Size,spawn.Transparency,spawn.CanCollide = V(5,.2,5),1,false
    spawn.CFrame = CFrame.lookAt(V(-25,20.15,-4),V(10,20.15,9))
    spawn.Parent = yard
    local lighting = game:GetService("Lighting")
    lighting.ClockTime,lighting.Brightness = 17.1,2.7
    lighting.Ambient,lighting.OutdoorAmbient = C("8480A5"),C("A9A8C7")
    local atmosphere = Instance.new("Atmosphere",lighting)
    atmosphere.Density,atmosphere.Color,atmosphere.Decay = .26,C("CED4FF"),C("F6B18B")
    return yard,podium,spawn
end
return World
