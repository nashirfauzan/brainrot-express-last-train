-- Bind station prompts and player mission attributes to contract state.
local Contracts=require(script.Parent.Contracts)
local Station=require(script.Parent.Station)
local M={}
function M.attach(root,remote,pay,conductor)
 local active,indices,visuals={},{},{}
 local function update(p)
  local a=active[p]
  p:SetAttribute('MissionTitle',a and a.title or 'Visit orange contract board')
  local progress='Optional • expires at departure'
  if a then progress=a.done and 'PAID' or a.kind==4 and 'Catch Kulkasaurus' or a.stage==1 and 'Return to conductor!' or 'Find station objective' end
  p:SetAttribute('MissionProgress',progress);p:SetAttribute('MissionReward',a and '$'..a.reward or '$350–650')
 end
 local function clearVisual(p)if visuals[p]then visuals[p]:Destroy();visuals[p]=nil end end
 local function valid(p,part)
  local c=p.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
  return workspace:GetAttribute('Phase')=='STOP' and h and h.Health>0 and r and (r.Position-part.Position).Magnitude<=12
 end
 local function prop(name,pos,size,color,caption,action,hold)
  local part=Instance.new('Part');part.Name=name;part.Position=pos;part.Size=size;part.Color=color;part.Anchored=true;part.Parent=root
  if name=='Contract board' then
   local plaque=Station.part(root,'Contract board lettering',Vector3.new(4.75,2.3,.16),part.Position+Vector3.new(0,1,.43),Station.green)
   Station.sign(plaque,'SIDE CONTRACTS',Enum.NormalId.Back)
  end
  local q=Instance.new('ProximityPrompt');q.ActionText=action;q.ObjectText=name;q.HoldDuration=hold or .4;q.MaxActivationDistance=10;q.RequiresLineOfSight=false;q.Parent=part
  return part,q
 end
 local board,kiosk=prop('Contract board',Vector3.new(41,3,-70),Vector3.new(5,6,.7),Color3.fromRGB(255,127,77),'SIDE CONTRACTS\nSame 40-second whistle','Accept next job')
 local parcel,pp=prop('Contract parcel',Vector3.new(42,1,-84),Vector3.new(2,2,2),Color3.fromRGB(196,151,97),'PARCEL → CONDUCTOR','Pick up parcel')
 Station.part(root,'Parcel strap',Vector3.new(.24,.035,2),Vector3.new(42,2.02,-84),Station.cream)
 local passenger,rp=prop('Lost passenger',Vector3.new(-43,1.5,-84),Vector3.new(2,3,2),Color3.fromRGB(140,225,255),'LOST PASSENGER\nEscort to conductor','Begin escort')
 local lever,sp=prop('Signal lever',Vector3.new(47,1.5,-63),Vector3.new(.36,3,.36),Station.iron,'SIGNAL REPAIR','Repair signal',1)
 Station.part(root,'Signal handle',Vector3.new(.85,.27,.32),Vector3.new(47,2.85,-63),Color3.fromRGB(193,76,57))
 local deliver=Instance.new('ProximityPrompt');deliver.ActionText='Deliver parcel / passenger';deliver.ObjectText='Train conductor';deliver.HoldDuration=.4;deliver.MaxActivationDistance=10;deliver.RequiresLineOfSight=false;deliver.Parent=conductor
 local function action(p,event,part,id)
  if not valid(p,part)then return false end
  local a=active[p];local before=a and a.stage
  local paid=Contracts.act(a,event,workspace:GetAttribute('TrainStop'),id)
  if paid then
   clearVisual(p);pay(p,a.reward);remote:FireClient(p,'toast','CONTRACT PAID +$'..a.reward)
  elseif a and a.stage==1 and before==0 then
   clearVisual(p)
   local c=p.Character;local r=c and c:FindFirstChild('HumanoidRootPart')
   if r then local v=Instance.new('Part');v.Name='ContractCargo';v.Size=Vector3.new(1.5,1.5,1.5);v.Color=part.Color;v.CanCollide=false;v.Massless=true;v.CFrame=r.CFrame*CFrame.new(-2,1,0);v.Parent=c;local weld=Instance.new('WeldConstraint');weld.Part0=r;weld.Part1=v;weld.Parent=v;visuals[p]=v end
   remote:FireClient(p,'toast','Objective secured. Deliver to the blue conductor before departure!')
  end
  update(p);return paid
 end
 kiosk.Triggered:Connect(function(p)
  if not valid(p,board)then return end
  if active[p]then remote:FireClient(p,'toast','One contract per stop. Finish it before the whistle!');return end
  active[p]=Contracts.accept(indices[p],workspace:GetAttribute('TrainStop'));indices[p]=active[p].kind;update(p)
 end)
 pp.Triggered:Connect(function(p)action(p,'parcel',parcel)end)
 rp.Triggered:Connect(function(p)action(p,'passenger',passenger)end)
 sp.Triggered:Connect(function(p)action(p,'repair',lever)end)
 deliver.Triggered:Connect(function(p)action(p,'deliver',conductor)end)
 local api={}
 function api.caught(p,id,part)action(p,'caught',part,id)end
 function api.remove(p)clearVisual(p);active[p]=nil;indices[p]=nil end
 function api.cancel(p)clearVisual(p);active[p]=nil;update(p)end
 function api.depart()for p in active do api.cancel(p)end end
 api.update=update
 return api
end
return M
