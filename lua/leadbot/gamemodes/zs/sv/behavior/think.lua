-- Cache cvars
local leadbot_hinfammo = GetConVar("leadbot_hinfammo")
local leadbot_hordes = GetConVar("leadbot_hordes")
local leadbot_cs = GetConVar("leadbot_cs")
local leadbot_quota = GetConVar("leadbot_quota")
local leadbot_minzombies = GetConVar("leadbot_minzombies")

-- Credit goes out to 女儿 for this infinite ammo code :D --

local n = 1

local function InfiniteAmmoForSurvivorBots()
    if leadbot_hinfammo:GetInt() < 1 then 
        n = 2
    else
        n = 1
    end
    if n > 0 then
        for k,v in ipairs (player.GetBots()) do
            weapon = v:GetActiveWeapon()
            if IsValid(weapon) and v:Team() == TEAM_SURVIVORS then
                local maxClip = weapon:GetMaxClip1()
                local maxClip2 = weapon:GetMaxClip2()
                local primAmmoType = weapon:GetPrimaryAmmoType()
                local secAmmoType = weapon:GetSecondaryAmmoType()
                if n == 1 then
                    if maxClip >= 0 then weapon:SetClip1(maxClip) end
                    if maxClip2 >= 0 then weapon:SetClip2(maxClip2) end
                end
                if primAmmoType ~= -1 then
                    v:SetAmmo( maxClip, primAmmoType)
                end
                if secAmmoType ~= -1 and secAmmoType ~= primAmmoType then
                    v:SetAmmo( maxClip2, secAmmoType)
                end
            end
        end
    end
end

function LeadBot.Think()
    if ZSB.INTERMISSION == 1 and leadbot_hordes:GetInt() >= 1 and leadbot_quota:GetInt() < 2 then 
        for k, v in ipairs(player.GetHumans()) do
            if v:Team() == TEAM_ZOMBIE then 
                v:Redeem()
            end
        end
    end

    if leadbot_cs:GetInt() >= 1 then 
        for k, v in ipairs(player.GetAll()) do
            if v:Team() == TEAM_ZOMBIE then
                ZSB.playerCSSpeed = ZSB.playerCSSpeed + 10
                if v:Health() ~= 1000 then 
                    GAMEMODE:SetPlayerSpeed(v, math.min(ZSB.playerCSSpeed, 200))
                else
                    GAMEMODE:SetPlayerSpeed(v, 200)
                end
                if v:GetZombieClass() ~= 1 then 
                    v:Kill()
                    v:SetZombieClass(1)
                end
            else
                if v:Health() > 30 then 
                    v:SetMaxHealth(30)
                    v:SetHealth(30)
                end
            end
        end
    end

    local startZombsPercent = player.GetCount() * (leadbot_minzombies:GetInt() * 0.01)

    if player.GetCount() >= leadbot_quota:GetInt() then
        for k, v in ipairs(player.GetBots()) do
            if k <= math.ceil(startZombsPercent) and v:Team() == TEAM_SURVIVORS and team.NumPlayers(TEAM_ZOMBIE) < math.ceil(startZombsPercent) then
                v:Kill()
            end
        end
    end

    if team.NumPlayers(TEAM_ZOMBIE) >= 1 and team.NumPlayers(TEAM_ZOMBIE) < player.GetCount() then 
        ZSB.INTERMISSION = 0
    end

    --[[
    if leadbot_collision:GetInt() < 1 then
        for k, v in ipairs(player.GetBots()) do
            v:SetNoCollideWithTeammates(true)
        end
    else 
        for k, v in ipairs(player.GetBots()) do
            v:SetNoCollideWithTeammates(false)
        end
    end
    ]]

    InfiniteAmmoForSurvivorBots()

    for _, bot in ipairs(player.GetBots()) do
        if bot:IsLBot() then
            if LeadBot.RespawnAllowed and bot.NextSpawnTime and !bot:Alive() and bot.NextSpawnTime < CurTime() then
                bot:Spawn()
                return
            end
        end
    end
end