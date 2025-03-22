-- Cache cvars
local leadbot_hinfammo = GetConVar("leadbot_hinfammo")

-- Credit goes out to 女儿 for this infinite ammo code :D --
local function KeepInfiniteAmmoForSurvivorBots(bot, weapon)
    if not leadbot_hinfammo:GetBool() then return end
    if not bot:Team() == TEAM_SURVIVORS then return end

    local maxClip = weapon:GetMaxClip1()
    local maxClip2 = weapon:GetMaxClip2()
    local primAmmoType = weapon:GetPrimaryAmmoType()
    local secAmmoType = weapon:GetSecondaryAmmoType()

    if maxClip > 0 then
        weapon:SetClip1(maxClip)

        if primAmmoType ~= -1 then
            bot:SetAmmo(maxClip, primAmmoType)
        end
    end

    if maxClip2 > 0 then
        weapon:SetClip2(maxClip2)
 
        if secAmmoType ~= -1 and secAmmoType ~= primAmmoType then
            bot:SetAmmo(maxClip2, secAmmoType)
        end
    end
end

function LeadBot.FireBullets(bot, weapon, data)
    KeepInfiniteAmmoForSurvivorBots(bot, weapon)
end
