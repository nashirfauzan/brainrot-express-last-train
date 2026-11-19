-- Keep carry, bank and upgrade accounting independent of Roblox instances.
local E = {}
function E.new()
 return {cash=0, carry={}, bank={}, Bag=0, Boots=0, Racks=0, rebirth=0}
end
function E.catch(s, item)
 if #s.carry >= 1+s.Bag then return false end
 table.insert(s.carry,item)
 return true
end
function E.bank(s)
 local n=0
 while #s.carry>0 and #s.bank<3+s.Racks do
  table.insert(s.bank,table.remove(s.carry,1))
  n+=1
 end
 return n
end
function E.rate(s)
 local n=0
 for _,item in s.bank do n+=item.rate end
 return math.floor(n*(1+s.rebirth*.5))
end
function E.tick(s)
 local n=E.rate(s)
 s.cash=math.min(1e12,s.cash+n)
 return n
end
function E.depart(s)
 local n=#s.carry
 table.clear(s.carry)
 return n
end
function E.upgrade(s, name)
 if name~='Bag' and name~='Boots' and name~='Racks' then return false,0 end
 local level=s[name];local price=math.floor(80*2.3^level)
 if level>=4 or s.cash<price then return false,price end
 s.cash-=price;s[name]+=1;return true,price
end
function E.rebirth(s)
 local price=math.floor(1500*3^s.rebirth)
 if s.rebirth>=20 or s.cash<price or #s.bank<3 then return false,price end
 s.cash=0;s.bank={};s.carry={};s.Bag=0;s.Boots=0;s.Racks=0;s.rebirth+=1;return true,price
end
return E
