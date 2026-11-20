local Economy={states={}}
function Economy.add(player)
	local state={cash=0,banked={},carried={},capacity=1,speed=16,rebirth=0,message="Catch with E. Bank with F. Board before the wave!",bonusUntil=0}
	Economy.states[player]=state
	return state
end
function Economy.rate(state)
	local income=0
	for _,item in state.banked do income+=item.entry.rate end
	return income*(state.rebirth+1)
end
function Economy.costs(state)
	return {bag=100*state.capacity^2,boots=150*2^((state.speed-16)/4),rebirth=2500*(state.rebirth+1)^2}
end
function Economy.apply(player)
	local state=Economy.states[player]
	local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if state and hum then hum.WalkSpeed=state.speed end
end
function Economy.buy(player,action)
	if typeof(action)~="string" then return end
	local state=Economy.states[player]
	if not state then return end
	local price=Economy.costs(state)[action]
	if not price then return end
	if action=="boots" and state.speed>=40 then state.message="Boots already at maximum speed." return end
	if state.cash<price then state.message="Not enough cash. Bank more creatures!" return end
	state.cash-=price
	if action=="bag" then state.capacity+=1
	elseif action=="boots" then state.speed+=4 Economy.apply(player)
	elseif action=="rebirth" then
		for _,item in state.banked do item.model:Destroy() end
		for _,item in state.carried do item.model:Destroy() end
		state.banked={} state.carried={} state.rebirth+=1
	end
	state.message="Purchased "..action.."!"
end
function Economy.start(push)
	task.spawn(function()
		while task.wait(1) do
			for player,state in Economy.states do
				local bonus=workspace:GetServerTimeNow()<state.bonusUntil and 2 or 1
				state.cash+=Economy.rate(state)*bonus
				push(player)
			end
		end
	end)
end
return Economy
