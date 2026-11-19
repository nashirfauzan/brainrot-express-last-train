local function creature(name, rarity, rate, color, body, head, eyes, eyeSize, style)
	return {name = name, rarity = rarity, rate = rate, color = Color3.fromHex(color), body = body,
		head = head, eyes = eyes, eyeSize = eyeSize, style = style}
end
local v = Vector3.new
return {
	creature("Skibidi Toilet", "Common", 1, "ceeaff", v(2.1,1.6,2.4), v(1.3,1.45,1.3), 2,.33,"bowl"),
	creature("Ohio Rat", "Common", 2, "ad93ca", v(1.45,1.1,2.5), v(1.5,1.2,1.55), 2,.44,"ears"),
	creature("Sigma Toilet", "Uncommon", 3, "57ebc1", v(2,2,2), v(1.7,1.5,1.5), 1,.62,"visor"),
	creature("Grimace Goon", "Rare", 8, "984cff", v(2.7,2.2,2), v(2.15,1.8,1.7), 3,.45,"crest"),
	creature("Bombardiro Crocodilo", "Epic", 15, "88cf62", v(1.6,1.2,3.1), v(1.8,1.05,2.3), 2,.35,"wings"),
	creature("Tralalero Tralala", "Epic", 18, "34c9f6", v(1.6,1.55,2.8), v(1.9,1.3,1.8), 3,.25,"fin"),
	creature("Tung Tung Sahur", "Legendary", 30, "e19552", v(1.45,2.5,1.3), v(1.35,1.35,1.3), 2,.54,"cap"),
	creature("Ballerina Cappuccina", "Legendary", 40, "ffa4cd", v(2.55,.85,2.55), v(1.6,1.65,1.6), 2,.31,"cup"),
	creature("La Vacca Saturno", "Mythic", 60, "ffc659", v(2.4,1.35,2.45), v(1.45,1.4,1.5), 1,.78,"orbit"),
	creature("Carmine Gorillo", "Mythic", 75, "f85366", v(2.95,2.35,1.8), v(1.85,1.25,1.55), 4,.28,"crown"),
}
