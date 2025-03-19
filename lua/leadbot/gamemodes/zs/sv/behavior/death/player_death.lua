-- Cache cvars
local leadbot_cs = GetConVar("leadbot_cs")

function LeadBot.PlayerDeath(victim, attacker)
    if leadbot_cs:GetInt() >= 1 then 
        if attacker:Team() == TEAM_ZOMBIE and attacker ~= victim then 
            victim:EmitSound("npc/fast_zombie/fz_scream1.wav", CHAN_REPLACE)  
        end
    end
end