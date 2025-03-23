-- Cache cvars
local leadbot_hordes = GetConVar("leadbot_hordes")
local leadbot_cs = GetConVar("leadbot_cs")
local leadbot_quota = GetConVar("leadbot_quota")
local leadbot_minzombies = GetConVar("leadbot_minzombies")

function LeadBot.Tick()
    local totalPlayers = player.GetCount()
    local minimumZombies = math.ceil(totalPlayers * (leadbot_minzombies:GetInt() * 0.01))
    local reedeemPlayers = ZSB.INTERMISSION == 1 and leadbot_hordes:GetInt() >= 1 and leadbot_quota:GetInt() < 2
    local CSMode = leadbot_cs:GetBool()
    local totalZombies = team.NumPlayers(TEAM_ZOMBIE)

    local toZombies = 0
    for k, plyOrBot in ipairs(player.GetAll()) do
        if CSMode then
            if plyOrBot:Team() == TEAM_ZOMBIE then
                ZSB.playerCSSpeed = ZSB.playerCSSpeed + 10

                if plyOrBot:Health() ~= 1000 then 
                    GAMEMODE:SetPlayerSpeed(plyOrBot, math.min(ZSB.playerCSSpeed, 200))
                else
                    GAMEMODE:SetPlayerSpeed(plyOrBot, 200)
                end

                if plyOrBot:GetZombieClass() ~= 1 then 
                    plyOrBot:Kill()
                    plyOrBot:SetZombieClass(1)
                end
            else
                if plyOrBot:Health() > 30 then 
                    plyOrBot:SetMaxHealth(30)
                    plyOrBot:SetHealth(30)
                end
            end
        end

        if plyOrBot:IsLBot() then
            local bot = plyOrBot

            -- bot:SetNoCollideWithTeammates(false)

            if bot:Team() == TEAM_SURVIVORS and totalPlayers >= leadbot_quota:GetInt() then
                if minimumZombies > totalZombies + toZombies then
                    bot:Kill()
                    toZombies = toZombies + 1
                end
            end

            if LeadBot.RespawnAllowed and bot.NextSpawnTime and not bot:Alive() and bot.NextSpawnTime < CurTime() then
                bot:Spawn()
                return
            end
        else
            local ply = plyOrBot

            if reedeemPlayers and ply:Team() == TEAM_ZOMBIE then 
                ply:Redeem()
            end
        end
    end

    if totalZombies >= 1 and totalZombies < totalPlayers then 
        ZSB.INTERMISSION = 0
    end
end