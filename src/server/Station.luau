-- Share the station palette and construction primitives with the train builder.
local S={}
local V=Vector3.new
local rgb=Color3.fromRGB
local M=Enum.Material
S.green=rgb(34,105,83)
S.cream=rgb(246,224,177)
S.brass=rgb(214,158,67)
S.iron=rgb(43,47,49)
local stone=rgb(184,159,131)
local roof=rgb(151,65,47)
local timber=rgb(86,57,44)
function S.part(parent,name,size,pos,color,material,shape)
 local p=Instance.new('Part')
 p.Name=name;p.Size=size;p.CFrame=typeof(pos)=='CFrame' and pos or CFrame.new(pos)
 p.Anchored=true;p.Color=color;p.Material=material or M.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=parent
 return p
end
local P=S.part
function S.sign(p,text,face)
 local gui=Instance.new('SurfaceGui');gui.Face=face or Enum.NormalId.Front
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=44;gui.MaxDistance=95;gui.Parent=p
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
 t.TextColor3=S.cream;t.TextScaled=true;t.Font=Enum.Font.GothamBold;t.Text=text;t.Parent=gui
end
local function gable(parent,x,y,z,width,length,color)
 local angle=math.rad(24)
 for _,side in {-1,1} do
  local cf=CFrame.new(x+side*width/4,y+width/4*math.tan(angle),z)*CFrame.Angles(0,0,-side*angle)
  P(parent,'Terracotta roof plane',V(width/2/math.cos(angle),.34,length),cf,color,M.Slate)
  P(parent,'Painted fascia',V(.32,.48,length),V(x+side*width/2,y,z),timber)
 end
 P(parent,'Ridge cap',V(.55,.42,length),V(x,y+width/2*math.tan(angle),z),color)
end
local function tree(root,x,z,height)
 P(root,'Pine trunk',V(.85,height*.7,.85),V(x,height*.35,z),timber,M.Wood)
 for i=1,3 do
  local p=Instance.new('CornerWedgePart');local w=height*(.85-i*.16)
  p.Name='Pine crown';p.Size=V(w,height*.54,w);p.CFrame=CFrame.new(x,height*(.35+i*.18),z)*CFrame.Angles(0,i*1.57,0)
  p.Color=({rgb(62,110,73),rgb(72,126,79),rgb(95,145,87)})[i];p.Anchored=true;p.CanCollide=false;p.Parent=root
 end
