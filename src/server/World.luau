-- Build the train and connect catch and cargo prompts to server callbacks.
local W={}
local Rep=game:GetService('ReplicatedStorage')
local Catalog=require(Rep.Shared.Catalog)
local Models=require(Rep.Shared.Models)
local S=require(script.Parent.Station)
local part=S.part
function W.build(root,onCatch,onBank)
 S.land(root)
 local train=Instance.new('Model');train.Name='Last Train Home';train.Parent=root;train.WorldPivot=CFrame.new()
 local function disc(name,x,y,z,l,d,c,axis)
  return part(train,name,Vector3.new(l,d,d),CFrame.new(x,y,z)*axis,c,Enum.Material.Metal,Enum.PartType.Cylinder)
 end
 local V=Vector3.new
 local cz=-63
 local longitudinal=CFrame.Angles(0,math.pi/2,0)
 part(train,'Engine frame',V(7.7,.63,17),V(0,1.77,cz),S.iron,Enum.Material.Metal)
 for _,z in {-68.4,-57.6} do for _,x in {-2.65,2.65} do
  disc('Driving wheel',x,1.56,z,.58,1.82,S.iron,CFrame.new())
  disc('Brass hub',x*1.14,1.56,z,.18,.81,S.brass,CFrame.new())
 end end
 disc('Emerald boiler',0,4.12,-65,11,4.4,S.green,longitudinal)
 for _,z in {-70.5,-67.3,-61.5} do disc('Boiler band',0,4.12,z,.18,4.49,S.brass,longitudinal) end
 disc('Smokebox door',0,4.12,-70.73,.45,3.85,S.iron,longitudinal)
 disc('Headlight',0,5.56,-71,.4,1.04,S.cream,longitudinal)
 disc('Smokestack',0,6.84,-68.5,1.82,1.04,S.iron,CFrame.Angles(0,0,math.pi/2))
 disc('Stack cap',0,7.82,-68.5,.25,1.6,S.brass,CFrame.Angles(0,0,math.pi/2))
 part(train,'Buffer beam',V(7.9,.64,.63),V(0,1.66,-71.74),S.iron)
 for _,x in {-2.65,2.65} do disc('Front buffer',x,1.66,-72.17,.63,.68,S.brass,longitudinal) end
 part(train,'Cab floor',V(7.5,.45,5.55),V(0,2.05,-57.75),S.green)
 for _,side in {-1,1} do
  local x=side*3.42
  part(train,'Cab side',V(.44,2.1,5.4),V(x,3.3,-57.75),S.green)
  part(train,'Cream pinstripe',V(.13,.18,5.45),V(side*3.67,4.12,-57.75),S.cream)
  for _,z in {-60.22,-55.3} do part(train,'Cab window pillar',V(.42,3,.43),V(x,5.72,z),S.green) end
 end
 for _,x in {-2.38,0,2.38} do part(train,'Cab roof',V(2.55,.32,5.9),CFrame.new(x,7.36-math.abs(x)*.12,-57.75)*CFrame.Angles(0,0,-x*.07),S.iron) end
 local conductorModel=Models.build(train,Catalog.get(4),4,1)
 conductorModel.Name='Train conductor'
 conductorModel:PivotTo(CFrame.new(2.4,2.28,-55.7)*CFrame.Angles(0,-math.pi/2,0))
 local conductor=conductorModel.PrimaryPart
 local label=conductor:FindFirstChild('BrainrotLabel');if label then label:Destroy()end
 local folder=Instance.new('Folder');folder.Name='Wild Brainrots';folder.Parent=root
 local spots={V(19,.18,-60),V(26,.18,-65),V(35,.18,-63),V(25,.18,-71),V(38,0,-89),V(46,0,-91),V(32,0,-90),V(25,.18,-89),V(-26,.8,-98),V(-20,.8,-106),V(-14,.8,-99),V(-27,.8,-105)}
 local state={train=train,conductor=conductor,wild=folder,spots=spots,onCatch=onCatch,onBank=onBank,slots={}}
 return state
