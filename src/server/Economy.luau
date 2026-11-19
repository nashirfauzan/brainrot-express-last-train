local Catalog = require(game.ReplicatedStorage.Shared.Catalog)
local Economy = {}
local INCOME_TICK_SECONDS = 1
function Economy.new(player)
    local stats = Instance.new("Folder",player)
    stats.Name = "leaderstats"
    local cash = Instance.new("IntValue",stats)
    cash.Name, cash.Value = "Cash",0
    return {cash=cash, bag={}, bank={}, capacity=1, speed=16, multiplier=1}
end
function Economy.income(s)
    local total = 0
    for _, index in s.bank do total += Catalog[index][3] end
    return total * s.multiplier
end
function Economy.prices(s)
    return {bag=35*s.capacity, boots=55*(1+(s.speed-16)/4), rebirth=500*s.multiplier}
end
function Economy.buy(s, action)
    local cost = Economy.prices(s)[action]
    if not cost or s.cash.Value < cost then return false,"Not enough cash" end
    if action == "bag" and s.capacity >= 6 then return false,"Bag maxed" end
    if action == "boots" and s.speed >= 40 then return false,"Boots maxed" end
    s.cash.Value -= cost
    if action == "bag" then s.capacity += 1
    elseif action == "boots" then s.speed += 4
    else
        table.clear(s.bank)
        s.multiplier += 1
        s.cash.Value = 0
    end
    return true
end
function Economy.run(states, push)
    task.spawn(function()
        while task.wait(INCOME_TICK_SECONDS) do
            for player,s in states do
                s.cash.Value += Economy.income(s)
                push(player)
            end
        end
    end)
end
return Economy