end
function S.land(root)
 local light=game:GetService('Lighting');light.ClockTime=16.2;light.GeographicLatitude=32
 light.Brightness=2.3;light.Ambient=rgb(104,96,92);light.OutdoorAmbient=rgb(153,149,140)
 local air=Instance.new('Atmosphere');air.Density=.23;air.Haze=1.1;air.Color=rgb(232,214,189);air.Decay=rgb(153,168,179);air.Parent=light
 P(root,'Meadow',V(174,8,270),V(1,-4,-51),rgb(104,145,81),M.Grass)
 P(root,'Ballast',V(10,.23,256),V(0,.115,-57),rgb(98,91,85),M.Pebble)
 for z=-184,70,3 do P(root,'Timber sleeper',V(8,.24,.72),V(0,.27,z),timber,M.Wood) end
 for _,x in {-2.65,2.65} do P(root,'Continuous steel rail',V(.24,.25,256),V(x,.51,-57),rgb(143,151,153),M.Metal) end
 P(root,'Platform stone',V(9,1.5,161),V(9.65,.75,-10),stone,M.Concrete)
 P(root,'Platform coping',V(.55,.18,161),V(5.35,1.51,-10),S.cream)
 for z=-88,61,3 do P(root,'Platform joints',V(8,.025,.034),V(9.8,1.515,z),rgb(146,126,109)) end
 for i=1,3 do P(root,'Long boarding step',V(.95,i*.5,144),V(16-(i-1),i*.25,-10),stone,M.Concrete) end
 P(root,'Market promenade',V(34,.18,8),V(31,.09,-64),stone,M.Cobblestone)
 P(root,'Garden path',V(8,.18,36),V(22,.09,-79),stone,M.Cobblestone)
 P(root,'West lane crossing',V(46,.16,8),V(-13,.08,-83),stone,M.Cobblestone)
 for z=-86,-80,.6 do P(root,'Flush timber crossing',V(6,.6,.48),V(0,.3,z),timber,M.Wood) end
 for _,z in {-46,-33,-20} do
  for _,x in {7.3,12.35} do
   P(root,'Iron canopy column',V(.37,8,.37),V(x,5.5,z),S.green,M.Metal)
   P(root,'Column base',V(.78,.46,.78),V(x,1.73,z),S.iron)
  end
  P(root,'Cross beam',V(7,.42,.42),V(9.8,9.3,z),timber)
 end
 for _,x in {7.3,12.35} do P(root,'Long timber beam',V(.4,.42,34),V(x,9.3,-33),timber,M.Wood) end
 gable(root,9.8,9.55,-33,8,35,roof)
 for _,z in {-38,-27} do
  P(root,'Bench seat',V(1.3,.24,4.3),V(11.9,2.4,z),timber,M.Wood)
  P(root,'Bench back',V(.22,.75,4.3),V(12.5,2.9,z),timber,M.Wood)
  for _,dz in {-1.6,1.6} do P(root,'Bench leg',V(.7,.85,.18),V(11.9,1.95,z+dz),S.iron) end
 end
 local board=P(root,'Station name',V(12,1.55,.27),V(9.8,8.35,-15.4),S.green)
 S.sign(board,'  JELLYBEAN JUNCTION  ',Enum.NormalId.Back)
 local rim=P(root,'Brass clock rim',V(.4,3.15,3.15),CFrame.new(9.8,11.1,-15.18)*CFrame.Angles(0,math.pi/2,0),S.brass,M.Metal,Enum.PartType.Cylinder)
 P(root,'Ivory clock dial',V(.18,2.76,2.76),rim.CFrame+V(0,0,.24),S.cream,M.SmoothPlastic,Enum.PartType.Cylinder)
 for i=0,11 do
  local a=i*math.pi/6
  P(root,'Clock index',V(.1,.18,.035),CFrame.new(9.8+math.sin(a)*1.18,11.1+math.cos(a)*1.18,-14.83)*CFrame.Angles(0,0,-a),S.iron)
 end
 P(root,'Minute hand',V(.08,.98,.046),CFrame.new(10.17,11.32,-14.78)*CFrame.Angles(0,0,-1),S.iron)
 P(root,'Hour hand',V(.13,.64,.046),CFrame.new(9.63,10.91,-14.77)*CFrame.Angles(0,0,-.7),S.iron)
 local buildings={{28,-32,12,12,rgb(234,201,143),'TICKETS'},{43,-32,12,14,rgb(202,147,113),'BAKERY'},{56,-33,11,11,rgb(183,190,146),'POST'}}
 for _,b in buildings do
  local x,z,w,h,color,name=table.unpack(b)
  P(root,name..' plaster',V(w,h,10),V(x,h/2,z),color,M.Plaster)
  P(root,'Stone plinth',V(w+.3,.65,10.3),V(x,.325,z),stone,M.Concrete)
  gable(root,x,h,z,w+1.15,11.3,roof)
  for _,dx in {-w*.3,w*.3} do
   P(root,'Window trim',V(2.1,2.8,.22),V(x+dx,h*.68,z-5.08),S.cream)
   P(root,'Window glass',V(1.68,2.34,.12),V(x+dx,h*.68,z-5.23),rgb(71,111,117))
   P(root,'Window mullion',V(.11,2.34,.08),V(x+dx,h*.68,z-5.31),S.cream)
  end
  P(root,'Recessed painted door',V(2.65,4.8,.2),V(x,2.4,z-5.14),S.green)
  local placard=P(root,'Shop sign',V(w*.65,1,.22),V(x,5.75,z-5.21),timber);S.sign(placard,name)
  P(root,'Canvas awning',V(w*.85,.17,2.3),CFrame.new(x,4.95,z-6.19)*CFrame.Angles(-.22,0,0),name=='BAKERY' and roof or S.green,M.Fabric)
 end
 for _,z in {-53,-73} do
  local x=33
  P(root,'Market counter',V(6.5,1.4,2.25),V(x,.7,z),timber,M.WoodPlanks)
  for _,dx in {-3,3} do for _,dz in {-1,1} do P(root,'Stall post',V(.22,4.5,.22),V(x+dx,2.25,z+dz),timber) end end
  for i=0,7 do P(root,'Striped canvas',V(.92,.13,3.25),CFrame.new(x-3.19+.92*i,4.42,z)*CFrame.Angles(.14,0,0),i%2==0 and S.cream or roof,M.Fabric) end
 end
 P(root,'Canal retaining basin',V(18,.2,9),V(40,.1,-98),stone,M.Concrete)
 P(root,'Reflecting canal',V(17,.05,8),V(40,.225,-98),rgb(82,148,148),M.Glass)
 P(root,'Clock garden terrace',V(22,.8,15),V(-20,.4,-102),stone,M.Cobblestone)
 P(root,'Garden step',V(12,.4,1.4),V(-20,.2,-93.9),stone,M.Concrete)
 for _,p in {{18,-44,7},{44,-51,8},{55,-62,11},{56,-90,10},{27,-101,10},{-33,-100,10},{-42,-92,9},{-14,-116,11},{-51,-70,10},{-37,-42,12},{-27,-27,10},{67,-43,12}} do tree(root,table.unpack(p)) end
 for i=1,12 do
  local x=-75+(i-1)*13;local z=-145-(i%3)*9
  local p=Instance.new('WedgePart');p.Name='Mountain ridge';p.Size=V(24,21+(i%4)*8,26)
  p.CFrame=CFrame.new(x,p.Size.Y/2-1,z)*CFrame.Angles(0,(i%3-1)*.4,0);p.Anchored=true;p.Color=i%2==0 and rgb(94,120,112) or rgb(112,135,120);p.Material=M.Rock;p.Parent=root
 end
end
return S
