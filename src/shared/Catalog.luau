-- rate is dollars/second when banked; sizes are studs; eyes/eyeSize shape the face; style selects trim.
local function creature(name, rarity, rate, colour, body, head, eyes, eyeSize, style)
	assert(rate > 0 and eyes >= 1, "Catalog entries need positive income and visible eyes")
	return {name=name, rarity=rarity, rate=rate, colour=colour, body=body, head=head, eyes=eyes, eyeSize=eyeSize, style=style}
end
return {
	creature("Skibidi Toilet", "Common", 2, "D9EEF2", Vector3.new(2.2,2,2), Vector3.new(1.5,1.4,1.5), 2, .38, "rim"),
	creature("Ohio Rat", "Common", 3, "A89AB8", Vector3.new(2,1.3,2.5), Vector3.new(1.5,1.3,1.6), 2, .34, "ears"),
	creature("Sigma Toilet", "Uncommon", 5, "64DCC6", Vector3.new(2.2,2.2,2), Vector3.new(1.7,1.5,1.6), 2, .4, "hat"),
	creature("Grimace Goon", "Uncommon", 8, "AA70E8", Vector3.new(2.7,2.5,2.2), Vector3.new(2,1.7,1.8), 3, .38, "crest"),
	creature("Bombardiro Crocodilo", "Rare", 13, "6DAF79", Vector3.new(3,1.5,3), Vector3.new(2,1.4,2.8), 2, .45, "wings"),
	creature("Tralalero Tralala", "Rare", 21, "66BEFF", Vector3.new(2.6,2,2.5), Vector3.new(2,1.8,2), 3, .38, "crest"),
	creature("Tung Tung Sahur", "Epic", 34, "C78A50", Vector3.new(1.8,3,1.8), Vector3.new(1.9,1.8,1.8), 2, .5, "hat"),
	creature("Ballerina Cappuccina", "Epic", 55, "F6A6C9", Vector3.new(2,2.4,2), Vector3.new(2,1.7,2), 2, .42, "rim"),
	creature("La Vacca Saturno", "Legendary", 89, "F6C95D", Vector3.new(3,2.4,2.6), Vector3.new(2.2,1.9,2), 4, .36, "ears"),
	creature("Carmine Gorillo", "Mythic", 144, "F16D77", Vector3.new(3.2,3,2.5), Vector3.new(2.3,2,2.2), 2, .55, "hat"),
}
