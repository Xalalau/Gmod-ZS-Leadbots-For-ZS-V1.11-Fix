timer.Create("zombieNearDetector", 20, 0, function() 
    if team.NumPlayers(TEAM_ZOMBIE) <= 0 then return end

    for _, bot in ipairs(player.GetBots()) do  
        local controller = bot.ControllerBot 
        if controller.PosGen and !IsValid(controller.Target) then 
            if bot:Team() == TEAM_ZOMBIE and bot:LBGetZomSkill() == 1 then 
                for _, plyOrBot in ipairs(player.GetAll()) do
                    local distance = plyOrBot:GetPos():DistToSqr(bot:GetPos())
                    local otherdistance = controller.PosGen:DistToSqr(bot:GetPos())
                    if IsValid(plyOrBot) and plyOrBot:Team() == TEAM_SURVIVORS and distance < otherdistance then 
                        controller.PosGen = plyOrBot:GetPos()
                        controller.LastSegmented = CurTime() + 4000000
                        break
                    end
                end
            end
        end
    end
end)

timer.Create("zombieStuckDetector", 20, 0, function()
    if team.NumPlayers(TEAM_ZOMBIE) <= 0 then return end
    for k, bot in ipairs(player.GetBots()) do
        local controller = bot.ControllerBot 
        if bot:Team() == TEAM_ZOMBIE then
            if bot:GetVelocity():Length2DSqr() <= 225 and not bot:IsFrozen() and bot:Team() == TEAM_ZOMBIE then
                if controller.Target == nil or IsValid(controller.Target) and not controller.Target:IsPlayer() and controller.Target:Health() <= 0 or bot:GetZombieClass() > 3 or bot:GetVelocity():Length2DSqr() == 0 then 
                    bot:Kill()
                end
            end
        end
    end
end)