local posoffset = Vector(0, 0, -20)

-- Cache cvars
local leadbot_hregen = GetConVar("leadbot_hregen")
local leadbot_cs = GetConVar("leadbot_cs")

function LeadBot.Death(victim, attacker)
    if CLIENT then return end
    if IsValid(victim) and victim:IsBot() and victim:Alive() and victim:Team() == TEAM_ZOMBIE then
        if victim:GetZombieClass() ~= 1 then 
            if victim:GetZombieClass() ~= 9 then 
                if victim:GetZombieClass() ~= 11 then
                    victim:SetZombieClass(1)
                end
            end
        end
        local pos = victim:GetPos()
        if victim:IsOnGround() then 
            victim:SetPos(pos)
        else
            victim:SetPos(pos + posoffset)
        end
    end
    timer.Create(victim:SteamID64().."secondwindstopper1", 2.1, 1, function()
        if IsValid(victim) and victim:IsBot() and victim:Alive() and victim:Team() == TEAM_ZOMBIE then
            if victim:GetZombieClass() ~= 1 then 
                if victim:GetZombieClass() ~= 9 then 
                    if victim:GetZombieClass() ~= 11 then
                        victim:SetZombieClass(1)
                    end
                end
            end
            local pos = victim:GetPos()
            if victim:IsOnGround() then 
                victim:SetPos(pos)
            else
                victim:SetPos(pos + posoffset)
            end
        end
    end)
    timer.Create(victim:SteamID64().."secondwindstopper2", 2.6, 1, function()
        if IsValid(victim) and victim:IsBot() and victim:Alive() and victim:Team() == TEAM_ZOMBIE then
            if victim:GetZombieClass() ~= 1 then 
                if victim:GetZombieClass() ~= 9 then 
                    if victim:GetZombieClass() ~= 11 then
                        victim:SetZombieClass(1)
                    end
                end
            end
            local pos = victim:GetPos()
            if victim:IsOnGround() then 
                victim:SetPos(pos)
            else
                victim:SetPos(pos + posoffset)
            end
        end
    end)
    if leadbot_hregen:GetInt() >= 1 then
        if attacker:IsBot() and attacker:Team() == TEAM_SURVIVORS and attacker ~= victim then
            local class = victim:GetZombieClass()
            local classtab = ZombieClasses[class]
            local newhp = classtab.Health / 10
            attacker:SetHealth(attacker:Health() + math.floor(newhp) )
        end
    end
    if leadbot_cs:GetInt() >= 1 then 
        if attacker:Team() == TEAM_ZOMBIE and attacker ~= victim then 
            victim:EmitSound("npc/fast_zombie/fz_scream1.wav", CHAN_REPLACE)  
        end
    end
end
