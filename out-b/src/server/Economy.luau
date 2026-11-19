local Economy = {states = {}}
local INCOME_TICK_SECONDS = 1
function Economy.add(player)
	local stats = Instance.new("Folder")
	stats.Name,stats.Parent = "leaderstats",player
	local cash = Instance.new("IntValue")
	cash.Name,cash.Value,cash.Parent = "Cash",0,stats
	local s = {cash=cash,banked={},carried={},capacity=1,speed=16,rebirths=0,message="Catch a creature at the market!"}
	Economy.states[player] = s
	return s
end
function Economy.rate(s)
	local rate = 0
	for _,item in s.banked do rate += item.data.rate end
	return rate * (1+s.rebirths)
end
function Economy.costs(s)
	return {bag=25*s.capacity*s.capacity,boots=40+20*(s.speed-16),rebirth=1000*(s.rebirths+1)}
end
function Economy.apply(player)
	local s = Economy.states[player]
	local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if s and h then h.WalkSpeed = s.speed end
end
function Economy.buy(player,action)
	local s = Economy.states[player]
	if not s then return end
	local cost = Economy.costs(s)[action]
	if not cost or s.cash.Value < cost then s.message="Not enough cash" return end
	s.cash.Value -= cost
	if action=="bag" then s.capacity+=1
	elseif action=="boots" then s.speed=math.min(s.speed+4,48)
	elseif action=="rebirth" then
		for _,list in {s.banked,s.carried} do for _,item in list do item.model:Destroy() end end
		s.banked,s.carried,s.rebirths = {},{},s.rebirths+1
	end
	Economy.apply(player)
	s.message="Upgrade purchased!"
end
function Economy.start(push)
	task.spawn(function()
		while task.wait(INCOME_TICK_SECONDS) do
			for player,s in Economy.states do s.cash.Value += Economy.rate(s) push(player) end
		end
	end)
end
return Economy
