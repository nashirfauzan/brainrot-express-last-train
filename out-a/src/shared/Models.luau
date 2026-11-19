local Models = {}
function Models.build(d)
	local m = Instance.new("Model")
	m.Name = d.name
	local function part(name, size, pos, color, ball)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position, p.Color = name, size, pos, color
		p.Anchored, p.CanCollide, p.Massless = true, false, true
		p.Material = Enum.Material.SmoothPlastic
		if ball then p.Shape = Enum.PartType.Ball end
		p.Parent = m
		return p
	end
	local b = part("Body", d.body, Vector3.new(0,d.body.Y/2,0), d.color, true)
	m.PrimaryPart = b
	b.PivotOffset = CFrame.new(0,-d.body.Y/2,0)
	local y = d.body.Y + d.head.Y/2 - .15
	part("Head", d.head, Vector3.new(0,y,-.25),d.color:Lerp(Color3.new(1,1,1),.2),true)
	for i=1,d.eyes do
		local x = (i-(d.eyes+1)/2)*d.eyeSize*1.5
		part("Eye",Vector3.new(d.eyeSize,d.eyeSize,d.eyeSize),Vector3.new(x,y+.1,-.25-d.head.Z/2),Color3.new(1,1,1),true)
		part("Pupil",Vector3.new(d.eyeSize*.48,d.eyeSize*.6,.12),Vector3.new(x,y+.1,-.3-d.head.Z/2-d.eyeSize/2),Color3.fromRGB(18,24,46),true)
	end
	local hat = part("Hat",Vector3.new(d.head.X+ .35,.35,d.head.Z+.35),Vector3.new(0,y+d.head.Y/2, -.25),Color3.fromRGB(27,33,62))
	if d.style == "ears" or d.style == "crown" then
		for _,x in {-1,1} do part("Ear",Vector3.new(.7,1,.5),Vector3.new(x*.9,y+.6,0),d.color,true) end
	elseif d.style == "wings" or d.style == "orbit" then
		part("Wings",Vector3.new(4.7,.22,1),Vector3.new(0,1,0),Color3.fromRGB(255,211,78))
	elseif d.style == "cup" or d.style == "bowl" then
		part("Rim",Vector3.new(d.body.X+.4,.25,d.body.Z+.4),Vector3.new(0,d.body.Y-.1,0),Color3.new(1,1,1))
	else
		hat.Size = Vector3.new(.65,.9,.65)
	end
	for _,p in m:GetChildren() do
		if p:IsA("BasePart") and p ~= b then
			local weld = Instance.new("WeldConstraint")
			weld.Part0, weld.Part1, weld.Parent = b,p,b
		end
	end
	local gui = Instance.new("BillboardGui")
	gui.Size, gui.StudsOffset, gui.AlwaysOnTop = UDim2.fromOffset(180,46),Vector3.new(0,d.body.Y+d.head.Y+1,0),false
	gui.Parent = b
	local t = Instance.new("TextLabel")
	t.Size,t.BackgroundTransparency,t.TextColor3 = UDim2.fromScale(1,1),1,Color3.new(1,1,1)
	t.TextStrokeTransparency,t.Font,t.TextSize = .25,Enum.Font.GothamBold,13
	t.Text = d.name.."\n"..d.rarity.."  /  $"..d.rate.."/s"
	t.Parent = gui
	return m
end
return Models
