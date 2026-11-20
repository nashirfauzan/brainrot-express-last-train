local Models = {}
function Models.build(entry)
	local model = Instance.new("Model")
	model.Name = entry.name
	local colour = Color3.fromHex(entry.colour)
	local function piece(name, size, position, tint, ball)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position, p.Color = name, size, position, tint
		p.Anchored, p.CanCollide = true, false
		p.CastShadow = name ~= "Eye" and name ~= "Pupil"
		p.Material = Enum.Material.SmoothPlastic
		if ball then p.Shape = Enum.PartType.Ball end
		p.Parent = model
		return p
	end
	-- Body rests on y=0; head and trim scale with catalog dimensions, not world coordinates.
	local body = piece("Body", entry.body, Vector3.new(0,entry.body.Y/2,0), colour, true)
	local h = entry.body.Y + entry.head.Y/2
	piece("Head", entry.head, Vector3.new(0,h,0), colour, true)
	for i=1,entry.eyes do
		local x = (i-(entry.eyes+1)/2)*entry.eyeSize*1.25
		piece("Eye", Vector3.one*entry.eyeSize, Vector3.new(x,h,-entry.head.Z*.46), Color3.new(1,1,1), true)
		piece("Pupil", Vector3.one*entry.eyeSize*.48, Vector3.new(x,h,-entry.head.Z*.46-entry.eyeSize*.4), Color3.fromRGB(20,25,45), true)
	end
	local top = h+entry.head.Y/2
	if entry.style == "ears" then
		for _,side in {-1,1} do piece("Ear",Vector3.new(.8,1,.45),Vector3.new(side*entry.head.X*.48,top,0),colour,true) end
	elseif entry.style == "wings" then
		for _,side in {-1,1} do piece("Wing",Vector3.new(2.8,.25,1.5),Vector3.new(side*2,entry.body.Y*.65,0),Color3.fromRGB(225,238,245)) end
	elseif entry.style == "rim" then
		for _,side in {-1,1} do
			piece("CupRim",Vector3.new(.18,.3,entry.head.Z+ .4),Vector3.new(side*(entry.head.X/2+.1),top,0),Color3.new(1,1,1))
			piece("CupRim",Vector3.new(entry.head.X+.4,.3,.18),Vector3.new(0,top,side*(entry.head.Z/2+.1)),Color3.new(1,1,1))
		end
	elseif entry.style == "crest" then
		for i=1,3 do piece("Crest",Vector3.new(.3,.7,.5),Vector3.new(0,top+.2,(i-2)*.6),Color3.fromRGB(255,213,90)) end
	else
		piece("HatBrim",Vector3.new(entry.head.X+ .6,.18,entry.head.Z+.5),Vector3.new(0,top,0),Color3.fromRGB(32,38,65))
		piece("Hat",Vector3.new(1.2,.8,1.2),Vector3.new(0,top+.45,0),Color3.fromRGB(43,55,86))
	end
	local gui = Instance.new("BillboardGui")
	gui.Size, gui.StudsOffset, gui.AlwaysOnTop = UDim2.fromOffset(220,64), Vector3.new(0,top+1.4-body.Position.Y,0), true
	gui.MaxDistance = 75
	gui.Parent = body
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency = UDim2.fromScale(1,1), 1
	label.Font, label.TextSize = Enum.Font.GothamBold, 14
	label.TextColor3, label.TextStrokeTransparency = Color3.new(1,1,1), .3
	label.Text = entry.name.."\n"..entry.rarity.."  /  $"..entry.rate.." per sec"
	label.Parent = gui
	model.PrimaryPart = body
	-- Offset the primary pivot down to the feet so shelf placement needs no size-specific correction.
	body.PivotOffset = CFrame.new(0,-entry.body.Y/2,0)
	return model
end
return Models
