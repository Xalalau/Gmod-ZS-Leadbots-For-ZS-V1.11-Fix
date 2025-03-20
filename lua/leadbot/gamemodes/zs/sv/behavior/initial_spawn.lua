-- Cache cvars
local leadbot_quota = GetConVar("leadbot_quota")
local leadbot_hordes = GetConVar("leadbot_hordes")
local leadbot_mapchanges = GetConVar("leadbot_mapchanges")

function LeadBot.InitialSpawn(bot)
    if leadbot_quota:GetInt() > 1 and leadbot_hordes:GetInt() < 1 then
        local mapName = game.GetMap()

        bot:SetMaxHealth(1000000)

        if leadbot_mapchanges:GetInt() >= 1 then 
            if mapName == "zs_buntshot" then 
                bot:SetPos( Vector(550.256470 + math.random(-25, 25), -595.521240 + math.random(-25, 25), -203.968750) )
            elseif mapName == "zs_snow" then 
                bot:SetPos( Vector(-154.754593 + math.random(-25, 25), 1325.260010 + math.random(-25, 25), -571.968750) )
            end
        end 
    end
end