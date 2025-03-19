timer.Create("zombieNearDetector", 20, 0, function() 
    if team.NumPlayers(TEAM_ZOMBIE) <= 0 then return end

    for _, z in ipairs(player.GetBots()) do  
        local controller = z.ControllerBot 
        if controller.PosGen and !IsValid(controller.Target) then 
            if z:Team() == TEAM_ZOMBIE and z:LBGetZomSkill() == 1 then 
                for _, h in ipairs(player.GetAll()) do
                    local distance = h:GetPos():DistToSqr(z:GetPos())
                    local otherdistance = controller.PosGen:DistToSqr(z:GetPos())
                    if IsValid(h) and h:Team() == TEAM_SURVIVORS and distance < otherdistance then 
                        controller.PosGen = h:GetPos()
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
    for k, v in ipairs(player.GetBots()) do
        local controller = v.ControllerBot 
        if v:Team() == TEAM_ZOMBIE then
            if v:GetVelocity():Length2DSqr() <= 225 and not v:IsFrozen() and v:Team() == TEAM_ZOMBIE then
                if controller.Target == nil or IsValid(controller.Target) and not controller.Target:IsPlayer() and controller.Target:Health() <= 0 or v:GetZombieClass() > 3 or v:GetVelocity():Length2DSqr() == 0 then 
                    v:Kill()
                end
            end
        end
    end
end)