local Catalog = require(script.Parent.Catalog)
local Models = {}

function Models.create(index, scale)
    local row = Catalog[index]
    local name, _, _, coat, torso, head, eyes, eyeSize = table.unpack(row)
    scale = scale or 1
    local model = Instance.new("Model")
    model.Name = name
    local body
    local function piece(label, size, pos, color, shape)
        local p = Instance.new("Part")
        p.Name, p.Size, p.Position, p.Color = label, size * scale, pos * scale, color
        p.Shape = shape or Enum.PartType.Block
        p.CanCollide, p.CanTouch, p.CanQuery, p.Massless = false, false, false, true
        p.Parent = model
        if body then
            local weld = Instance.new("WeldConstraint")
            weld.Part0, weld.Part1, weld.Parent = body, p, p
        end
        return p
    end
    local V = Vector3.new
    body = piece("Body", torso, V(0,torso.Y/2,0), coat, index % 2 == 0 and Enum.PartType.Ball or nil)
    body.Anchored = true
    body.PivotOffset = CFrame.new(0,-body.Size.Y/2,0)
    model.PrimaryPart = body
    local y = torso.Y + head.Y * .36
    piece("Head", head, V(0,y,-.18), coat:Lerp(Color3.new(1,1,1),.24), Enum.PartType.Ball)
    for i = 1, eyes do
        local x = (i - (eyes + 1)/2) * head.X / (eyes + .8)
        piece("Eye", V(1,1,.52)*eyeSize, V(x,y,-head.Z*.43-.21), Color3.new(1,1,1), Enum.PartType.Ball)
        piece("Pupil", V(.55,.68,.3)*eyeSize, V(x,y,-head.Z*.43-.21-eyeSize*.24), Color3.fromHex("192036"), Enum.PartType.Ball)
    end
    piece("Hat", V(head.X*.8,.24,head.Z*.8), V(0,y+head.Y*.46,-.18), coat:Lerp(Color3.fromHex("161A33"),.55))
    for _, side in {-1,1} do
        piece("Boot", V(torso.X*.38,.28,torso.Z*.55), V(side*torso.X*.26,.15,-torso.Z*.2), Color3.fromHex("25314A"))
    end
    return model
end
return Models
