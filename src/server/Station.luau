local Station = {}
local TICK_SECONDS = 0.5
local IMMINENT_SECONDS = 10
local WAVE_SECONDS, DEPARTURE_SECONDS = 45,90
function Station.start(economy,world,push)
	Station.waveAt = workspace:GetServerTimeNow()+WAVE_SECONDS
	Station.departureAt = workspace:GetServerTimeNow()+DEPARTURE_SECONDS
	task.spawn(function()
		while task.wait(TICK_SECONDS) do
			local now = workspace:GetServerTimeNow()
			if now >= Station.waveAt then
				Station.waveAt = now+WAVE_SECONDS
				for p,s in economy.states do
					if not world.onTrain(p) and #s.carried>0 then
						for _,item in s.carried do item.model:Destroy() end
						s.carried={} s.message="WAVE! Your loose cargo was swept away. Banked cargo is safe."
					end
				end
				local wave = Instance.new("Part")
				wave.Name,wave.Size,wave.Position = "SkyWave",Vector3.new(94,5,2),Vector3.new(0,2,-24)
				wave.Anchored,wave.CanCollide,wave.Material,wave.Transparency = true,false,Enum.Material.Neon,.45
				wave.Color,wave.Parent = Color3.fromRGB(70,200,255),workspace
				game:GetService("TweenService"):Create(wave,TweenInfo.new(2),{Position=Vector3.new(0,2,24)}):Play()
				game:GetService("Debris"):AddItem(wave,2)
			end
			if now >= Station.departureAt then
				Station.departureAt=now+DEPARTURE_SECONDS
				for p,s in economy.states do
					if world.onTrain(p) then s.cash.Value+=economy.rate(s)*10 s.message="ALL ABOARD! 10-second income bonus."
					else s.message="Express departed! Be aboard next time for a cash bonus." end
				end
			end
			Station.imminent = math.min(Station.waveAt-now,Station.departureAt-now)<=IMMINENT_SECONDS
			for p in economy.states do push(p) end
		end
	end)
end
return Station
