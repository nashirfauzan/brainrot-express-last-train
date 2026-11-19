-- Species IDs are positional; keep the name, rarity, income and flavor tuple stable.
local C = {items={
 {"Kulkasaurus","Common",5,"Fridge dinosaur"},{"Bebek Jetpack","Common",6,"Rocket duck"},{"Sate Satelit","Common",7,"Orbital skewer"},{"Capybara Kondektur","Common",8,"Tiny ticket inspector"},
 {"Roti Komodo","Uncommon",13,"Bread lizard"},{"Bakso UFO","Uncommon",15,"Flying meatball"},{"Pisang Beroda","Uncommon",17,"Wheelie banana"},{"Gurita WiFi","Uncommon",19,"Router octopus"},
 {"Ayam Kronos","Rare",31,"Alarm-clock rooster"},{"Naga Laundry","Rare",36,"Laundry dragon"},
 {"Sultan Sendal","Epic",72,"Royal slipper"},{"Megakucing Mie","Epic",95,"Noodle-cat titan"}},
 names={Common=Color3.fromRGB(180,229,255),Uncommon=Color3.fromRGB(108,255,170),Rare=Color3.fromRGB(255,205,76),Epic=Color3.fromRGB(255,104,218)}}
function C.get(id) return C.items[id] end
return C
