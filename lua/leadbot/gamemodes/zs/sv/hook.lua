

hook.Add("InitPostEntity", "ZS_LeadBot_InitPostEntity", function()
    ZSBots.InitPostEntity()
end)

hook.Add("PlayerInitialSpawn", "ZS_LeadBot_PlayerInitialSpawn", function(ply)
    if ply:IsLBot() then
        LeadBot.InitialSpawn(ply)
    else
        LeadBot.PlayerInitialSpawn(ply)
    end
end)

hook.Add("PlayerDisconnected", "ZS_LeadBot_Disconnect", function(ply)
    if ply:IsLBot() then
        LeadBot.Disconnected(ply)
    end
end)

hook.Add("SetupMove", "ZS_LeadBot_SetupMove", function(ply, mv, cmd)
    if ply:IsLBot() then
        LeadBot.SetupMove(ply, cmd, mv)
    end
end)

hook.Add("StartCommand", "ZS_LeadBot_StartCommand", function(ply, cmd)
    if ply:IsLBot() then
        LeadBot.StartCommand(ply, cmd)
    end
end)

hook.Add("PostPlayerDeath", "ZS_LeadBot_PostPlayerDeath", function(ply)
    if ply:IsLBot() then
        LeadBot.PostDeath(ply)
    end
end)

hook.Add("Think", "LeadBot_Think", function()    
    LeadBot.Think()
end)

hook.Add("PlayerSpawn", "ZS_LeadBot_PlayerSpawn", function(ply)    
    if ply:IsLBot() then
        LeadBot.Spawn(ply)
    end
end) 

hook.Add("EntityTakeDamage", "ZS_LeadBot_EntityTakeDamage", function(victim, dmgI) 
    local aggressor = dmgI:GetAttacker()

    if victim:IsPlayer() and aggressor:IsPlayer() and aggressor:IsLBot() then
        local hp = victim:Health()
        local dmg = dmgI:GetDamage()
        local force = dmgI:GetDamageForce()

        LeadBot.InflictDamage(aggressor, victim, hp, dmg)

        if victim:IsLBot() then
            LeadBot.TakeDamage(aggressor, victim, hp, dmg)
        end
    end
end)

hook.Add("PlayerDeath", "ZS_LeadBot_PlayerDeath", function(victim, inflictor, attacker)
    if attacker.IsLBot and attacker:IsLBot() then
        if victim:IsLBot() then
            LeadBot.Death(attacker, victim)
        else
            LeadBot.PlayerDeath(attacker, victim)
        end
    end
end)
