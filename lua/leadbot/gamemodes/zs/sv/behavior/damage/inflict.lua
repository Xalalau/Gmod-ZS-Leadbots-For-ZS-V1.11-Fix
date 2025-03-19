-- Cache cvars
local leadbot_cs = GetConVar("leadbot_cs")

function LeadBot.InflictDamage(bot, victim, hp, dmg)
    if leadbot_cs:GetInt() >= 1 then
        if victim:IsPlayer() and bot:IsPlayer() and victim:Team() == TEAM_ZOMBIE and bot:Team() == TEAM_SURVIVORS then 
            ZSBots.playerCSSpeed = 1
            victim:SetVelocity(victim:GetVelocity() + (force / 4))
        end
    end

    if victim:IsNPC() then
        local controller = victim:GetController()
        local hurtdistance = victim:GetPos():DistToSqr(bot:GetPos())
            
        --[[if hp <= dmg and math.random(1, 2) == 1 and bot:IsPlayer() then
            LeadBot.TalkToMe(bot, "taunt")
        end

        if hp >= dmg and victim:Team() == TEAM_SURVIVOFRS and victim:Health() <= 10 and math.random(10) == 1 then -- don't spam
            LeadBot.TalkToMe(bot, "help")
        end

        if hp >= dmg and victim:Team() == TEAM_SURVIVORS and not bot:IsNPC() and victim:Health() <= 40 and math.random(1, 2) == 1 then -- don't spam
            LeadBot.TalkToMe(bot, "pain")
        end]]

        if victim:Team() == TEAM_SURVIVORS then 
            if hp >= dmg and not bot:IsNPC() and bot:Team() ~= victim:Team() or hp >= dmg and bot:IsNPC() then
                controller.Target = bot
                controller.ForgetTarget = CurTime() + 4
            end
        end

        if victim:Team() == TEAM_ZOMBIE then
            local distance = victim:GetPos():DistToSqr(controller.PosGen)
            if hp >= dmg and not bot:IsNPC() and bot:Team() ~= victim:Team() and hurtdistance < distance then
                controller.PosGen = bot:GetPos()
                controller.LastSegmented = CurTime() + 5 
                controller.LookAtTime = CurTime() + 2
                if !bot:IsFrozen() then 
                    controller.LookAt = (bot:GetPos() - victim:GetPos()):Angle()
                end
            end
        end

        if victim:Team() == TEAM_ZOMBIE and IsValid(controller.Target) then
            local distance = victim:GetPos():DistToSqr(controller.Target:GetPos())
            if hp >= dmg and not bot:IsNPC() and bot:Team() ~= victim:Team() and distance > hurtdistance then
                controller.Target = bot
                controller.ForgetTarget = CurTime() + 4
            end
        end
    end
end