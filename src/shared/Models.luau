-- Construct the physical species models from the shared catalog IDs.
local M={}
local C=require(script.Parent.Catalog)
local V=Vector3.new
local rgb=Color3.fromRGB
local ivory=rgb(255,231,175)
local dark=rgb(51,42,47)
local red=rgb(209,79,58)
local green=rgb(79,155,111)
local gold=rgb(237,179,68)
local cinnamon=rgb(156,88,51)
local plum=rgb(153,83,164)
local steel=rgb(91,133,161)
local ball=Enum.PartType.Ball
local cylinder=Enum.PartType.Cylinder
function M.build(parent,item,id,mutation)
 local model=Instance.new('Model');model.Name=item[1];model:SetAttribute('Species',id);model:SetAttribute('Mutation',mutation or 1)
 local function piece(name,x,y,z,w,h,d,color,shape,turn)
  local p=Instance.new('Part');p.Name=name;p.Size=V(w,h,d);p.CFrame=CFrame.new(x,y,z)*(turn or CFrame.new())
  p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  if shape then p.Shape=shape end;p.Parent=model;return p
 end
 local function round(name,x,y,z,w,h,d,c) return piece(name,x,y,z,w,h,d,c,ball) end
 local function eyes(y,z,span)
  for _,side in {-1,1} do round('Eye',side*span,y,z,.24,.31,.14,dark);round('Eye glint',side*span-.045,y+.055,z-.068,.07,.08,.035,ivory) end
 end
 local function disc(name,x,y,z,depth,diameter,c,axis)
  return piece(name,x,y,z,depth,diameter,diameter,c,cylinder,axis or CFrame.Angles(0,math.pi/2,0))
 end
 local function feet(x,y,z,c)
  for _,side in {-1,1} do round('Foot',side*x,y,z,.65,.42,.91,c)end
 end
 local anchor=piece('Body',0,1.55,0,.4,.4,.4,ivory);anchor.Transparency=1;anchor.PivotOffset=CFrame.new(0,-1.55,0);model.PrimaryPart=anchor
 if id==1 then
  piece('Fridge shell',0,1.75,0,1.95,2.55,1.5,green);piece('Cream freezer door',0,2.49,-.79,1.73,.87,.15,ivory)
  piece('Lower fridge door',0,1.43,-.79,1.73,1.13,.15,rgb(153,206,175));piece('Handle',.57,1.48,-.9,.13,.51,.1,steel)
  eyes(2.53,-.9,.43);feet(.62,.25,-.11,green)
  round('Dino tail',0,.51,.93,.77,.62,1.7,green)
  for j=1,3 do round('Spine',0,2.86-j*.41,.83,.29,.41,.48,gold)end
 elseif id==2 then
  round('Duck body',0,1.27,.12,2.07,1.78,2.07,ivory);round('Duck head',0,2.36,-.63,1.45,1.4,1.34,gold)
  round('Orange bill',0,2.19,-1.3,.94,.34,.54,rgb(232,128,48));eyes(2.57,-1.18,.39);feet(.43,.22,-.34,gold)
  for _,side in {-1,1} do
   round('Wing',side*.99,1.38,-.12,.51,.73,1.2,gold)
   disc('Jet cylinder',side*.83,1.63,.9,1.58,.56,steel,CFrame.Angles(0,0,math.pi/2));round('Rocket tip',side*.83,2.4,.9,.56,.52,.56,red)
   round('Exhaust',side*.83,.73,.9,.34,.57,.34,red)
  end
 elseif id==3 then
  piece('Satay skewer',0,1.84,0,.14,3.37,.16,gold,nil,CFrame.Angles(0,0,-.32))
  for i=1,3 do round('Grilled satay',-.56+i*.27,.45+i*.76,0,.95,.8,1,cinnamon) end
  for _,side in {-1,1} do
   piece('Solar spar',side*.82,1.95,0,.8,.12,.12,steel)
   piece('Solar wing',side*1.38,1.95,0,.96,.95,.14,steel,nil,CFrame.Angles(0,0,side*.18))
   for j=-1,1 do piece('Solar cell',side*1.38,1.95+j*.25,-.09,.65,.13,.06,rgb(90,174,186)) end
  end
  eyes(2.48,-.43,.22)
 elseif id==4 then
  round('Capybara body',0,1,.52,1.65,1.68,2.08,cinnamon);round('Long capybara head',0,1.83,-.62,1.62,1.56,1.98,cinnamon)
  round('Blunt muzzle',0,1.62,-1.42,1.27,.75,.65,rgb(185,123,78));round('Nose',0,1.81,-1.75,.36,.22,.17,dark);eyes(2.02,-1.46,.5)
  for _,side in {-1,1} do round('Ear',side*.65,2.48,-.2,.36,.51,.34,cinnamon);round('Jacket panel',side*.57,1.11,.1,.73,1.38,1.7,green) end
  disc('Uniform cap',0,2.63,-.57,.38,1.63,green,CFrame.Angles(0,0,math.pi/2));round('Visor',0,2.48,-1.24,1.3,.12,.85,dark)
  piece('Cap badge',0,2.66,-1.37,.23,.23,.09,gold);piece('Ticket punch',.8,.91,-.78,.37,.37,.42,steel);feet(.49,.22,-.39,cinnamon)
 elseif id==5 then
  round('Toast crust',0,.97,.24,1.7,1.12,2.6,cinnamon);round('Toast center',0,1.36,.2,1.43,.46,2.35,ivory)
  round('Komodo head',0,1.02,-1.27,1.05,.78,1.36,green);eyes(1.29,-1.75,.34)
  for _,z in {-.54,1.01} do feet(.77,.21,z,green) end
  round('Long lizard tail',.28,.42,1.74,.59,.46,1.59,green)
 elseif id==6 then
  round('Ceramic bowl',0,1.01,0,2.89,1.28,2.89,steel)
  disc('Bowl rim',0,1.6,0,.16,3.12,ivory,CFrame.Angles(0,0,math.pi/2));round('Broth',0,1.67,0,2.62,.18,2.62,gold)
  for _,x in {-.71,0,.71} do round('Meatball',x,1.9,x==0 and -.53 or .3,.73,.76,.73,cinnamon) end
  eyes(2,-.875,.16);round('UFO thruster',0,.61,0,1.45,.55,1.45,green)
 elseif id==7 then
  piece('Cart',0,.64,0,2.29,.29,1.58,red)
  for _,x in {-1.08,1.08} do for _,z in {-.57,.57} do disc('Wheel',x,.42,z,.22,.72,dark,CFrame.new()) end end
  for i=0,6 do local a=.26+i*.37;round('Banana arc',1.36*math.cos(a),2.08-1.16*math.sin(a),0,.78,.88,1.04,gold) end
  round('Stem',-1.18,1.99,0,.41,.34,.52,cinnamon);eyes(1.37,-.51,.35)
 elseif id==8 then
  for i=1,8 do local a=i*math.pi/4;round('Tentacle',math.sin(a)*.95,.42,math.cos(a)*.95,.75,.65,.75,plum);round('Tentacle tip',math.sin(a)*1.43,.3,math.cos(a)*1.43,.42,.49,.42,plum)end
  round('Octopus mantle',0,1.43,0,2.18,2.45,2.1,plum);eyes(1.62,-.99,.41)
  for _,x in {-.52,.52} do piece('Antenna',x,2.79,.1,.12,.82,.12,steel,nil,CFrame.Angles(0,0,-x*.52));round('Antenna tip',x*1.19,3.18,.1,.26,.26,.26,gold) end
 elseif id==9 then
  round('Rooster breast',0,1.35,0,1.92,2,1.55,ivory);round('Rooster head',0,2.55,-.32,1.29,1.14,1.15,ivory)
  for i=1,3 do round('Comb',0,3.04+(i==2 and .14 or 0),-.68+i*.2,.36,.49,.36,red);round('Tail feather',i*.35-.7,1.53+i*.18,.83,.48,1.33,.79,green) end
  eyes(2.64,-.83,.36);round('Beak',0,2.38,-.93,.61,.34,.53,gold);feet(.49,.21,-.06,gold)
  disc('Alarm clock',0,1.38,-.73,.31,1.26,red);disc('Alarm dial',0,1.38,-.91,.09,1.05,ivory)
  piece('Clock hand',.08,1.49,-.975,.06,.44,.06,dark,nil,CFrame.Angles(0,0,-.55))
  piece('Second clock hand',-.12,1.35,-.98,.27,.07,.06,dark)
 elseif id==10 then
  piece('Washer body',0,1.08,.05,1.83,1.9,1.55,ivory);disc('Brass washer rim',0,1.03,-.79,.22,1.37,gold);disc('Glass drum',0,1.03,-.93,.12,1.12,steel)
  round('Dragon head',0,2.5,-.37,1.47,1.18,1.45,green);round('Dragon snout',0,2.25,-.98,1.06,.42,.64,green);eyes(2.59,-1.04,.41)
  for _,side in {-1,1} do
   round('Horns',side*.46,3.07,-.12,.27,.65,.35,gold)
   piece('Swept wing',side*1.12,1.98,.42,.68,1.36,.33,green,nil,CFrame.Angles(.3,0,-side*.51))
  end
  round('Dragon tail',.48,.44,1.01,.74,.66,1.51,green);feet(.62,.19,-.14,green)
 elseif id==11 then
  round('Velvet slipper',0,.54,0,1.82,1.04,3.14,plum);round('Curled toe',0,.79,-1.07,1.35,1.42,1.14,plum)
  round('Royal band',0,1.28,-.19,1.64,.77,1.13,gold);eyes(1.36,-.69,.34)
  for _,side in {-1,1} do round('Moustache',side*.24,1.05,-.77,.57,.18,.23,dark) end
  for i=-1,1 do piece('Crown prong',i*.42,1.98-math.abs(i)*.17,-.27,.28,.67,.42,gold,nil,CFrame.Angles(0,0,-i*.23));round('Crown gem',i*.42,2.32-math.abs(i)*.16,-.27,.23,.24,.23,red) end
 elseif id==12 then
  round('Noodle cat body',0,1.06,.17,1.95,2.05,1.82,ivory);round('Cat head',0,2.21,-.35,1.99,1.56,1.51,gold)
  for _,side in {-1,1} do
   piece('Cat ear',side*.65,2.98,-.28,.46,.69,.36,gold,nil,CFrame.Angles(0,0,-side*.3))
   piece('Inner ear',side*.65,3,-.48,.23,.4,.07,red,nil,CFrame.Angles(0,0,-side*.3))
   for j=-1,1 do piece('Whisker',side*.83,2.02+j*.11,-1.06,.67,.04,.05,dark,nil,CFrame.Angles(0,0,side*j*.18))end
  end
  eyes(2.43,-1.04,.45);round('Nose',0,2.12,-1.11,.23,.16,.15,red);feet(.53,.22,-.43,gold)
  for i=0,8 do local a=i*.48;round('Noodle curl',.75+.64*math.sin(a),.83+.58*(1-math.cos(a)),.77,.35,.35,.36,i%2==0 and gold or ivory) end
 end
 local rate=item[3]*(mutation==2 and 3 or mutation==3 and 6 or 1)
 local accent=mutation==2 and gold or mutation==3 and rgb(239,125,250) or C.names[item[2]]
 if mutation==2 or mutation==3 then
  local halo=disc('Mutation accent',0,.065,0,.11,2.55,accent,CFrame.Angles(0,0,math.pi/2));halo.Material=Enum.Material.Neon;halo.Transparency=.36
 end
 local gui=Instance.new('BillboardGui');gui.Name='BrainrotLabel';gui.Size=UDim2.fromOffset(147,35);gui.StudsOffsetWorldSpace=V(0,2.3,0);gui.MaxDistance=23;gui.Parent=anchor
 for i,text in {item[1],(mutation==2 and 'Golden' or mutation==3 and 'Glitched' or item[2])..'  ·  $'..rate..'/s'} do
  local t=Instance.new('TextLabel');t.Position=UDim2.fromScale(0,(i-1)*.5);t.Size=UDim2.fromScale(1,.5);t.BackgroundTransparency=1
  t.TextStrokeTransparency=.28;t.TextColor3=i==1 and ivory or accent;t.TextSize=i==1 and 14 or 12;t.Font=Enum.Font.GothamBold;t.Text=text;t.Parent=gui
 end
 model.Parent=parent;return model
end
return M
