-- Cache cvars
local leadbot_cs = GetConVar("leadbot_cs")
local leadbot_zchance = GetConVar("leadbot_zchance")
local leadbot_mapchanges = GetConVar("leadbot_mapchanges")
local zs_roundtime = GetConVar("zs_roundtime")
local zs_human_deadline = GetConVar("zs_human_deadline")

function LeadBot.PlayerInitialSpawn(ply)
    if not game.SinglePlayer() then
        if not ply:IsBot() and leadbot_zchance:GetInt() < 1 and INFLICTION < 0.5 or not ply:IsBot() and leadbot_zchance:GetInt() < 1 and (CurTime() <= zs_roundtime:GetInt()*0.5 and not zs_human_deadline:GetBool()) then 
            timer.Simple(2, function() 
                local mapName = game.GetMap()
                ply:Redeem()
                if leadbot_mapchanges:GetInt() >= 1 then 
                    if mapName == "zs_buntshot" then 
                        ply:SetPos( Vector(-520.605774 + math.random(-25, 25), -90.801414 + math.random(-25, 25), -211.968750) ) 
                    elseif mapName == "zs_snow" then 
                        ply:SetPos( Vector(-566.444092 + math.random(-25, 25), 1023.660217 + math.random(-25, 25), -38.856033) ) 
                    end
                end
            end)
        end
    end
end