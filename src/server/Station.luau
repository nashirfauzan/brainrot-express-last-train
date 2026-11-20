local TweenService=game:GetService("TweenService")
local Station={waveAt=0,departureAt=0,imminent=false}
function Station.start(economy,world,push)
	-- Absolute server-clock deadlines avoid per-client drift: waves 45s, departures 90s, warning 10s.
	local now=workspace:GetServerTimeNow()
	Station.waveAt,Station.departureAt=now+45,now+90
	task.spawn(function()
		while task.wait(.2) do
			now=workspace:GetServerTimeNow()
			local imminent=math.min(Station.waveAt,Station.departureAt)-now<=10
			if imminent and not Station.imminent then
				for player,state in economy.states do state.message="Ten seconds! Bank cargo or board the Express." push(player) end
			end
			Station.imminent=imminent
			world.board.Text=string.format("NEXT EXPRESS  %02ds\nWAVE IN %02ds",math.max(0,math.ceil(Station.departureAt-now)),math.max(0,math.ceil(Station.waveAt-now)))
			if now>=Station.waveAt then
				Station.waveAt+=45
				for player,state in economy.states do
					if not world.onTrain(player) then
						for _,item in state.carried do item.model:Destroy() end
						state.carried={}
						state.message="Sky wave! Unbanked cargo lost. Your collection is safe."
					else state.message="Train shelter protected your cargo!" end
					push(player)
				end
				local wave=Instance.new("Part")
				wave.Name,wave.Size,wave.Position="SkyWave",Vector3.new(3,18,76),Vector3.new(-75,8,0)
				wave.Anchored,wave.CanCollide,wave.Transparency=true,false,.55
				wave.Color,wave.Material=Color3.fromRGB(114,190,255),Enum.Material.Neon
				wave.Parent=workspace
				TweenService:Create(wave,TweenInfo.new(3,Enum.EasingStyle.Linear),{Position=Vector3.new(75,8,0)}):Play()
				game:GetService("Debris"):AddItem(wave,3.1)
			end
			if now>=Station.departureAt then
				Station.departureAt+=90
				for player,state in economy.states do
					if world.onTrain(player) then state.bonusUntil=now+10 state.message="ALL ABOARD! Double banked income for ten seconds."
					else state.message="You missed the Express! Next train in 90 seconds." end
					push(player)
				end
				-- Carry riders with the departing train, then return it for the next service.
				local riders={}
				for player in economy.states do if world.onTrain(player) then table.insert(riders,player) end end
				local home=world.train:GetPivot()
				local driver=Instance.new("CFrameValue") driver.Value=home
				local previous=home
				local connection=driver.Changed:Connect(function(cf)
					local delta=cf*previous:Inverse()
					world.train:PivotTo(cf)
					for _,player in riders do
						if player.Character then player.Character:PivotTo(delta*player.Character:GetPivot()) end
					end
					previous=cf
				end)
				TweenService:Create(driver,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{Value=home*CFrame.new(150,0,0)}):Play()
				task.delay(6.1,function() connection:Disconnect() driver:Destroy() world.train:PivotTo(home) end)
				for _,p in world.train:GetChildren() do
					if p.Name=="Roof" then
						p.Material=Enum.Material.Neon
						task.delay(10,function() if p.Parent then p.Material=Enum.Material.Metal end end)
					end
				end
			end
		end
	end)
end
return Station
