local Station = {}
local TICK_SECONDS = 0.5
local IMMINENT_SECONDS = 10
local WAVE_PERIOD, DEPARTURE_PERIOD = 38, 90
function Station.onTrain(root)
    if not root then return false end
    local p = root.Position
    return math.abs(p.X) < 34 and p.Z <= -20.5 and p.Z >= -30 and p.Y >= 19.8 and p.Y <= 32
end
function Station.run(onWave,onDeparture)
    local now = workspace:GetServerTimeNow()
    local clock = {wave=now+WAVE_PERIOD, depart=now+DEPARTURE_PERIOD, period=DEPARTURE_PERIOD, imminent=IMMINENT_SECONDS}
    task.spawn(function()
        while task.wait(TICK_SECONDS) do
            local t = workspace:GetServerTimeNow()
            if t >= clock.wave then
                clock.wave += WAVE_PERIOD
                onWave()
            end
            if t >= clock.depart then
                clock.depart += DEPARTURE_PERIOD
                onDeparture()
            end
        end
    end)
    return clock
end
return Station
