local Players=game:GetService('Players')
local Rep=game:GetService('ReplicatedStorage')
local UIS=game:GetService('UserInputService')
local player=Players.LocalPlayer;local remote=Rep:WaitForChild('ExpressEvent')
local gui=Instance.new('ScreenGui');gui.Name='ExpressHUD';gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild('PlayerGui')
local function text(name,pos,size,value,color,n)
 local t=Instance.new('TextLabel');t.Name=name;t.Position=pos;t.Size=size;t.BackgroundColor3=Color3.fromRGB(23,44,38);t.BackgroundTransparency=.16;t.BorderSizePixel=0;t.TextColor3=color or Color3.new(1,1,1);t.TextStrokeTransparency=.7;t.Font=Enum.Font.GothamBold;t.TextSize=n or 16;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextWrapped=true;t.Text=value;t.Parent=gui;local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,12);c.Parent=t;return t
end
local title=text('Title',UDim2.new(.25,0,0,5),UDim2.new(.5,0,0,29),'BRAINROT EXPRESS  /  LAST TRAIN HOME',Color3.fromRGB(255,227,135),20);title.TextXAlignment=Enum.TextXAlignment.Center
local stats=text('Stats',UDim2.new(.02,0,0,78),UDim2.new(.24,0,0,45),'$0    Bag 0/1\n$0 / sec    0',Color3.fromRGB(222,250,255),16)
local clock=text('Whistle',UDim2.new(.36,0,0,38),UDim2.new(.28,0,0,29),'STOP • 40s to whistle',Color3.fromRGB(183,255,202),17);clock.TextXAlignment=Enum.TextXAlignment.Center
local mission=text('Contract',UDim2.new(.73,0,0,10),UDim2.new(.25,0,0,56),'No contract\nVisit the orange job board',Color3.fromRGB(255,220,147),14)
stats.TextXAlignment=Enum.TextXAlignment.Center
local help=text('Guide',UDim2.new(.02,0,1,-77),UDim2.new(.54,0,0,58),'Catch a brainrot • return to train • press E at a podium\nBanked friends earn every second. Beat the whistle!',Color3.fromRGB(223,247,255),14)
local toast=text('Feedback',UDim2.new(.24,0,.77,0),UDim2.new(.52,0,0,64),'',Color3.fromRGB(255,244,205),17);toast.TextXAlignment=Enum.TextXAlignment.Center;toast.Visible=false
local buttons={}
local function chip(caption,x,action,arg,w)local b=Instance.new('TextButton');b.Size=UDim2.new(w,0,0,46);b.Position=UDim2.new(x,0,1,-49);b.BackgroundColor3=Color3.fromRGB(38,77,63);b.TextColor3=Color3.fromRGB(239,255,250);b.Font=Enum.Font.GothamBold;b.TextSize=12;b.TextWrapped=true;b.Text=caption;b.Parent=gui;local r=Instance.new('UICorner');r.CornerRadius=UDim.new(0,9);r.Parent=b;b.Activated:Connect(function()remote:FireServer(action,arg)end);if arg then buttons[arg]=b end;return b end
chip('1 BAG',.02,'upgrade','Bag',.16);chip('2 BOOTS',.19,'upgrade','Boots',.16);chip('3 RACKS',.36,'upgrade','Racks',.16)
chip('SHIFT / SPRINT',.53,'sprint',nil,.19);local rebirth=chip('R / REBIRTH',.73,'rebirth',nil,.25)
help.Text='E / tap prompt: catch & deposit at YOUR wagon • SHIFT: sprint\n40 seconds per stop. Board any train deck before departure!'
help.Text='Catch → board your wagon → deposit'
help.Size=UDim2.new(.56,0,0,26);help.Position=UDim2.new(.22,0,1,-80);help.TextXAlignment=Enum.TextXAlignment.Center
task.delay(12,function()help.Visible=false end)
local function update()
 local g=function(k,d)return player:GetAttribute(k)or d end
 stats.Text=string.format('$%d    Bag %d/%d\n$%d / sec ',g('Cash',0),g('CarryCount',0),g('CarryCap',1),g('Income',0))
 for name,b in buttons do local price=g(name..'Price',80);b.Text=name..' Lv'..g(name,0)..' • '..(price==0 and 'MAX' or '$'..price)end
 rebirth.Text='REBIRTH $'..g('RebirthPrice',1500)..'\n3 banked • +50% income'
 local t=workspace:GetAttribute('Countdown')or 40;local phase=workspace:GetAttribute('Phase')or'STOP';clock.Text=phase=='WHISTLE'and'WHISTLE · BOARD NOW'or phase=='MOVING'and'EN ROUTE' or 'DEPARTS IN '..t..'s';clock.TextColor3=t<=10 and Color3.fromRGB(255,114,112)or Color3.fromRGB(183,255,202)
 mission.Visible=g('MissionReward','$350–650')~='$350–650'
 mission.Text=''..g('MissionTitle','No contract — visit the kiosk')..'\n'..g('MissionProgress','Optional')..'   '..g('MissionReward','Reward: $250')
end
for _,a in {'Cash','CarryCount','CarryCap','Income','Rebirth','MissionTitle','MissionProgress','MissionReward','Bag','Boots','Racks','BagPrice','BootsPrice','RacksPrice','RebirthPrice'}do player:GetAttributeChangedSignal(a):Connect(update)end
workspace:GetAttributeChangedSignal('Countdown'):Connect(update)
remote.OnClientEvent:Connect(function(kind,msg)if kind=='toast'then toast.Text=msg;toast.Visible=true;task.delay(3,function()if toast.Text==msg then toast.Visible=false end end)elseif kind=='cycle'then workspace:SetAttribute('Phase',msg);update()end end)
UIS.InputBegan:Connect(function(i,p)if p then return end;if i.KeyCode==Enum.KeyCode.One then remote:FireServer('upgrade','Bag')elseif i.KeyCode==Enum.KeyCode.Two then remote:FireServer('upgrade','Boots')elseif i.KeyCode==Enum.KeyCode.Three then remote:FireServer('upgrade','Racks')elseif i.KeyCode==Enum.KeyCode.R then remote:FireServer('rebirth')elseif i.KeyCode==Enum.KeyCode.LeftShift then remote:FireServer('sprint')end end)
update()
