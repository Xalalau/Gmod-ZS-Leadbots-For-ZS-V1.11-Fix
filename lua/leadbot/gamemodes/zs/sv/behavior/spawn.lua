-- Cache cvars
local leadbot_cs = GetConVar("leadbot_cs")
local leadbot_knockback = GetConVar("leadbot_knockback")

function LeadBot.Spawn(bot)
    if bot:Team() == TEAM_ZOMBIE and leadbot_cs:GetInt() >= 1 then 
        timer.Create(bot:SteamID64() .. " csHealth", 1, 1, function() 
            bot:SetMaxHealth(1000)
            bot:SetHealth(1000) 
        end )
    end

    if leadbot_knockback:GetInt() < 1 then 
        bot:AddEFlags(EFL_NO_DAMAGE_FORCES)
    else
        bot:RemoveEFlags(EFL_NO_DAMAGE_FORCES)
    end

    if bot:Team() == TEAM_ZOMBIE then

        local classes = math.random(1, 6)
        local HALFclasses = math.random(1, 14)
        local UNclasses = math.random(1, 16)

        bot:StripWeapon("weapon_zs_swissarmyknife")
        bot:StripWeapon("weapon_zs_battleaxe")
        bot:StripWeapon("weapon_zs_peashooter")
        bot:StripWeapon("weapon_zs_deagle")
        bot:StripWeapon("weapon_zs_glock3")
        bot:StripWeapon("weapon_zs_magnum")
        bot:StripWeapon("weapon_zs_smg")
        bot:StripWeapon("weapon_zs_uzi")
        bot:StripWeapon("weapon_zs_barricadekit")
        bot:StripWeapon("weapon_zs_crossbow")
        bot:StripWeapon("weapon_zs_sweepershotgun")
        bot:StripWeapon("weapon_zs_slugrifle")

        if leadbot_cs:GetInt() < 1 then 
            if INFLICTION < ZombieClasses[2].Threshold then 
                if bot:GetZombieClass() ~= 9 then 
                    if bot:GetZombieClass() ~= 11 then 
                        if classes > 3 and INFLICTION >= ZombieClasses[1].Threshold then 
                            bot:SetZombieClass(1)
                        elseif classes == 1 and INFLICTION >= ZombieClasses[5].Threshold then
                            bot:SetZombieClass(5)
                        elseif classes == 2 and INFLICTION >= ZombieClasses[6].Threshold then
                            bot:SetZombieClass(6)
                        elseif classes == 3 and INFLICTION >= ZombieClasses[7].Threshold then
                            bot:SetZombieClass(7)
                        else
                            bot:SetZombieClass(1)
                        end
                    end
                end
            elseif INFLICTION >= ZombieClasses[2].Threshold and INFLICTION < ZombieClasses[4].Threshold then
                if HALFclasses > 7 and ZombieClasses[2].Threshold then 
                    bot:SetZombieClass(2)
                else
                    if bot:GetZombieClass() ~= 9 then 
                        if bot:GetZombieClass() ~= 11 then 
                            if HALFclasses == 1 and INFLICTION >= ZombieClasses[1].Threshold then 
                                bot:SetZombieClass(1)
                            elseif HALFclasses == 2 and INFLICTION >= ZombieClasses[2].Threshold then
                                bot:SetZombieClass(2)
                            elseif HALFclasses == 3 and INFLICTION >= ZombieClasses[3].Threshold then
                                bot:SetZombieClass(3)
                            elseif HALFclasses == 4 and INFLICTION >= ZombieClasses[5].Threshold then
                                bot:SetZombieClass(5)
                            elseif HALFclasses == 5 and INFLICTION >= ZombieClasses[6].Threshold then
                                bot:SetZombieClass(6)
                            elseif HALFclasses == 6 and INFLICTION >= ZombieClasses[7].Threshold then
                                bot:SetZombieClass(7)
                            elseif HALFclasses == 7 and INFLICTION >= ZombieClasses[8].Threshold then
                                bot:SetZombieClass(8)
                            else
                                bot:SetZombieClass(2)
                            end
                        end
                    end
                end
            elseif INFLICTION >= ZombieClasses[4].Threshold then
                if UNclasses > 12 and ZombieClasses[2].Threshold then 
                    bot:SetZombieClass(2)
                elseif UNclasses <= 12 and UNclasses > 8 and ZombieClasses[4].Threshold then
                    bot:SetZombieClass(4)
                elseif UNclasses <= 8 then
                    if bot:GetZombieClass() ~= 9 then 
                        if bot:GetZombieClass() ~= 11 then 
                            if UNclasses == 1 and INFLICTION >= ZombieClasses[1].Threshold then 
                                bot:SetZombieClass(1)
                            elseif UNclasses == 2 and INFLICTION >= ZombieClasses[2].Threshold then
                                bot:SetZombieClass(2)
                            elseif UNclasses == 3 and INFLICTION >= ZombieClasses[3].Threshold then
                                bot:SetZombieClass(3)
                            elseif UNclasses == 4 and INFLICTION >= ZombieClasses[4].Threshold then 
                                bot:SetZombieClass(4)
                            elseif UNclasses == 5 and INFLICTION >= ZombieClasses[5].Threshold then
                                bot:SetZombieClass(5)
                            elseif UNclasses == 6 and INFLICTION >= ZombieClasses[6].Threshold then
                                bot:SetZombieClass(6)
                            elseif UNclasses == 7 and INFLICTION >= ZombieClasses[7].Threshold then
                                bot:SetZombieClass(7)
                            elseif UNclasses == 8 and INFLICTION >= ZombieClasses[8].Threshold then
                                bot:SetZombieClass(8)
                            else
                                bot:SetZombieClass(4)
                            end
                        end
                    end
                else
                    bot:SetZombieClass(4)
                end
            end 
        else
            bot:SetZombieClass(1)
        end
    else
        bot:SetZombieClass(1)
    end
end