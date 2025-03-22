-- Cache cvars
local leadbot_zcheats = GetConVar("leadbot_zcheats")
local leadbot_hordes = GetConVar("leadbot_hordes")
local leadbot_quota = GetConVar("leadbot_quota")
local leadbot_skill = GetConVar("leadbot_skill")

function LeadBot.SetupMove(bot, cmd, mv)
    local filterList = {controller, bot, function( ent ) return ( ent:GetClass() == "prop_physics" ) end}
    local prt = util.QuickTrace(bot:EyePos(), bot:GetAimVector() * 10000000000, filterList)
    local dtnse = util.QuickTrace(bot:EyePos(), bot:GetForward() * 90 - ( bot:GetViewOffsetDucked() * 3 ), bot)

    local controller = bot.ControllerBot

    local strategy = bot:LBGetStrategy()
    local sigil1 = ZSB.Map:GetValue("sigil1")
    local sigil2 = ZSB.Map:GetValue("sigil2")
    local sigil3 = ZSB.Map:GetValue("sigil3")

    if !IsValid(controller.Target) and bot:Team() == TEAM_SURVIVORS then
        if strategy == 1 and sigil3 and bot:GetPos():DistToSqr(sigil3:GetPos()) <= 5000 or
            strategy == 2 and sigil2 and bot:GetPos():DistToSqr(sigil2:GetPos()) <= 5000 or
            strategy == 3 and sigil1 and bot:GetPos():DistToSqr(sigil1:GetPos()) <= 5000
        then
            local openvar = math.random(-90, 90)
            local hallvar = math.random(-45, 45)
            local doorvar = math.random(-15, 15)
            local eyeAngles = ZSB.Map:GetValue("eyeAngles", nil, strategy, doorVar, hallVar, openVar)

            bot:SetEyeAngles(eyeAngles)
        end
    end

    if bot:Team() == TEAM_ZOMBIE then 
        if bot:GetZombieClass() > 5 then 
            if bot:GetZombieClass() == 8 and leadbot_zcheats:GetInt() >= 1 then 
                bot:Freeze(false)
            end
            bot:SetJumpPower(300)
        else
            bot:SetJumpPower(200)
        end
        if leadbot_zcheats:GetInt() >= 1 then 
            if bot:GetZombieClass() == 3 or bot:GetZombieClass() == 5 then 
                GAMEMODE:SetPlayerSpeed(bot, ZombieClasses[bot:GetZombieClass()].Speed)
            end
        end
    end

    if leadbot_hordes:GetInt() >= 1 and bot:Team() == TEAM_SURVIVORS and leadbot_quota:GetInt() < 2 then 
        bot:Kill()
    end

    if bot:Team() == TEAM_SURVIVORS then 
        if bot:Health() <= 50 or team.NumPlayers(TEAM_SURVIVORS) <= team.NumPlayers(TEAM_ZOMBIE) then
            bot.freeroam = false
        end
    end

    if !IsValid(controller) then
        bot.ControllerBot = ents.Create("leadbot_navigator")
        bot.ControllerBot:Spawn()
        bot.ControllerBot:SetOwner(bot)
        controller = bot.ControllerBot
    end

    -- force a recompute
    if controller.PosGen and controller.P and controller.TPos ~= controller.PosGen then
        controller.TPos = controller.PosGen
        controller.P:Compute(controller, controller.PosGen)
    end

    if controller:GetPos() ~= bot:GetPos() then
        controller:SetPos(bot:GetPos())
    end

    if controller:GetAngles() ~= bot:EyeAngles() then
        controller:SetAngles(bot:EyeAngles())
    end

    if bot:Team() == TEAM_SURVIVORS then 
        if controller.Target == nil then 
            mv:SetForwardSpeed(1200)
        end
    else
        mv:SetForwardSpeed(1200)
    end

    if not IsValid(controller.Target) or controller.ForgetTarget < CurTime() or controller.Target:Health() < 1 then
        controller.Target = nil
    end

    if !IsValid(controller.Target) then
        for _, fin in ipairs(ents.FindInSphere(bot:GetShootPos() + bot:GetAimVector() * 50, 20)) do
            if IsValid(fin) and fin:IsPlayer() and fin ~= bot and fin:Team() ~= fin:Team() and fin:Alive() and not fin:IsWorld() and not fin:IsLBot() then 
                controller.Target = fin
            end
        end
    elseif controller.ForgetTarget < CurTime() and pet.Entity == controller.Target then
        controller.ForgetTarget = CurTime() + 4
    end

    if ZSB.DEBUG then
        debugoverlay.Text(bot:EyePos(), bot:Nick(), 0.03, false)
        local min, max = bot:GetHull()
        debugoverlay.Box(bot:GetPos(), min, max, 0.03, Color(255, 255, 255, 0))
    end

    if !IsValid(controller.Target) and (!controller.PosGen or bot:GetPos():DistToSqr(controller.PosGen) < 1000 or controller.LastSegmented < CurTime()) then
        -- find a random spot on the map if human, and then do it again in 5 seconds!
        if bot:Team() == TEAM_SURVIVORS then
            if bot.freeroam or strategy == 0 then
                if bot:LBGetSurvSkill() == 0 then 
                    bot:SelectWeapon("weapon_zs_swissarmyknife")
                end
                if strategy <= 2 then 
                    controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                    controller.LastSegmented = CurTime() + 1000000
                else
                    if team.NumPlayers(TEAM_ZOMBIE) > 0 then 
                        for k, v in RandomPairs(player.GetAll()) do 
                            if IsValid(v) and v:Team() == TEAM_ZOMBIE and not v:HasGodMode() and v:Alive() then 
                                controller.PosGen = v:GetPos()
                                controller.LastSegmented = CurTime() + 10
                                break
                            end
                        end
                    else
                        controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                        controller.LastSegmented = CurTime() + 1000000
                    end
                end
            else
                if strategy == 1 then 
                    -- camping ai 
                    if sigil3Valid then
                        local dist = bot:GetPos():DistToSqr(sigil3:GetPos())
                            if dist <= 2500 then -- we're here
                                controller.PosGen = nil
                            else -- we need to run...
                                controller.PosGen = sigil3:GetPos()
                            end

                        controller.LastSegmented = CurTime() + 1
                    else
                        if bot:LBGetSurvSkill() == 0 then 
                            bot:SelectWeapon("weapon_zs_swissarmyknife")
                        end
                        controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                        controller.LastSegmented = CurTime() + 5
                    end
                elseif strategy == 2 then
                    if sigil2Valid then 
                        local dist = bot:GetPos():DistToSqr(sigil2:GetPos())
                            if dist <= 2500 then
                                controller.PosGen = nil
                            else
                                controller.PosGen = sigil2:GetPos()
                            end

                        controller.LastSegmented = CurTime() + 1
                    else
                        if bot:LBGetSurvSkill() == 0 then 
                            bot:SelectWeapon("weapon_zs_swissarmyknife")
                        end
                        for k, v in RandomPairs(player.GetAll()) do 
                            if IsValid(v) and v:Team() == TEAM_SURVIVORS then 
                                controller.PosGen = v:GetPos()
                                controller.LastSegmented = CurTime() + 10
                                break
                            end
                        end
                    end
                elseif strategy == 3 then
                    if sigil1Valid then 
                        local dist = bot:GetPos():DistToSqr(sigil1:GetPos())
                            if dist <= 2500 then
                                controller.PosGen = nil
                            else
                                controller.PosGen = sigil1:GetPos()
                            end
                        controller.LastSegmented = CurTime() + 1
                    else
                        if bot:LBGetSurvSkill() == 0 then 
                            bot:SelectWeapon("weapon_zs_swissarmyknife")
                        end
                        for k, v in RandomPairs(player.GetAll()) do 
                            if IsValid(v) and v:Team() == TEAM_ZOMBIE and not v:HasGodMode() then 
                                controller.PosGen = v:GetPos()
                                controller.LastSegmented = CurTime() + 10
                                break
                            end
                        end
                    end
                end
            end
        else
            -- find survivor position
            if team.NumPlayers(TEAM_SURVIVORS) ~= 0 then
                for k, v in RandomPairs(player.GetAll()) do 
                    if IsValid(v) and v:Team() == TEAM_SURVIVORS then 
                        controller.PosGen = v:GetPos()
                        controller.LastSegmented = CurTime() + 1000000
                        break
                    end
                end
            end
        end
    elseif IsValid(controller.Target) then
        -- move to our target
        local distance = controller.Target:GetPos():DistToSqr(bot:GetPos())
        if bot:IsPlayer() and controller.Target:IsPlayer() and bot:Team() ~= controller.Target:Team() or bot:Team() == TEAM_SURVIVORS and controller.Target:IsNPC() then 
            controller.PosGen = controller.Target:GetPos()
            controller.LastSegmented = CurTime() + 0.1
        end

        -- back up if the target is really close
        -- TODO: find a random spot rather than trying to back up into what could just be a wall
        -- something like controller.PosGen = controller:FindSpot("random", {pos = bot:GetPos() - bot:GetForward() * 350, radius = 1000})?

        if controller.Target:IsPlayer() or controller.Target:IsNPC() then
            if bot:Team() == TEAM_ZOMBIE then 
                mv:SetForwardSpeed(1200)
                if distance > 45000 and bot:LBGetZomSkill() == 1 and IsValid(prt.Entity) then
                    if controller.strafeAngle == 1 then
                        mv:SetSideSpeed(1500)
                    elseif controller.strafeAngle == 2 then
                        mv:SetSideSpeed(-1500)
                    end
                end
            else
                if strategy == 0 or bot.freeroam then 
                    if bot:Health() > 70 then 
                        if distance <= 45000 then
                            mv:SetForwardSpeed(-1200)
                        end
                    elseif bot:Health() <= 70 and bot:Health() > 40 then 
                        if distance <= 90000 then
                            mv:SetForwardSpeed(-1200)
                        end
                    elseif bot:Health() <= 40 and bot:Health() > 10 then 
                        if distance <= 135000 then
                            mv:SetForwardSpeed(-1200)
                        end
                    elseif bot:Health() <= 10 then 
                        if distance <= 180000 then
                            mv:SetForwardSpeed(-1200)
                        end
                    end
                    if bot:LBGetSurvSkill() == 0 and IsValid(prt.Entity) then
                        if controller.strafeAngle == 1 then
                            mv:SetSideSpeed(1500)
                        elseif controller.strafeAngle == 2 then
                            mv:SetSideSpeed(-1500)
                        end
                    end
                else
                    if distance <= 45000 and IsValid(prt.Entity) then 
                        mv:SetForwardSpeed(-1200)
                        if controller.strafeAngle == 1 then
                            mv:SetSideSpeed(1500)
                        elseif controller.strafeAngle == 2 then
                            mv:SetSideSpeed(-1500)
                        end
                    end
                    if bot:Health() <= 40 and IsValid(prt.Entity) then 
                        if controller.Target:IsPlayer() and ( controller.Target:GetZombieClass() == 2 or controller.Target:GetZombieClass() > 5 and controller.Target:GetZombieClass() < 9 ) or controller.Target:IsNPC() then                                 if controller.strafeAngle == 1 then
                                mv:SetSideSpeed(1500)
                            elseif controller.strafeAngle == 2 then
                                mv:SetSideSpeed(-1500)
                            end
                        end
                    end
                end
            end
        else
            mv:SetForwardSpeed(1200)
        end

        if bot:Team() == TEAM_SURVIVORS then 
            local tier2 = GetConVar("zs_rewards_1"):GetInt()
            local tier3 = GetConVar("zs_rewards_3"):GetInt()
            local tier4 = GetConVar("zs_rewards_4"):GetInt()
            local botwep = bot:GetActiveWeapon()
            local botclip = botwep:Clip1()
            if distance > 30000 then 
                if bot:Frags() < tier2 then
                    if bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_battleaxe")
                        bot:SelectWeapon("weapon_zs_peashooter")
                    elseif botclip <= 0 and bot:GetAmmoCount("Pistol") <= 0 then
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                elseif bot:Frags() >= tier2 and bot:Frags() < tier3 then
                    if bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_glock3")
                        bot:SelectWeapon("weapon_zs_magnum")
                    elseif botclip <= 0 and bot:GetAmmoCount("Pistol") <= 0 then
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                elseif bot:Frags() >= tier3 then
                    if bot:GetAmmoCount("SMG1") > 0 then 
                        bot:SelectWeapon("weapon_zs_uzi")
                        bot:SelectWeapon("weapon_zs_smg")
                    elseif bot:GetAmmoCount("SMG1") <= 0 and bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_glock3")
                        bot:SelectWeapon("weapon_zs_magnum")
                    elseif botclip <= 0 and bot:GetAmmoCount("SMG1") <= 0 and bot:GetAmmoCount("Pistol") <= 0 then 
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                end
            else
                if bot:Frags() < tier2 then
                    if bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_battleaxe")
                        bot:SelectWeapon("weapon_zs_peashooter")
                    elseif botclip <= 0 and bot:GetAmmoCount("Pistol") <= 0 then
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                elseif bot:Frags() >= tier2 and bot:Frags() < tier3 then
                    if bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_glock3")
                        bot:SelectWeapon("weapon_zs_magnum")
                    elseif botclip <= 0 and bot:GetAmmoCount("Pistol") <= 0 then
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                elseif bot:Frags() >= tier3 and bot:Frags() < tier4 then
                    if bot:GetAmmoCount("SMG1") > 0 then 
                        bot:SelectWeapon("weapon_zs_uzi")
                        bot:SelectWeapon("weapon_zs_smg")
                    elseif bot:GetAmmoCount("SMG1") <= 0 and bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_glock3")
                        bot:SelectWeapon("weapon_zs_magnum")
                    elseif botclip <= 0 and bot:GetAmmoCount("SMG1") <= 0 and bot:GetAmmoCount("Pistol") <= 0 then
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                elseif bot:Frags() >= tier4 then
                    if bot:GetAmmoCount("Buckshot") > 0 then 
                        bot:SelectWeapon("weapon_zs_sweepershotgun")
                    elseif bot:GetAmmoCount("Buckshot") <= 0 and bot:GetAmmoCount("SMG1") > 0 then
                        bot:SelectWeapon("weapon_zs_uzi")
                        bot:SelectWeapon("weapon_zs_smg")
                    elseif bot:GetAmmoCount("Buckshot") <= 0 and bot:GetAmmoCount("SMG1") <= 0 and bot:GetAmmoCount("Pistol") > 0 then 
                        bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_glock3")
                    elseif botclip <= 0 and bot:GetAmmoCount("Buckshot") <= 0 and bot:GetAmmoCount("SMG1") <= 0 and bot:GetAmmoCount("Pistol") <= 0 then
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                end
            end
        end
    end

    -- movement also has a similar issue, but it's more severe...
    if !controller.P then
        return
    end

    local segments = controller.P:GetAllSegments()

    if !segments then return end

    local cur_segment = controller.cur_segment
    local curgoal = (controller.PosGen and segments[cur_segment])

    -- eyesight
    local lerp
    local lerpc
    local mva
    local aimskill
    if leadbot_skill:GetInt() == 0 then
        aimskill = 4
    elseif leadbot_skill:GetInt() == 1 then
        aimskill = 8
    elseif leadbot_skill:GetInt() == 2 then
        aimskill = 12
    else
        aimskill = 16
    end

    if leadbot_skill:GetInt() ~= 4 then
        if bot:Team() == TEAM_SURVIVORS and IsValid(controller.Target) then
            if strategy > 0 and not bot.freeroam then 
                lerp = FrameTime() * aimskill / 2
                lerpc = FrameTime() * aimskill / 2
            else
                lerp = FrameTime() * aimskill
                lerpc = FrameTime() * aimskill
            end
        end
        if bot:Team() == TEAM_SURVIVORS and !IsValid(controller.Target) or bot:Team() == TEAM_ZOMBIE then
            lerp = FrameTime() * (aimskill / 4)
            lerpc = FrameTime() * (aimskill / 4)
        end
    else
        if bot:Team() == TEAM_SURVIVORS and IsValid(controller.Target) then
            if strategy > 0 and not bot.freeroam then 
                lerp = FrameTime() * bot:LBGetShootSkill() / 2
                lerpc = FrameTime() * bot:LBGetShootSkill() / 2
            else
                lerp = FrameTime() * bot:LBGetShootSkill()
                lerpc = FrameTime() * bot:LBGetShootSkill()
            end
        end
        if bot:Team() == TEAM_SURVIVORS and !IsValid(controller.Target) or bot:Team() == TEAM_ZOMBIE then
            lerp = FrameTime() * (bot:LBGetShootSkill() / 4)
            lerpc = FrameTime() * (bot:LBGetShootSkill() / 4)
        end
    end

    -- got nowhere to go, why keep moving?
    if curgoal then
        -- think every step of the way!
        if segments[cur_segment + 1] and Vector(bot:GetPos().x, bot:GetPos().y, 0):DistToSqr(Vector(curgoal.pos.x, curgoal.pos.y)) < 100 then
            controller.cur_segment = controller.cur_segment + 1
            curgoal = segments[controller.cur_segment]
        end

        local goalpos = curgoal.pos

        if bot:GetVelocity():Length2DSqr() <= 225 then
            if !bot:IsFrozen() then 
                if !IsValid(controller.Target) and bot:Team() == TEAM_SURVIVORS or bot:Team() == TEAM_ZOMBIE then
                    if controller.nextStuckJump < CurTime() then
                        if !bot:Crouching() then
                            controller.NextJump = 0
                        end
                        controller.nextStuckJump = CurTime() + math.Rand(1, 2)
                    end
                end
            end
        end

        if controller.NextCenter < CurTime() then
            if curgoal.area:GetAttributes() ~= NAV_MESH_JUMP and ( bot:GetVelocity():Length2DSqr() <= 225 or IsValid(controller.Target) ) then
                if !bot:IsFrozen() then 
                    controller.strafeAngle = ((controller.strafeAngle == 1 and 2) or 1)
                    controller.NextCenter = CurTime() + math.Rand(0.3, 0.9)
                end
            end
        end

        if controller.NextCenter > CurTime() then
            if curgoal.area:GetAttributes() ~= NAV_MESH_JUMP and bot:GetVelocity():Length2DSqr() <= 10000 and ( !IsValid(controller.Target) and bot:GetMoveType() ~= MOVETYPE_LADDER or bot:Team() == TEAM_SURVIVORS and IsValid(controller.Target) and ( strategy == 0 or bot.freeroam ) or bot:Team() == TEAM_ZOMBIE and IsValid(controller.Target) and strategy > 1 ) then                    if !bot:IsFrozen() then 
                    if controller.strafeAngle == 1 then
                        mv:SetSideSpeed(1500)
                        if bot:LBGetSurvSkill() == 1 then 
                            mv:SetForwardSpeed(0)
                        end
                    elseif controller.strafeAngle == 2 then
                        mv:SetSideSpeed(-1500)
                        if bot:LBGetSurvSkill() == 1 then 
                            mv:SetForwardSpeed(0)
                        end
                    end
                end
            end
        end

        -- jump
        if not bot:IsFrozen() and ( controller.NextJump ~= 0 and curgoal.type > 1 and controller.NextJump < CurTime() or controller.NextJump ~= 0 and curgoal.area:GetAttributes() == NAV_MESH_JUMP and controller.NextJump < CurTime() ) then
            controller.NextJump = 0
        end

        -- duck
        if curgoal.area:GetAttributes() == NAV_MESH_CROUCH or IsValid(dtnse.Entity) then
            controller.NextDuck = CurTime() + 0.1
        end

        controller.goalPos = goalpos

        if ZSB.DEBUG then
            controller.P:Draw()
        end

        mva = ((goalpos + bot:GetCurrentViewOffset()) - bot:GetShootPos()):Angle()

        mv:SetMoveAngles(mva)
    else
        if bot:Team() == TEAM_SURVIVORS then
            mv:SetForwardSpeed(-1200)
        end
        if bot:Team() == TEAM_ZOMBIE then
            mv:SetForwardSpeed(1200)
        end
    end

    if IsValid(controller.Target) and controller.Target:IsPlayer() then
        if bot:Team() == TEAM_SURVIVORS then
            if controller.Target:GetZombieClass() >= 2 and controller.Target:GetZombieClass() < 5 or controller.Target:GetZombieClass() < 2 or controller.Target:GetZombieClass() == 5 or controller.Target:GetZombieClass() >= 10 then                    if !controller.Target:Crouching() then 
                    bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
                else
                    bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
                end
            end
            if controller.Target:GetZombieClass() >= 6 then
                if controller.Target:GetZombieClass() >= 6 and controller.Target:GetZombieClass() < 10 then
                    bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
                else
                    bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
                end
            end
        else 
            if !bot:IsFrozen() then 
                bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
            end
        end
        return
    elseif IsValid(controller.Target) and not controller.Target:IsPlayer() then
        if !bot:IsFrozen() then 
            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:WorldSpaceCenter() - bot:GetShootPos()):Angle()))
        end
    elseif curgoal then
        if controller.LookAtTime > CurTime() then
            local ang = LerpAngle(lerpc, bot:EyeAngles(), controller.LookAt)
            if !bot:IsFrozen() then 
                bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
            end
        else
            local ang = LerpAngle(lerpc, bot:EyeAngles(), mva)
            if !bot:IsFrozen() then 
                bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
            end
        end
    end
end