end
function W.replenish(w)
 w.wild:ClearAllChildren()
 for id,item in Catalog.items do
  local mutation=id==10 and 2 or id==12 and 3 or 1
  local model=Models.build(w.wild,item,id,mutation);model:PivotTo(CFrame.new(w.spots[id])*CFrame.Angles(0,w.spots[id].X>0 and 2 or -1.7,0))
  local q=Instance.new('ProximityPrompt');q.ActionText='Catch';q.ObjectText=item[1];q.HoldDuration=.25;q.MaxActivationDistance=10;q.Parent=model.PrimaryPart
  q.Triggered:Connect(function(p)w.onCatch(p,model)end)
 end
end
function W.addPlayer(w,p)
 local slot=1;while w.slots[slot]do slot+=1 end;w.slots[slot]=p
 local wagon=Instance.new('Model');wagon.Name='Wagon_'..p.UserId;wagon:SetAttribute('Owner',p.UserId);wagon.Parent=w.train
 local z=-46+(slot-1)*15
 local V=Vector3.new
 local deck=part(wagon,'BoardingDeck',V(8.6,.4,13),V(0,1.99,z),Color3.fromRGB(144,110,76),Enum.Material.WoodPlanks)
 part(wagon,'Wagon chassis',V(7.6,.55,13),V(0,1.55,z),S.iron)
 for _,dz in {-4.2,4.2} do for _,x in {-2.65,2.65} do
  part(wagon,'Wagon wheel',V(.52,1.34,1.34),V(x,1.32,z+dz),S.iron,Enum.Material.Metal,Enum.PartType.Cylinder)
  part(wagon,'Wheel hub',V(.12,.59,.59),V(x*1.12,1.32,z+dz),S.brass,Enum.Material.Metal,Enum.PartType.Cylinder)
 end end
 for _,side in {-1,1} do
  for _,dz in {-4.9,4.9} do
   part(wagon,'Open cargo rail',V(.27,.78,3.2),V(side*4.18,2.58,z+dz),S.green)
   part(wagon,'Cream cargo trim',V(.3,.13,3.22),V(side*4.18,3,z+dz),S.cream)
  end
  part(wagon,'End gate',V(8.45,.75,.27),V(0,2.56,z+side*6.36),S.green)
  part(wagon,'Coupling',V(.67,.45,2),V(0,1.56,z+side*6.5),S.iron)
 end
 part(wagon,'Boarding tread',V(1.42,.24,4.8),V(4.84,1.64,z),S.brass,Enum.Material.Metal)
 local plaque=part(wagon,'Owner plate',V(.12,.55,3.08),V(4.38,2.58,z+4.9),S.iron)
 S.sign(plaque,p.DisplayName,Enum.NormalId.Right)
 local podium=part(wagon,'Deposit',V(1.45,.14,2.1),V(-2.9,2.26,z-1),S.brass);podium:SetAttribute('Owner',p.UserId)
 local q=Instance.new('ProximityPrompt');q.ActionText='Deposit carried brainrots';q.ObjectText=p.DisplayName..' cargo';q.HoldDuration=.25;q.MaxActivationDistance=10;q.Parent=podium
 q.RequiresLineOfSight=false
 q.Triggered:Connect(function(plr)w.onBank(plr,podium)end)
 local display=Instance.new('Folder');display.Name='Banked';display.Parent=wagon
 wagon:PivotTo(w.train:GetPivot()*wagon:GetPivot())
 return {model=wagon,podium=podium,display=display,deck=deck,slot=slot}
end
function W.showBank(rack,s)
 rack.display:ClearAllChildren()
 for i,item in s.bank do
  local m=Models.build(rack.display,Catalog.get(item.id),item.id,item.mutation)
  m:ScaleTo(.59)
  local offset=Vector3.new(((i-1)%3-1)*2.55,.22,i==7 and 1.9 or i<=3 and 4.65 or -4.65)
  m:PivotTo(rack.deck.CFrame*CFrame.new(offset)*CFrame.Angles(0,-math.pi/2,0))
  local label=m.PrimaryPart:FindFirstChild('BrainrotLabel');if label then label:Destroy()end
 end
end
function W.removePlayer(w,rack)
 if rack then w.slots[rack.slot]=nil;rack.model:Destroy()end
end
return W
