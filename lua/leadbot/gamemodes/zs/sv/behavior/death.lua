local posoffset = Vector(0, 0, -20)

-- Cache cvars
local leadbot_hregen = GetConVar("leadbot_hregen")
local leadbot_cs = GetConVar("leadbot_cs")

function LeadBot.Death(aggressor, victimBot)
    if CLIENT then return end
    if IsValid(victimBot) and victimBot:IsBot() and victimBot:Alive() and victimBot:Team() == TEAM_ZOMBIE then
        if victimBot:GetZombieClass() ~= 1 then 
            if victimBot:GetZombieClass() ~= 9 then 
                if victimBot:GetZombieClass() ~= 11 then
                    victimBot:SetZombieClass(1)
                end
            end
        end
        local pos = victimBot:GetPos()
        if victimBot:IsOnGround() then 
            victimBot:SetPos(pos)
        else
            victimBot:SetPos(pos + posoffset)
        end
    end
    timer.Create(victimBot:SteamID64().."secondwindstopper1", 2.1, 1, function()
        if IsValid(victimBot) and victimBot:IsBot() and victimBot:Alive() and victimBot:Team() == TEAM_ZOMBIE then
            if victimBot:GetZombieClass() ~= 1 then 
                if victimBot:GetZombieClass() ~= 9 then 
                    if victimBot:GetZombieClass() ~= 11 then
                        victimBot:SetZombieClass(1)
                    end
                end
            end
            local pos = victimBot:GetPos()
            if victimBot:IsOnGround() then 
                victimBot:SetPos(pos)
            else
                victimBot:SetPos(pos + posoffset)
            end
        end
    end)
    timer.Create(victimBot:SteamID64().."secondwindstopper2", 2.6, 1, function()
        if IsValid(victimBot) and victimBot:IsBot() and victimBot:Alive() and victimBot:Team() == TEAM_ZOMBIE then
            if victimBot:GetZombieClass() ~= 1 then 
                if victimBot:GetZombieClass() ~= 9 then 
                    if victimBot:GetZombieClass() ~= 11 then
                        victimBot:SetZombieClass(1)
                    end
                end
            end
            local pos = victimBot:GetPos()
            if victimBot:IsOnGround() then 
                victimBot:SetPos(pos)
            else
                victimBot:SetPos(pos + posoffset)
            end
        end
    end)
    if leadbot_hregen:GetInt() >= 1 then
        if aggressor:IsPlayer() and aggressor:IsBot() and aggressor:Team() == TEAM_SURVIVORS and aggressor ~= victimBot then
            local class = victimBot:GetZombieClass()
            local classtab = ZombieClasses[class]
            local newhp = classtab.Health / 10
            aggressor:SetHealth(aggressor:Health() + math.floor(newhp) )
        end
    end
    if leadbot_cs:GetInt() >= 1 then 
        if attacker:IsPlayer() and aggressor:Team() == TEAM_ZOMBIE and aggressor ~= victimBot then 
            victimBot:EmitSound("npc/fast_zombie/fz_scream1.wav", CHAN_REPLACE)  
        end
    end
end