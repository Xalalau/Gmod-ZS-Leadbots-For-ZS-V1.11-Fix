-- basically finished :I --f
--      By Tony Dosk Enginooy. 8====================================================================================D 
--         This file was creater to Zombie Survival v1.11 Fix, by Xalalau. Ty, Tony - Xala

LeadBot.Gamemode = "zombiesurvival"
LeadBot.RespawnAllowed = true -- allows bots to respawn automatically when dead
LeadBot.PlayerColor = true -- disable this to get the default gmod style players
LeadBot.NoNavMesh = false -- disable the nav mesh check
LeadBot.TeamPlay = true -- don't hurt players on the bots team
LeadBot.LerpAim = true -- interpolate aim (smooth aim)
LeadBot.AFKBotOverride = false -- KEEP THIS FALSE OR ELSE CODE BREAKS!
LeadBot.SuicideAFK = false -- kill the player when entering/exiting afk
LeadBot.NoFlashlight = true -- disable flashlight being enabled in dark areas
LeadBot.NoSprint = true
LeadBot.Strategies = 3 -- how many strategies can the bot pick from

concommand.Add("leadbot_add", function(ply, _, args) if IsValid(ply) and !ply:IsSuperAdmin() then return end local amount = 1 if tonumber(args[1]) then amount = tonumber(args[1]) end for i = 1, amount do timer.Simple(i * 0.1, function() LeadBot.AddBot() end) end end, nil, "Adds a LeadBot")
concommand.Add("leadbot_kick", function(ply, _, args) if !args[1] or IsValid(ply) and !ply:IsSuperAdmin() then return end if args[1] ~= "all" then for k, v in ipairs(player.GetBots()) do if string.find(v:GetName(), args[1]) then v:Kick() return end end else for k, v in ipairs(player.GetBots()) do v:Kick() end end end, nil, "Kicks LeadBots (all is avaliable!)")
CreateConVar("leadbot_strategy", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enables the strategy system for newly created bots.")
CreateConVar("leadbot_names", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot names, seperated by commas.")
CreateConVar("leadbot_models", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot models, seperated by commas.")
CreateConVar("leadbot_name_prefix", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot name prefix")
local leadbot_minzombies = CreateConVar("leadbot_minzombies", "1", {FCVAR_ARCHIVE}, "What Percentage of Leadbots become Zombies at the Beginning (this includes players as well)", 0, 100)
local leadbot_zchance = CreateConVar("leadbot_zchance", "0", {FCVAR_ARCHIVE}, "If you want a chance to become a zombie when you spawn", 0 , 1)
local leadbot_hordes = CreateConVar("leadbot_hordes", "0", {FCVAR_ARCHIVE}, "If you want to play horde mode instead of using quota", 0 , 1)
local leadbot_hinfammo = CreateConVar("leadbot_hinfammo", "1", {FCVAR_ARCHIVE}, "If you want survivor bots to have an infinite amount of clip ammo so that they survive longer", 0 , 1)
local leadbot_hregen = CreateConVar("leadbot_hregen", "0", {FCVAR_ARCHIVE}, "If you want survivor bots to heal every time a survivor dies so that they survive longer", 0 , 1)
local leadbot_freeroam = CreateConVar("leadbot_freeroam", "0", {FCVAR_ARCHIVE}, "If you want survivor bots to run around instead of camp", 0 , 1)
local leadbot_zcheats = CreateConVar("leadbot_zcheats", "0", {FCVAR_ARCHIVE}, "If you want zombie bots to cheat a little so that they're better at killing humans'", 0 , 1)
local leadbot_collision = CreateConVar("leadbot_collision", "0", {FCVAR_ARCHIVE}, "If you want bots to not collide with each other or others", 0 , 1)
local leadbot_knockback = CreateConVar("leadbot_knockback", "1", {FCVAR_ARCHIVE}, "If you want to not experience any knockback", 0 , 1)
local leadbot_mapchanges = CreateConVar("leadbot_mapchanges", "0", {FCVAR_ARCHIVE}, "If you want certain things to be removed from certain maps in order for bots to not get stuck and/or confused", 0, 1)
local leadbot_cs = CreateConVar("leadbot_cs", "0", {FCVAR_ARCHIVE}, "If you want THE counter strike ZM experience", 0 , 1)
local DEBUG = false
local nextCheck = 0
local INTERMISSION = 1
local INTERMISSION_FAKE_TIMER = 60
local sigil3Valid = false
local sigil2Valid = false
local sigil1Valid = false
local survivorBreak = false
local survivorBoxBreak = false
local zombiePropCheck = true
local zombieBreakCheck = true
local playerCSSpeed = 200
resource.AddFile("sound/intermission.mp3")

if SERVER then 
    timer.Simple(3, function() 
        for k, v in ipairs(ents.FindByClass("func_door_rotating")) do
            v:Remove()
        end
            
        if game.GetMap() ~= "zs_jail_v1" then 
            for k, v in ipairs(ents.FindByClass("prop_door_rotating")) do
                v:Remove()
            end
        end

        if game.GetMap() == "zs_embassy" or game.GetMap() == "zs_buntshot" or game.GetMap() == "zs_termites_v2" or game.GetMap() == "zs_pub" or game.GetMap() == "zs_bog_shityhouse" or game.GetMap() == "zs_ancient_castle_opt" or game.GetMap() == "zs_deadblock_v2" or game.GetMap() == "zs_gu_frostbite_v2" or game.GetMap() == "zs_house_outbreak_b2" or game.GetMap() == "zs_imashouse_b2" then
            survivorBreak = true
        end

        if game.GetMap() == "zs_embassy" then
            survivorBoxBreak = true
        end

        if game.GetMap() == "zs_buntshot" or game.GetMap() == "zs_port_v5" or game.GetMap() == "zs_bunkerhouse" then 
            zombiePropCheck = false
        end

        if game.GetMap() == "zs_pub" or game.GetMap() == "zs_ascent" or game.GetMap() == "zs_nastierhouse_v3" then
            zombieBreakCheck = false
        end

        if leadbot_mapchanges:GetInt() >= 1 then 
            for k, v in ipairs(ents.FindByClass("func_useableladder")) do
                v:Remove()
            end

            if game.GetMap() == "zs_embassy" or game.GetMap() == "zs_termites_v2" or game.GetMap() == "zs_lila_panic_v3" or game.GetMap() == "zs_house_number_23" or game.GetMap() == "zs_mall_dl" or game.GetMap() == "zs_fen" or game.GetMap() == "zs_house_outbreak_b2" or game.GetMap() == "zs_pub" then 
                for k, v in ipairs( ents.FindByClass( "func_breakable" ) ) do
                    v:Remove()
                end
            end

            for k, v in ipairs( ents.FindByClass( "func_physbox" ) ) do
                if game.GetMap() == "zs_jail_v1" or game.GetMap() == "zs_house_number_23" or game.GetMap() == "zs_embassy" and v:Health() > 1 or game.GetMap() == "zs_the_pub_beta1" and ( v:GetModel() == "*46" or v:GetModel() == "*47" ) then 
                    v:Remove()
                end
                if game.GetMap() == "zs_termites_v2" then 
                    v:Fire("EnableMotion")
                end
            end

            for k, v in ipairs( ents.FindByClass( "prop_physics" ) ) do
                if v:GetModel() == "models/combine_apc.mdl" or v:GetModel() == "models/props_junk/vent001.mdl" or v:GetModel() == "models/props/cs_militia/refrigerator01.mdl" then 
                    v:Remove()
                end
                if game.GetMap() == "zs_imashouse_b2" and v:GetModel() == "models/props_debris/wood_board04a.mdl" then  
                    v:Remove()
                end
                if game.GetMap() == "zs_panic_house_v2" and v:GetModel() == "models/props_debris/wood_board06a.mdl" then  
                    v:Remove()
                end
                if game.GetMap() == "zs_termites_v2" then 
                    v:Fire("EnableMotion")
                end
            end

            if game.GetMap() == "zs_snow" then 
                barrierLeadBot = ents.Create("prop_physics")
                barrierLeadBot:SetModel("models/props_c17/fence03a.mdl")
                barrierLeadBot:SetPos(Vector(-125.453964, 250.133347, -293.968750))
                barrierLeadBot:SetAngles(Angle(0, 90, 0))
                barrierLeadBot:Spawn()
                barrierLeadBot:Fire("DisableMotion")

                barrierLeadBot2 = ents.Create("prop_physics")
                barrierLeadBot2:SetModel("models/props_c17/fence03a.mdl")
                barrierLeadBot2:SetPos(Vector(-224.436020, 1804.177734, -551.968750))
                barrierLeadBot2:SetAngles(Angle(0, 90, 0))
                barrierLeadBot2:Spawn()
                barrierLeadBot2:Fire("DisableMotion")
            end
        end 
    end )

    local player_meta = FindMetaTable("Player")
    local oldInfo = player_meta.GetInfo

    function player_meta.IsLBot(self, realbotsonly)
        if realbotsonly == true then
            return self.LeadBot and self:IsBot() or false
        end

        return self.LeadBot or false
    end

    function player_meta.LBGetStrategy(self)
        if self.LeadBot_Config then
            return self.LeadBot_Config[4]
        else
            return 0
        end
    end

    function player_meta.LBGetSurvSkill(self)
        if self.LeadBot_Config then
            return self.LeadBot_Config[5]
        else
            return 0
        end
    end

    function player_meta.LBGetZomSkill(self)
        if self.LeadBot_Config then
            return self.LeadBot_Config[6]
        else
            return 0
        end
    end

    function player_meta.LBGetModel(self)
        if self.LeadBot_Config then
            return self.LeadBot_Config[1]
        else
            return "kleiner"
        end
    end

    function player_meta.LBGetColor(self, weapon)
        if self.LeadBot_Config then
            if weapon == true then
                return self.LeadBot_Config[3]
            else
                return self.LeadBot_Config[2]
            end
        else
            return Vector(0, 0, 0)
        end
    end

    function player_meta.GetInfo(self, convar)
        if self:IsBot() and self:IsLBot() then
            if convar == "cl_playermodel" then
                return self:LBGetModel() --self.LeadBot_Config[1]
            elseif convar == "cl_playercolor" then
                return self:LBGetColor() --self.LeadBot_Config[2]
            elseif convar == "cl_weaponcolor" then
                return self:LBGetColor(true) --self.LeadBot_Config[3]
            else
                return ""
            end
        else
            return oldInfo(self, convar)
        end
    end

    function player_meta.GetController(self)
        if self:IsLBot() then
            return self.ControllerBot
        end
    end

    local name_Default = {
        alyx = "Alyx Vance",
        kleiner = "BuizBuben241",
        breen = "Dr. Wallace Breen",
        gman = "The G-Man",
        odessa = "Odessa Cubbage",
        eli = "Eli Vance",
        monk = "Father Grigori",
        mossman = "Judith Mossman",
        mossmanarctic = "Bushe",
        barney = "Barney Calhoun",


        dod_american = "Boldier",
        dod_german = "German Soldier",

        css_swat = "GIGN",
        css_leet = "Elite Crew",
        css_arctic = "Artic Avengers",
        css_urban = "SEAL Team Six",
        css_riot = "GSG-9",
        css_gasmask = "SAS",
        css_phoenix = "Phoenix Connexion",
        css_guerilla = "Guerilla Warfare",

        hostage01 = "Art",
        hostage02 = "Sandro",
        hostage03 = "Vance",
        hostage04 = "Cohrt",

        police = "Civil Protection",
        policefem = "Civil Erection",

        chell = "Chell",

        combine = "Combine Soldier",
        combineprison = "Combine Prison Guard",
        combineelite = "Bony Bosk Benginooy",
        stripped = "Stripped Combine Soldier",

        zombie = "Zombie",
        zombiefast = "Fast Zombie",
        zombine = "Zombine",
        corpse = "Corpse",
        charple = "Charple",
        skeleton = "BiversRox",

        male01 = "Dan",
        male02 = "Ted",
        male03 = "Joe",
        male04 = "Eric",
        male05 = "Tart",
        male06 = "Mandro",
        male07 = "Mike",
        male08 = "Dance",
        male09 = "Erdin",
        male10 = "Van",
        male11 = "Fed",
        male12 = "Poe",
        male13 = "Deric",
        male14 = "Fart",
        male15 = "Candro",
        male16 = "Like",
        male17 = "Prance",
        male18 = "Ferdin",
        female01 = "Joey",
        female02 = "Kanisha",
        female03 = "Kim",
        female04 = "Chau",
        female05 = "Naomi",
        female06 = "Lakeetra",
        female07 = "Boey",
        female08 = "Latisha",
        female09 = "Jim",
        female10 = "Chow",
        female11 = "Satochi",
        female12 = "LackEatTra",

        medic01 = "Pan",
        medic02 = "Bed",
        medic03 = "Loe",
        medic04 = "Pric",
        medic05 = "Bart",
        medic06 = "Fandro",
        medic07 = "Pike",
        medic08 = "Lance",
        medic09 = "Sherdin",
        medic10 = "Moey",
        medic11 = "Moqueefa",
        medic12 = "Tim",
        medic13 = "Cow",
        medic14 = "Natsuke",
        medic15 = "Lackee",

        refugee01 = "Led",
        refugee02 = "Leric",
        refugee03 = "Landro",
        refugee04 = "Yance",
    }

    function LeadBot.AddBot()
        if SERVER then 
            if !navmesh.IsLoaded() and !LeadBot.NoNavMesh and not game.SinglePlayer() then
                if GetConVar("sv_cheats"):GetInt() == 1 then
                    RunConsoleCommand("nav_generate")
                end

                ErrorNoHalt("There is no navmesh! Generate one using \"nav_generate\"!\n")
                return
            end

            if player.GetCount() == game.MaxPlayers() then
                MsgN("[LeadBot] Player limit reached!")
                return
            end

            local original_name
            local generated = "Leadbot #" .. #player.GetBots() + 1
            local model = ""
            local color = Vector(-1, -1, -1)
            local weaponcolor = Vector(0.30, 1.80, 2.10)
            local strategy = 0

            if GetConVar("leadbot_names"):GetString() ~= "" then
                generated = table.Random(string.Split(GetConVar("leadbot_names"):GetString(), ","))
            elseif GetConVar("leadbot_models"):GetString() == "" then
                local name, _ = table.Random(player_manager.AllValidModels())
                local translate = player_manager.TranslateToPlayerModelName(name)
                name = translate

                for _, ply in ipairs(player.GetBots()) do
                    if ply.OriginalName == name or string.lower(ply:Nick()) == name or name_Default[name] and ply:Nick() == name_Default[name] then
                        name = ""
                    end
                end

                if name == "" then
                    local i = 0
                    while name == "" do
                        i = i + 1
                        local str = player_manager.TranslateToPlayerModelName(table.Random(player_manager.AllValidModels()))
                        for _, ply in ipairs(player.GetBots()) do
                            if ply.OriginalName == str or string.lower(ply:Nick()) == str or name_Default[str] and ply:Nick() == name_Default[str] then
                                str = ""
                            end
                        end

                        if str == "" and i < #player_manager.AllValidModels() then continue end
                        name = str
                    end
                end

                original_name = name
                model = name
                name = string.lower(name)
                name = name_Default[name] or name

                local name_Generated = string.Split(name, "/")
                name_Generated = name_Generated[#name_Generated]
                name_Generated = string.Split(name_Generated, " ")

                for i, namestr in ipairs(name_Generated) do
                    name_Generated[i] = string.upper(string.sub(namestr, 1, 1)) .. string.sub(namestr, 2)
                end

                name_Generated = table.concat(name_Generated, " ")
                generated = name_Generated
            end

            if LeadBot.PlayerColor == "default" then
                generated = "Kleiner"
            end

            generated = GetConVar("leadbot_name_prefix"):GetString() .. generated

            local name = LeadBot.Prefix .. generated
            local bot = player.CreateNextBot(name)

            if !IsValid(bot) then
                MsgN("[LeadBot] Unable to create bot!")
                return
            end

            if GetConVar("leadbot_strategy"):GetBool() then
                strategy = math.random(0, LeadBot.Strategies)
            end

            survskill = math.random(0, 1)
            zomskill = math.random(0, 1)

            if LeadBot.PlayerColor ~= "default" then
                if model == "" then
                    if GetConVar("leadbot_models"):GetString() ~= "" then
                        model = table.Random(string.Split(GetConVar("leadbot_models"):GetString(), ","))
                    else
                        model = player_manager.TranslateToPlayerModelName(table.Random(player_manager.AllValidModels()))
                    end
                end

                if color == Vector(-1, -1, -1) then
                    local botcolor = ColorRand()
                    local botweaponcolor = ColorRand()
                    color = Vector(botcolor.r / 255, botcolor.g / 255, botcolor.b / 255)
                    weaponcolor = Vector(botweaponcolor.r / 255, botweaponcolor.g / 255, botweaponcolor.b / 255)
                end
            else
                model = "kleiner"
                color = Vector(0.24, 0.34, 0.41)
            end

            bot.LeadBot_Config = {model, color, weaponcolor, strategy, survskill, zomskill}

            -- for legacy purposes, will be removed soon when gamemodes are updated
            bot.BotStrategy = strategy
            bot.OriginalName = original_name
            bot.ControllerBot = ents.Create("leadbot_navigator")
            bot.ControllerBot:Spawn()
            bot.ControllerBot:SetOwner(bot)
            bot.LeadBot = true
            LeadBot.AddBotOverride(bot)
            LeadBot.AddBotControllerOverride(bot, bot.ControllerBot)
        end
    end

    if not game.SinglePlayer() and leadbot_hordes:GetInt() >= 1 then
        timer.Create("Hordes", 60, -1, function() 
            RunConsoleCommand("leadbot_add", "1")
            INTERMISSION = 0
        end )

        timer.Create("INTERMISSION_MESSAGE", 1, 60, function() 
            PrintMessage( 4, "Infection begins in " .. INTERMISSION_FAKE_TIMER .. " Seconds!")
            INTERMISSION_FAKE_TIMER = INTERMISSION_FAKE_TIMER - 1
        end )
    end

    hook.Add( "PlayerInitialSpawn", "BotSpawnLogic", function( ply )
        if SERVER then 
            if not game.SinglePlayer() then 
                if not ply:IsBot() and leadbot_zchance:GetInt() < 1 and INFLICTION < 0.5 or not ply:IsBot() and leadbot_zchance:GetInt() < 1 and (CurTime() <= GetConVar("zs_roundtime"):GetInt()*0.5 and not GetConVar("zs_human_deadline"):GetBool()) then 
                    timer.Simple(2, function() 
                        ply:Redeem() 
                        if leadbot_mapchanges:GetInt() >= 1 then 
                            if game.GetMap() == "zs_buntshot" then 
                                ply:SetPos( Vector(-520.605774 + math.random(-25, 25), -90.801414 + math.random(-25, 25), -211.968750) ) 
                            elseif game.GetMap() == "zs_snow" then 
                                ply:SetPos( Vector(-566.444092 + math.random(-25, 25), 1023.660217 + math.random(-25, 25), -38.856033) ) 
                            end
                        end
                    end)
                end

                if ply:IsBot() then
                    if GetConVar("leadbot_quota"):GetInt() > 1 and leadbot_hordes:GetInt() < 1 then
                        for k, v in ipairs(player.GetBots()) do 
                            v:Redeem()
                            v:SetMaxHealth(1000000)
                            if leadbot_mapchanges:GetInt() >= 1 then 
                                if game.GetMap() == "zs_buntshot" then 
                                    v:SetPos( Vector(550.256470 + math.random(-25, 25), -595.521240 + math.random(-25, 25), -203.968750) )
                                elseif game.GetMap() == "zs_snow" then 
                                    v:SetPos( Vector(-154.754593 + math.random(-25, 25), 1325.260010 + math.random(-25, 25), -571.968750) )
                                end
                            end
                        end   
                    end
                end

                if leadbot_hordes:GetInt() >= 1 and player.GetCount() == 1 then
                    ply:EmitSound("intermission.mp3", CHAN_REPLACE)
                    timer.Start("Hordes")
                    timer.Start("INTERMISSION_MESSAGE")
                end
                if leadbot_hordes:GetInt() < 1 and player.GetCount() >= 1 then
                    timer.Stop("Hordes")
                    timer.Stop("INTERMISSION_MESSAGE")
                end
            end
        end
    end )

    function LeadBot.AddBotOverride(bot)
        if math.random(2) == 1 then
            timer.Simple(math.random(1, 4), function()
                LeadBot.TalkToMe(bot, "join")
            end)
        end
    end

    function LeadBot.AddBotControllerOverride(bot, controller)
    end

    function LeadBot.Think()
        for _, bot in ipairs(player.GetBots()) do
            if bot:IsLBot() then
                if LeadBot.RespawnAllowed and bot.NextSpawnTime and !bot:Alive() and bot.NextSpawnTime < CurTime() then
                    bot:Spawn()
                    return
                end

                local wep = bot:GetActiveWeapon()
                if IsValid(wep) then
                    local ammoty = wep:GetPrimaryAmmoType() or wep.Primary.Ammo
                    bot:SetAmmo(999, ammoty)
                end
            end
        end
    end

    function LeadBot.PostPlayerDeath(bot)
    end

    function LeadBot.PlayerSpawn(bot)

        --local classes = math.random(1, 8)
        local classes = math.random(1, 6)
        local HALFclasses = math.random(1, 14)
        local UNclasses = math.random(1, 16)

        if bot:Team() == TEAM_ZOMBIE then

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
                if INFLICTION < ZombieClasses[3].Threshold then 
                    if bot:GetZombieClass() ~= 9 then 
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
                elseif INFLICTION >= ZombieClasses[3].Threshold and INFLICTION < ZombieClasses[4].Threshold then
                    if HALFclasses > 7 then 
                        bot:SetZombieClass(2)
                    else
                        if bot:GetZombieClass() ~= 9 then 
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
                elseif INFLICTION >= INFLICTION < ZombieClasses[4].Threshold then
                    if UNclasses > 12 then 
                        bot:SetZombieClass(2)
                    elseif UNclasses <= 12 and UNclasses > 8 then
                        bot:SetZombieClass(4)
                    elseif UNclasses <= 8 then
                        if bot:GetZombieClass() ~= 9 then 
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
                            end
                        end
                    end
                end 
            else
                bot:SetZombieClass(1)
            end
        end
    end

    function LeadBot.PlayerHurt(ply, bot, hp, dmg)

        if bot:IsPlayer() or bot:IsNPC() then
            local controller = ply:GetController()
            local hurtdistance = ply:GetPos():DistToSqr(bot:GetPos())
                
            if hp <= dmg and math.random(2) == 1 and bot:IsPlayer() then
                LeadBot.TalkToMe(bot, "taunt")
            end

            if hp >= dmg and ply:Team() == TEAM_SURVIVOFRS and ply:Health() <= 10 and math.random(10) == 1 then -- don't spam
                LeadBot.TalkToMe(bot, "help")
            end

            if hp >= dmg and ply:Team() == TEAM_SURVIVORS and not bot:IsNPC() and ply:Health() <= 40 and math.random(2) == 1 then -- don't spam
                LeadBot.TalkToMe(bot, "pain")
            end

            if SERVER then 
                if ply:Team() == TEAM_SURVIVORS then 
                    if hp >= dmg and not bot:IsNPC() and bot:Team() ~= ply:Team() or hp >= dmg and bot:IsNPC() then
                        controller.Target = bot
                        controller.ForgetTarget = CurTime() + 4
                    end
                end

                if ply:Team() == TEAM_ZOMBIE then
                    if hp >= dmg and not bot:IsNPC() and bot:Team() ~= ply:Team() and hurtdistance < ply:GetPos():DistToSqr(controller.PosGen) then
                        controller.PosGen = bot:GetPos()
                        controller.LastSegmented = CurTime() + 5 
                        controller.LookAtTime = CurTime() + 2
                        if not bot:IsFrozen() then 
                            controller.LookAt = (bot:GetPos() - ply:GetPos()):Angle()
                        end
                    end
                end

                if ply:Team() == TEAM_ZOMBIE then
                    if hp >= dmg and not bot:IsNPC() and bot:Team() ~= ply:Team() and IsValid(controller.Target) and ply:GetPos():DistToSqr(controller.Target:GetPos()) > hurtdistance then
                        controller.Target = bot
                        controller.ForgetTarget = CurTime() + 4
                    end
                end
            end
        end
    end

    cvars.AddChangeCallback("leadbot_quota", function(_, oldval, val)
        oldval = tonumber(oldval)
        val = tonumber(val)

        if oldval and val and oldval > 0 and val < 1 then
            RunConsoleCommand("leadbot_kick", "all")
        end
    end)

    function LeadBot.StartCommand(bot, cmd)
        if SERVER then 
            local buttons = IN_SPEED
            local botWeapon = bot:GetActiveWeapon()
            local controller = bot.ControllerBot
            local target = controller.Target
            local filterList = {controller, bot, function( ent ) return ( ent:GetClass() == "prop_physics" ) end}

            if !IsValid(controller) then return end

            if LeadBot.NoSprint then
                buttons = 0
            end

            local feet = Vector(0, 0, -29)

            local prt = util.QuickTrace(bot:EyePos(), bot:GetAimVector() * 10000000000, filterList)

            local pot = util.QuickTrace(bot:GetPos(), bot:GetForward() * 10000000000, filterList)

            local pet = util.QuickTrace(bot:GetPos() + feet, bot:GetForward() * 10000000000, filterList)

            local pwrt = util.QuickTrace(bot:GetPos(), bot:GetRight() * 10000000000, filterList)

            local pwlt = util.QuickTrace(bot:GetPos(), bot:GetRight() * -10000000000, filterList)

            local pwdrt = util.QuickTrace(bot:GetPos(), ( bot:GetForward() + bot:GetRight() ) * 10000000000, filterList)

            local pwdlt = util.QuickTrace(bot:GetPos(), ( bot:GetForward() - bot:GetRight() ) * 10000000000, filterList)

            local pwdrat = util.QuickTrace(bot:GetPos(), ( bot:GetForward() + bot:GetRight() ) * -10000000000, filterList)

            local pwdlat = util.QuickTrace(bot:GetPos(), ( bot:GetForward() - bot:GetRight() ) * -10000000000, filterList)

            local ptn = util.QuickTrace(bot:GetPos(), bot:GetForward() * 10000000000 - bot:GetViewOffsetDucked(), filterList)

            local ptp = util.QuickTrace(bot:GetPos(), bot:GetForward() * 10000000000 + bot:GetViewOffsetDucked(), filterList)

            local ptne = util.QuickTrace(bot:GetPos(), bot:GetForward() * 10000000000 - bot:GetViewOffsetDucked() - bot:GetViewOffsetDucked(), filterList)

            local ptpe = util.QuickTrace(bot:GetPos(), bot:GetForward() * 10000000000 + bot:GetViewOffsetDucked() + bot:GetViewOffsetDucked(), filterList)

            if IsValid(prt.Entity) and prt.Entity:IsPlayer() and prt.Entity:Team() ~= bot:Team() then
                if prt.Entity:GetZombieClass() ~= 4 or prt.Entity:GetZombieClass() == 4 and prt.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = prt.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > prt.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = prt.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pot.Entity) and pot.Entity:IsPlayer() and pot.Entity:Team() ~= bot:Team() then
                if pot.Entity:GetZombieClass() ~= 4 or pot.Entity:GetZombieClass() == 4 and pot.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pot.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pot.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pot.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pet.Entity) and pet.Entity:IsPlayer() and pet.Entity:Team() ~= bot:Team() then
                if pet.Entity:GetZombieClass() ~= 4 or pet.Entity:GetZombieClass() == 4 and pet.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pet.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pet.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pet.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pwrt.Entity) and pwrt.Entity:IsPlayer() and pwrt.Entity:Team() ~= bot:Team() then
                if pwrt.Entity:GetZombieClass() ~= 4 or pwrt.Entity:GetZombieClass() == 4 and pwrt.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pwrt.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pwrt.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pwrt.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pwlt.Entity) and pwlt.Entity:IsPlayer() and pwlt.Entity:Team() ~= bot:Team() then
                if pwlt.Entity:GetZombieClass() ~= 4 or pwlt.Entity:GetZombieClass() == 4 and pwlt.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pwlt.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pwlt.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pwlt.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pwdrt.Entity) and pwdrt.Entity:IsPlayer() and pwdrt.Entity:Team() ~= bot:Team() then
                if pwdrt.Entity:GetZombieClass() ~= 4 or pwdrt.Entity:GetZombieClass() == 4 and pwdrt.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pwdrt.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pwdrt.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pwdrt.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pwdlt.Entity) and pwdlt.Entity:IsPlayer() and pwdlt.Entity:Team() ~= bot:Team() then
                if pwdlt.Entity:GetZombieClass() ~= 4 or pwdlt.Entity:GetZombieClass() == 4 and pwdlt.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pwdlt.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pwdlt.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pwdlt.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pwdrat.Entity) and pwdrat.Entity:IsPlayer() and pwdrat.Entity:Team() ~= bot:Team() then
                if pwdrat.Entity:GetZombieClass() ~= 4 or pwdrat.Entity:GetZombieClass() == 4 and pwdrat.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pwdrat.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pwdrat.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pwdrat.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(pwdlat.Entity) and pwdlat.Entity:IsPlayer() and pwdlat.Entity:Team() ~= bot:Team() then
                if pwdlat.Entity:GetZombieClass() ~= 4 or pwdlat.Entity:GetZombieClass() == 4 and pwdlat.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = pwdlat.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > pwdlat.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = pwdlat.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(ptn.Entity) and ptn.Entity:IsPlayer() and ptn.Entity:Team() ~= bot:Team() then
                if ptn.Entity:GetZombieClass() ~= 4 or ptn.Entity:GetZombieClass() == 4 and ptn.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = ptn.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > ptn.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = ptn.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(ptp.Entity) and ptp.Entity:IsPlayer() and ptp.Entity:Team() ~= bot:Team() then
                if ptp.Entity:GetZombieClass() ~= 4 or ptp.Entity:GetZombieClass() == 4 and ptp.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = ptp.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > ptp.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = ptp.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(ptne.Entity) and ptne.Entity:IsPlayer() and ptne.Entity:Team() ~= bot:Team() then
                if ptne.Entity:GetZombieClass() ~= 4 or ptne.Entity:GetZombieClass() == 4 and ptne.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = ptne.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > ptne.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = ptne.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if IsValid(ptpe.Entity) and ptpe.Entity:IsPlayer() and ptpe.Entity:Team() ~= bot:Team() then
                if ptpe.Entity:GetZombieClass() ~= 4 or ptpe.Entity:GetZombieClass() == 4 and ptpe.Entity:GetPos():DistToSqr(bot:GetPos()) > 67500 then
                    if !IsValid(target) then
                        controller.Target = ptpe.Entity
                        controller.ForgetTarget = CurTime() + 4
                    else
                        if target:GetPos():DistToSqr(bot:GetPos()) > ptpe.Entity:GetPos():DistToSqr(bot:GetPos()) then  
                            controller.Target = ptpe.Entity
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end

            if bot:Team() == TEAM_SURVIVORS then 
                if IsValid(botWeapon) then 
                    if !IsValid(target) then
                        if math.random(2) == 1 and botWeapon:Clip1() <= (botWeapon:GetMaxClip1() / 4) and leadbot_hinfammo:GetInt() < 1 then 
                            buttons = buttons + IN_RELOAD
                        end
                    else
                        if math.random(2) == 1 then
                            if botWeapon:Clip1() ~= 0 and ( not target:IsPlayer() or target:IsPlayer() and ( target:GetPos():DistToSqr(bot:GetPos()) > 67500 and target:GetZombieClass() == 4 or target:GetZombieClass() ~= 4 ) ) then 
                                buttons = buttons + IN_ATTACK
                            else
                                if leadbot_hinfammo:GetInt() < 1 then 
                                    buttons = buttons + IN_RELOAD
                                end
                            end
                        end
                    end
                end
            else
                if IsValid(target) then
                    if math.random(2) == 1 then 
                        if bot:GetZombieClass() > 5 and bot:GetZombieClass() < 9 then 
                            if target == prt.Entity then 
                                buttons = buttons + IN_ATTACK
                            end
                        else
                            if target:GetPos():DistToSqr(bot:GetPos()) < 10750 then 
                                buttons = buttons + IN_ATTACK
                            end
                        end
                    else
                        if target:IsPlayer() and target == prt.Entity and bot:LBGetZomSkill() == 1 then 
                            if bot:GetZombieClass() == 3 or bot:GetZombieClass() == 8 then
                                if target:GetPos():DistToSqr(bot:GetPos()) <= 90000 then 
                                    buttons = buttons + IN_ATTACK2
                                end
                            elseif bot:GetZombieClass() == 2 then 
                                if bot:IsOnGround() then 
                                    buttons = buttons + IN_ATTACK2
                                end
                            else
                                buttons = buttons + IN_ATTACK2
                            end
                        end
                    end
                end

                if !IsValid(target) and bot:LBGetZomSkill() == 1 then
                    if math.random(100) == 1 then 
                        if bot:IsOnGround() and ( bot:GetZombieClass() > 3 or bot:GetZombieClass() < 3 ) and ( bot:GetZombieClass() > 8 or bot:GetZombieClass() < 8 ) then
                            buttons = buttons + IN_ATTACK2
                        end
                    end
                    if math.random(100) == 1 and bot:GetZombieClass() > 5 and bot:GetZombieClass() < 9 then 
                        buttons = buttons + IN_ATTACK
                    end
                end
            end

            if bot:GetMoveType() == MOVETYPE_LADDER then
                local pos = controller.goalPos
                local ang = ((pos + bot:GetCurrentViewOffset()) - bot:GetShootPos()):Angle()

                if pos.z > controller:GetPos().z then
                    if not bot:IsFrozen() then 
                        controller.LookAt = Angle(-30, ang.y, 0)
                    end
                else
                    if not bot:IsFrozen() then 
                        controller.LookAt = Angle(30, ang.y, 0)
                    end
                end

                controller.LookAtTime = CurTime() + 0.1
                controller.NextJump = -1
                buttons = buttons + IN_FORWARD
            end

            if !IsValid(controller.Target) and bot:Team() == TEAM_SURVIVORS or bot:Team() == TEAM_ZOMBIE and not bot:IsFrozen() then
                if controller.NextDuck > CurTime() then
                    buttons = buttons + IN_DUCK
                elseif controller.NextJump == 0 then
                    controller.NextJump = CurTime() + 1
                    buttons = buttons + IN_JUMP
                end
            end

            if !IsValid(controller.Target) and bot:Team() == TEAM_SURVIVORS and controller.PosGen == nil then 
                buttons = buttons + IN_DUCK
            end

            if bot:GetVelocity():Length2DSqr() <= 225 and not bot:IsFrozen() and bot:GetMoveType() ~= MOVETYPE_LADDER and controller.PosGen ~= nil then 
                if target == nil or IsValid(target) and not target:IsPlayer() and target:Health() <= 0 and controller.PosGen ~= nil then 
                    if math.random(2) == 1 then 
                        buttons = buttons + IN_JUMP
                    end
                    if bot:Team() == TEAM_ZOMBIE then 
                        if bot:GetZombieClass() > 5 or bot:GetZombieClass() < 5 then
                            if math.random(2) == 1 then 
                                buttons = buttons + IN_ATTACK
                            end
                        end
                    end
                end
            end 

            if !bot:IsOnGround() and bot:WaterLevel() == 0 then
                buttons = buttons + IN_DUCK
            end

            cmd:ClearButtons()
            cmd:ClearMovement()
            cmd:SetButtons(buttons)
        end
    end

    if game.GetMap() == "zs_panic_house_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -978.400330, -106.284340, -88.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -848.922302, 241.240997, -336.702820 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -852.891663, -354.968750, 44.423325 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_termites_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 211.732071, 175.968750, 200.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 16.586996, 175.968750, 200.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 207.748230, 152.171402, 8.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_nastyhouse_v3" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 207.968750, -46.968750, -115.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 18.031250, -46.968750, -115.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 173.972610, 301.984589, -248.664764 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_lila_panic_v3" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 1244.166870, -1199.631958, 14.639694 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -1150.797241, -480.031250, -263.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -1167.968750, -879.030090, -263.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_villagehouse" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 106.208763, 767.968750, 72.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 343.968750, 767.968750, 72.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -523.968750, 575.968750, -167.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_afterseven_b" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 1535.968750, -1011.665894, -311.585205 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 967.568176, -1371.968750, -311.612701 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 896.549072, -211.911438, -135.694901 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_alexg_motel_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -615.968750, -260.337250, 136.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -615.999512, -254.953094, 8.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 262.041504, 359.978241, 8.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_ancient_castle_opt" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -73.241646, 2143.968750, 73.392014 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -670.902710, 656.014404, 73.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 187.444870, 2143.969971, 73.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_bunkerhouse" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -272.031250, 465.928040, -543.692566 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -679.969543, 602.923401, -135.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 200.511887, 607.978943, 8.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_bog_pubremakev1" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -442.031708, 249.968750, 249.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -392.031250, 383.521484, 249.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -752.008972, -17.133949, 249.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_bog_shityhouse" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -802.421753, 802.331543, 178.334702 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -758.031250, 890.733582, 177.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -800.402588, 1085.998535, 177.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_buntshot" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -1071.968750, -915.182922, -167.646179 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 297.207031, 840.505127, -375.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 336.741394, 726.400574, -375.648926 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_ascent" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 38.766651, 3.002626, 8.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -33.282291, -10.531364, 10.163082 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -991.968750, 991.968750, -55.462624 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_citadel_b4" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 520.074707, -2320.178223, 830.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 1016.000366, 850.968750, 1173.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 526.298279, -1739.576782, 1029.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_clav_maze" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -700.419800, 479.968750, 8.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -440.255951, -1454.927612, 9.737734 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -148.479843, -1243.997925, 8.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_clav_wall" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 150.420959, -1033.067261, 12.820862 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 1007.968750, 1391.968750, 29.858105 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -80.031250, -1453.781982, 19.747452 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_coasthouse" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -331.667023, 167.968750, 392.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -759.968750, -87.859299, 392.389954 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -97.217529, 167.999161, 264.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_deadblock_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 1023.693481, 2019.718750, -54.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 1104.311890, 1027.968750, 81.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 900.198730, -821.849854, 72.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_embassy" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 1148.922974, -1234.330566, 280.021942 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -278.965271, -1260.968750, 280.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 383.919495, -1092.835938, 122.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_fen" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -503.968750, 367.212708, 144.978729 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 167.968750, 361.545258, 144.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -127.914909, 18.031250, 144.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_gu_frostbite_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -1190.614258, 176.031250, 213.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -1434.279785, 181.031250, 212.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -1181.794556, 720.031250, 458.789459 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_house_number_23" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 586.667969, -469.422455, 216.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 938.991272, -365.968750, 216.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 534.031250, 26.832447, 216.03125 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_house_outbreak_b2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -231.968750, -141.968750, -107.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -173.720093, -141.968750, -107.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -112.031250, -141.968750, -107.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_imashouse_b2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -16.031250, 114.031250, -216.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -250.976242, 967.968750, -80.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 257.784760, 704.617065, 55.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_jail_v1" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -367.968750, -1343.254639, 8.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -96.164764, 2086.968750, 8.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -32.028828, 387.612549, 152.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_lakefront_alpha" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 1090.031250, 1819.968750, 14.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 1248.631714, 1820.729858, 14.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 1463.968750, 1879.968750, 14.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_mall_dl" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -2235.709717, 512.017944, -1583.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -2520.031250, 1086.488770, -1375.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -1750.003784, 224.031250, -1375.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_nastierhouse_v3" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -231.972427, -993.609375, -1015.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 281.125427, -1383.968750, -887.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -295.974670, -1042.085693, -887.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_nastiesthouse_v3" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 3746.718750, 5485.471680, -71.612259 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 4124.910156, 5464.471680, 72.387749 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 2666.046631, 4905.451172, 23.005402 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_nastyvillage" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 435.101105, -255.880249, 38.137650 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -875.099792, -741.297302, 64.513748 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -217.029633, 70.787254, 62.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_overandunderground_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -102.808205, 3071.968750, 216.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -42.848648, 2375.030029, 80.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -490.968750, 3106.968750, -55.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_placid" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -4067.968750, 24.031250, 212.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -3832.024902, 292.063232, 212.740753 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -4351.968750, 32.031250, 76.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_port_v5" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 145.955414, 2538.188477, -1141.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 791.228638, 2359.968750, -1015.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -1267.968750, 2268.495361, -1131.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_prc_wurzel_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 783.968750, -979.968750, 664.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 383.240173, -975.968750, 276.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 803.999329, -149.608978, 276.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_pub" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -750.578125, 451.991974, 196.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -411.031250, -45.968750, 196.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -648.743408, 298.968750, 41.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_raunchierhouse_v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -152.031250, -863.968750, 152.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 95.968750, -743.990723, 8.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -311.968750, -224.031250, 8.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_raunchyhouse_v3" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 2800.658691, -3041.973633, -431.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 3142.968750, -2577.031250, -431.968750 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 2926.272705, -2578.031250, -431.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_residentevil2v2" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -387.194305, -175.968750, 456.031250 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -386.796783, -175.986252, 280.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 1103.560303, 994.453369, 280.018341 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_the_pub_beta1" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( 3254.968750, -3183.968750, 1.100634 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( -346.067688, 896.031250, 136.031250 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( 375.968750, 1338.854492, 136.031250 ) )
        sigil1:Spawn()
        sigil1Valid = true

    elseif game.GetMap() == "zs_snow" then 

        sigil3 = ents.Create( "prop_dynamic" )
        sigil3:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil3:SetPos( Vector( -545.536194, 1121.322632, -223.968750 ) )
        sigil3:Spawn()
        sigil3Valid = true

        sigil2 = ents.Create( "prop_dynamic" )
        sigil2:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil2:SetPos( Vector( 174.030350, 980.480957, -597.033875 ) )
        sigil2:Spawn()
        sigil2Valid = true

        sigil1 = ents.Create( "prop_dynamic" )
        sigil1:SetModel( "models/dav0r/buttons/button.mdl" )
        sigil1:SetPos( Vector( -432.845428, 948.031250, -607.968750 ) )
        sigil1:Spawn()
        sigil1Valid = true

    end

    local testing = 0

    if testing == 0 then 
        if sigil3Valid then 
            sigil3:SetNoDraw(true)
        end
        if sigil2Valid then 
            sigil2:SetNoDraw(true)
        end
        if sigil1Valid then 
            sigil1:SetNoDraw(true)
        end
    else
        sigil3:SetNoDraw(false)
        sigil2:SetNoDraw(false)
        sigil1:SetNoDraw(false)
    end

    function LeadBot.PlayerMove(bot, cmd, mv)

        if SERVER then 
            local controller = bot.ControllerBot

            local openvar = math.random(-90, 90)
            local hallvar = math.random(-45, 45)
            local doorvar = math.random(-15, 15)

                if !IsValid(controller.Target) and bot:Team() == TEAM_SURVIVORS then
                    if bot:LBGetStrategy() == 1 and sigil3Valid then 
                        if bot:GetPos():DistToSqr(sigil3:GetPos()) <= 5000 then 
                            if game.GetMap() == "zs_panic_house_v2" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_termites_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_nastyhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_lila_panic_v3" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_villagehouse" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_afterseven_b" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_alexg_motel_v2" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_ancient_castle_opt" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_bunkerhouse" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_bog_pubremakev1" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_bog_shityhouse" then 
                                bot:SetEyeAngles(Angle(0, 180 + doorvar, 0))
                            elseif game.GetMap() == "zs_buntshot" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_ascent" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_citadel_b4" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_clav_maze" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_clav_wall" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_coasthouse" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_deadblock_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_embassy" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_fen" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_gu_frostbite_v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_house_number_23" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_house_outbreak_b2" then 
                                bot:SetEyeAngles(Angle(0, 45 + openvar, 0))
                            elseif game.GetMap() == "zs_imashouse_b2" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_jail_v1" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_lakefront_alpha" then 
                                bot:SetEyeAngles(Angle(0, 315 + openvar, 0))
                            elseif game.GetMap() == "zs_mall_dl" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_nastierhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastiesthouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastyvillage" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_overandunderground_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_placid" then 
                                bot:SetEyeAngles(Angle(0, 45 + openvar, 0))
                            elseif game.GetMap() == "zs_port_v5" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_prc_wurzel_v2" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_pub" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_raunchierhouse_v2" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_raunchyhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_residentevil2v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_the_pub_beta1" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_snow" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            end
                        end
                    elseif bot:LBGetStrategy() == 2 and sigil2Valid then 
                        if bot:GetPos():DistToSqr(sigil2:GetPos()) <= 5000 then  
                            if game.GetMap() == "zs_panic_house_v2" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_lila_panic_v3" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_bog_pubremakev1" then 
                                bot:SetEyeAngles(Angle(0, 180 + doorvar, 0))
                            elseif game.GetMap() == "zs_bunkerhouse" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_bog_shityhouse" then 
                                bot:SetEyeAngles(Angle(0, 180 + doorvar, 0))
                            elseif game.GetMap() == "zs_buntshot" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_afterseven_b" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_ascent" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_ancient_castle_opt" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_alexg_motel_v2" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_citadel_b4" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_clav_maze" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_clav_wall" then 
                                bot:SetEyeAngles(Angle(0, 225 + openvar, 0))
                            elseif game.GetMap() == "zs_coasthouse" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_deadblock_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_embassy" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_fen" then 
                                bot:SetEyeAngles(Angle(0, 180 + doorvar, 0))
                            elseif game.GetMap() == "zs_gu_frostbite_v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_house_number_23" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_house_outbreak_b2" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_imashouse_b2" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_jail_v1" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_lakefront_alpha" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_mall_dl" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastierhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_nastiesthouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastyhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 45 + openvar, 0))
                            elseif game.GetMap() == "zs_nastyvillage" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_overandunderground_v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_placid" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_port_v5" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_prc_wurzel_v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_pub" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_raunchierhouse_v2" then 
                                bot:SetEyeAngles(Angle(0, 135 + openvar, 0))
                            elseif game.GetMap() == "zs_raunchyhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 225 + openvar, 0))
                            elseif game.GetMap() == "zs_residentevil2v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_termites_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_the_pub_beta1" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_villagehouse" then 
                                bot:SetEyeAngles(Angle(0, 225 + openvar, 0))
                            elseif game.GetMap() == "zs_snow" then 
                                bot:SetEyeAngles(Angle(0, 112.5 + hallvar, 0))
                            end
                        end
                    elseif bot:LBGetStrategy() == 3 and sigil1Valid then  
                        if bot:GetPos():DistToSqr(sigil1:GetPos()) <= 5000 then 
                            if game.GetMap() == "zs_panic_house_v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_lila_panic_v3" then 
                                bot:SetEyeAngles(Angle(0, 0 + openvar, 0))
                            elseif game.GetMap() == "zs_bog_pubremakev1" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_bunkerhouse" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_bog_shityhouse" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_buntshot" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_afterseven_b" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_ascent" then 
                                bot:SetEyeAngles(Angle(0, 315 + openvar, 0))
                            elseif game.GetMap() == "zs_ancient_castle_opt" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_alexg_motel_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_citadel_b4" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_clav_maze" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_clav_wall" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_coasthouse" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_deadblock_v2" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_embassy" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_fen" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_gu_frostbite_v2" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_house_number_23" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_house_outbreak_b2" then 
                                bot:SetEyeAngles(Angle(0, 90 + doorvar, 0))
                            elseif game.GetMap() == "zs_imashouse_b2" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_jail_v1" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_lakefront_alpha" then 
                                bot:SetEyeAngles(Angle(0, 225 + openvar, 0))
                            elseif game.GetMap() == "zs_mall_dl" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastierhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 0 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastiesthouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_nastyhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_nastyvillage" then 
                                bot:SetEyeAngles(Angle(0, 180 + doorvar, 0))
                            elseif game.GetMap() == "zs_overandunderground_v2" then 
                                bot:SetEyeAngles(Angle(0, 315 + openvar, 0))
                            elseif game.GetMap() == "zs_placid" then 
                                bot:SetEyeAngles(Angle(0, 45 + openvar, 0))
                            elseif game.GetMap() == "zs_port_v5" then 
                                bot:SetEyeAngles(Angle(0, 0 + doorvar, 0))
                            elseif game.GetMap() == "zs_prc_wurzel_v2" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_pub" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_raunchierhouse_v2" then 
                                bot:SetEyeAngles(Angle(0, 315 + openvar, 0))
                            elseif game.GetMap() == "zs_raunchyhouse_v3" then 
                                bot:SetEyeAngles(Angle(0, 270 + hallvar, 0))
                            elseif game.GetMap() == "zs_residentevil2v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_termites_v2" then 
                                bot:SetEyeAngles(Angle(0, 270 + doorvar, 0))
                            elseif game.GetMap() == "zs_the_pub_beta1" then 
                                bot:SetEyeAngles(Angle(0, 180 + hallvar, 0))
                            elseif game.GetMap() == "zs_villagehouse" then 
                                bot:SetEyeAngles(Angle(0, 315 + openvar, 0))
                            elseif game.GetMap() == "zs_snow" then 
                                bot:SetEyeAngles(Angle(0, 90 + hallvar, 0))
                            end
                        end
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

            if leadbot_hordes:GetInt() >= 1 and bot:Team() == TEAM_SURVIVORS and GetConVar("leadbot_quota"):GetInt() < 2 then 
                bot:Kill()
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

            if bot:LBGetStrategy() > 0 and bot:Team() == TEAM_SURVIVORS then 
                if controller.Target == nil then 
                    mv:SetForwardSpeed(1200)
                end
            else
                mv:SetForwardSpeed(1200)
            end

            if (bot.NextSpawnTime and bot.NextSpawnTime + 1 > CurTime()) or !IsValid(controller.Target) or controller.ForgetTarget < CurTime() or controller.Target:Health() < 1 then
                controller.Target = nil
            end

            if !IsValid(controller.Target) then
                for _, ply in RandomPairs(player.GetAll()) do
                    if ply ~= bot and ply:Team() ~= bot:Team() and ply:Alive() and IsValid(ply) and ply:GetPos():DistToSqr(bot:GetPos()) <= 1200 then
                        controller.Target = ply
                        controller.ForgetTarget = CurTime() + 4
                    end
                end
            elseif controller.ForgetTarget < CurTime() and pet.Entity == controller.Target then
                controller.ForgetTarget = CurTime() + 4
            end

            local dt = util.QuickTrace(bot:EyePos(), bot:GetForward() * 90, bot)

            local dtn = util.QuickTrace(bot:EyePos(), bot:GetForward() * 90 - bot:GetViewOffsetDucked(), bot)

            local dtp = util.QuickTrace(bot:EyePos(), bot:GetForward() * 90 + bot:GetViewOffsetDucked(), bot)

            local dtnse = util.QuickTrace(bot:EyePos(), bot:GetForward() * 90 - bot:GetViewOffsetDucked() - bot:GetViewOffsetDucked() - bot:GetViewOffsetDucked(), bot)

            local dtpse = util.QuickTrace(bot:EyePos(), bot:GetForward() * 90 + bot:GetViewOffsetDucked() + bot:GetViewOffsetDucked() + bot:GetViewOffsetDucked(), bot)

            if game.GetMap() == "zs_jail_v1" then 
                if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_door_rotating" then
                    dt.Entity:Fire("Break", bot, 0)
                end
            end

            if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_movelinear" then
                if dt.Entity:GetName() ~= "BunkerDoor" then
                    dt.Entity:Fire("Open", bot, 0)
                else
                    dt.Entity:Fire("Close", bot, 0)
                end
            end

            if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_breakable" then
                if bot:Team() == TEAM_ZOMBIE or survivorBreak then
                    controller.Target = dt.Entity
                end
            end

            if IsValid(dtn.Entity) and dtn.Entity:GetClass() == "func_breakable" then
                if not zombieBreakCheck then
                    if bot:Team() == TEAM_ZOMBIE or survivorBreak then
                        controller.Target = dtn.Entity
                    end
                end
            end

            if IsValid(dtp.Entity) and dtp.Entity:GetClass() == "func_breakable" then
                if not zombieBreakCheck then
                    if bot:Team() == TEAM_ZOMBIE or survivorBreak then
                        controller.Target = dtp.Entity
                    end
                end
            end

            if IsValid(dtnse.Entity) and dtnse.Entity:GetClass() == "func_breakable" then
                    if not zombieBreakCheck then
                        if bot:Team() == TEAM_ZOMBIE or survivorBreak then
                            controller.Target = dtnse.Entity
                        end
                    end
                end

            if IsValid(dtpse.Entity) and dtpse.Entity:GetClass() == "func_breakable" then
                if not zombieBreakCheck then
                    if bot:Team() == TEAM_ZOMBIE or survivorBreak then
                        controller.Target = dtpse.Entity
                    end
                end
            end

            if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_physbox" then
                if bot:Team() == TEAM_ZOMBIE and ( IsValid(controller.Target) and not controller.Target:IsPlayer() and controller.Target:GetClass() ~= "func_breakable" or controller.Target == nil ) or survivorBoxBreak and dt.Entity:Health() > 1 then
                    controller.Target = dt.Entity
                end
            end

            if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_physics" then
                if bot:Team() == TEAM_ZOMBIE and ( IsValid(controller.Target) and not controller.Target:IsPlayer() and controller.Target:GetClass() ~= "func_breakable" or controller.Target == nil ) then
                    if dt.Entity:GetModel() ~= "models/props_c17/playground_carousel01.mdl" then 
                        if dt.Entity:GetModel() ~= "models/props_wasteland/prison_lamp001a.mdl" then
                            if not zombiePropCheck then
                                controller.Target = dt.Entity
                            end
                        end
                    end
                end
            end

            if bot:GetMoveType() == MOVETYPE_LADDER then 
                if IsValid(dtpse.Entity) and dtpse.Entity:GetClass() == "prop_physics" then
                    if bot:Team() == TEAM_ZOMBIE and ( IsValid(controller.Target) and not controller.Target:IsPlayer() and controller.Target:GetClass() ~= "func_breakable" or controller.Target == nil ) then
                        if dtpse.Entity:GetModel() ~= "models/props_c17/playground_carousel01.mdl" then 
                            if dtpse.Entity:GetModel() ~= "models/props_wasteland/prison_lamp001a.mdl" then
                                if not zombiePropCheck then
                                    controller.Target = dt.Entity
                                end
                            end
                        end
                    end
                end
            end

            if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_breakable_surf" then
                controller.Target = dt.Entity
            end

            if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_dynamic" and dt.Entity:Health() > 0 then
                controller.Target = dt.Entity
            end

            if DEBUG then
                debugoverlay.Text(bot:EyePos(), bot:Nick(), 0.03, false)
                local min, max = bot:GetHull()
                debugoverlay.Box(bot:GetPos(), min, max, 0.03, Color(255, 255, 255, 0))
            end

            if !IsValid(controller.Target) and (!controller.PosGen or bot:GetPos():DistToSqr(controller.PosGen) < 1000 or controller.LastSegmented < CurTime()) then
            -- find a random spot on the map if human, and then do it again in 5 seconds!
                if bot:Team() == TEAM_SURVIVORS and bot:LBGetStrategy() == 0 then
                    if bot:LBGetSurvSkill() == 0 then 
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                    end
                    controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                    controller.LastSegmented = CurTime() + 5
                elseif bot:Team() == TEAM_SURVIVORS and bot:LBGetStrategy() == 1 then 
                    if leadbot_freeroam:GetInt() < 1 then 
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
                            for k, v in RandomPairs(player.GetAll()) do 
                                if IsValid(v) and v:Team() == TEAM_SURVIVORS then 
                                    controller.PosGen = v:GetPos()
                                    controller.LastSegmented = CurTime() + 1000000
                                end
                            end
                        end
                    else
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                        controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                        controller.LastSegmented = CurTime() + 5
                    end
                elseif bot:Team() == TEAM_SURVIVORS and bot:LBGetStrategy() == 2 then
                    if leadbot_freeroam:GetInt() < 1 then 
                        if sigil2Valid then 
                            local dist = bot:GetPos():DistToSqr(sigil2:GetPos())
                                if dist <= 2500 then -- we're here
                                    controller.PosGen = nil
                                else -- we need to run...
                                    controller.PosGen = sigil2:GetPos()
                                end

                            controller.LastSegmented = CurTime() + 1
                        else
                            for k, v in RandomPairs(player.GetAll()) do 
                                if IsValid(v) and v:Team() == TEAM_SURVIVORS then 
                                    controller.PosGen = v:GetPos()
                                    controller.LastSegmented = CurTime() + 1000000
                                end
                            end
                        end
                    else
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                        controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                        controller.LastSegmented = CurTime() + 5
                    end
                elseif bot:Team() == TEAM_SURVIVORS and bot:LBGetStrategy() == 3 then
                    if leadbot_freeroam:GetInt() < 1 then 
                        if sigil1Valid then 
                            local dist = bot:GetPos():DistToSqr(sigil1:GetPos())
                                if dist <= 2500 then -- we're here
                                    controller.PosGen = nil
                                else -- we need to run...
                                    controller.PosGen = sigil1:GetPos()
                                end

                            controller.LastSegmented = CurTime() + 1
                        else
                            for k, v in RandomPairs(player.GetAll()) do 
                                if IsValid(v) and v:Team() == TEAM_SURVIVORS then 
                                    controller.PosGen = v:GetPos()
                                    controller.LastSegmented = CurTime() + 1000000
                                end
                            end
                        end
                    else
                        bot:SelectWeapon("weapon_zs_swissarmyknife")
                        controller.PosGen = controller:FindSpot("random", {radius = 1000000})
                        controller.LastSegmented = CurTime() + 5
                    end
                end
                -- find survivor position
                if bot:Team() == TEAM_ZOMBIE and team.NumPlayers(TEAM_SURVIVORS) ~= 0 then
                    for k, v in RandomPairs(player.GetAll()) do 
                        if IsValid(v) and v:Team() == TEAM_SURVIVORS then 
                            controller.PosGen = v:GetPos()
                            controller.LastSegmented = CurTime() + 1000000
                        end
                    end
                end
            elseif IsValid(controller.Target) then
                -- move to our target
                local distance = controller.Target:GetPos():DistToSqr(bot:GetPos())
                if controller.Target:IsPlayer() then 
                    controller.PosGen = controller.Target:GetPos()
                end

                -- back up if the target is really close
                -- TODO: find a random spot rather than trying to back up into what could just be a wall
                -- something like controller.PosGen = controller:FindSpot("random", {pos = bot:GetPos() - bot:GetForward() * 350, radius = 1000})?

                if controller.Target:IsPlayer() then 
                    if bot:Team() == TEAM_ZOMBIE then 
                        mv:SetForwardSpeed(1200)
                        if distance > 45000 and bot:LBGetZomSkill() == 1 then
                            if controller.strafeAngle == 1 then
                                mv:SetSideSpeed(1500)
                            elseif controller.strafeAngle == 2 then
                                mv:SetSideSpeed(-1500)
                            end
                        end
                    else
                        if bot:LBGetStrategy() == 0 or leadbot_freeroam:GetInt() >= 1 then 
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
                            if bot:LBGetSurvSkill() == 0 then
                                if controller.strafeAngle == 1 then
                                    mv:SetSideSpeed(1500)
                                elseif controller.strafeAngle == 2 then
                                    mv:SetSideSpeed(-1500)
                                end
                            end
                        else
                            if distance <= 45000 then 
                                mv:SetForwardSpeed(-1200)
                                if controller.strafeAngle == 1 then
                                    mv:SetSideSpeed(1500)
                                elseif controller.strafeAngle == 2 then
                                    mv:SetSideSpeed(-1500)
                                end
                            end
                            if bot:Health() <= 40 then 
                                if controller.Target:GetZombieClass() == 2 or controller.Target:GetZombieClass() > 5 and controller.Target:GetZombieClass() < 9 then 
                                    if controller.strafeAngle == 1 then
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

                local tier2 = GetConVar("zs_rewards_1"):GetInt()
                local tier3 = GetConVar("zs_rewards_3"):GetInt()
                local tier4 = GetConVar("zs_rewards_4"):GetInt()

                if bot:Team() == TEAM_SURVIVORS and distance > 30000 then 
                    if bot:Frags() < tier2 then 
                        bot:SelectWeapon("weapon_zs_battleaxe")
                        bot:SelectWeapon("weapon_zs_peashooter")
                    elseif bot:Frags() >= tier2 and bot:Frags() < tier3 then
                    bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_magnum")
                        bot:SelectWeapon("weapon_zs_glock3")
                    elseif bot:Frags() >= tier3 then
                        bot:SelectWeapon("weapon_zs_uzi")
                        bot:SelectWeapon("weapon_zs_smg")
                    end
                elseif bot:Team() == TEAM_SURVIVORS and distance <= 30000 then 
                    if bot:Frags() < tier2 then 
                        bot:SelectWeapon("weapon_zs_battleaxe")
                        bot:SelectWeapon("weapon_zs_peashooter")
                    elseif bot:Frags() >= tier2 and bot:Frags() < tier3 then
                        bot:SelectWeapon("weapon_zs_deagle")
                        bot:SelectWeapon("weapon_zs_magnum")
                        bot:SelectWeapon("weapon_zs_glock3")
                    elseif bot:Frags() >= tier3 and bot:Frags() < tier4 then
                        bot:SelectWeapon("weapon_zs_uzi")
                        bot:SelectWeapon("weapon_zs_smg")
                    elseif bot:Frags() >= tier4 then
                        bot:SelectWeapon("weapon_zs_sweepershotgun")
                    end
                end
                if bot:Team() == TEAM_ZOMBIE and distance <= 1000000000 then 
                    mv:SetForwardSpeed(1200)
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
            local lerp = FrameTime() * math.random(8, 10)
            local lerpc = FrameTime() * 8
            local mva

            if !LeadBot.LerpAim then
                lerp = 1
                lerpc = 1
            end

            -- got nowhere to go, why keep moving?
            if curgoal then
                -- think every step of the way!
                if segments[cur_segment + 1] and Vector(bot:GetPos().x, bot:GetPos().y, 0):DistToSqr(Vector(curgoal.pos.x, curgoal.pos.y)) < 100 then
                    controller.cur_segment = controller.cur_segment + 1
                    curgoal = segments[controller.cur_segment]
                end

                local goalpos = curgoal.pos

                if bot:GetVelocity():Length2DSqr() <= 225 and not bot:IsFrozen() then
                    if !IsValid(controller.Target) and bot:Team() == TEAM_SURVIVORS or bot:Team() == TEAM_ZOMBIE then
                        if controller.nextStuckJump < CurTime() then
                            if !bot:Crouching() then
                                controller.NextJump = 0
                            end
                            controller.nextStuckJump = CurTime() + math.Rand(1, 2)
                        end
                    end
                end

                if controller.NextCenter < CurTime() then
                    if bot:GetVelocity():Length2DSqr() <= 225 or IsValid(controller.Target) then
                        if not bot:IsFrozen() then 
                            controller.strafeAngle = ((controller.strafeAngle == 1 and 2) or 1)
                            controller.NextCenter = CurTime() + math.Rand(0.3, 0.9)
                        end
                    end
                end

                if controller.NextCenter > CurTime() then
                    if curgoal.area:GetAttributes() ~= NAV_MESH_JUMP and bot:GetVelocity():Length2DSqr() <= 10000 and ( !IsValid(controller.Target) and bot:GetMoveType() ~= MOVETYPE_LADDER and not bot:IsFrozen() or bot:Team() == TEAM_SURVIVORS and IsValid(controller.Target) and ( bot:LBGetStrategy() == 0 or leadbot_freeroam:GetInt() >= 1 ) or bot:Team() == TEAM_ZOMBIE and IsValid(controller.Target) and bot:LBGetStrategy() > 1 ) then
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

                -- jump
                if controller.NextJump ~= 0 and curgoal.type > 1 and controller.NextJump < CurTime() or controller.NextJump ~= 0 and curgoal.area:GetAttributes() == NAV_MESH_JUMP and controller.NextJump < CurTime() then
                    controller.NextJump = 0
                end

                -- duck
                if curgoal.area:GetAttributes() == NAV_MESH_CROUCH or IsValid(dtnse.Entity) then
                    controller.NextDuck = CurTime() + 0.1
                end

                controller.goalPos = goalpos

                if DEBUG then
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
                    if controller.Target:GetZombieClass() < 2 or controller.Target:GetZombieClass() == 5 then
                        bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
                    end
                    if controller.Target:GetZombieClass() >= 2 and controller.Target:GetZombieClass() < 5 then
                        if !controller.Target:Crouching() then 
                            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
                        else
                            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
                        end
                    end
                    if controller.Target:GetZombieClass() >= 6 then
                        if !controller.Target:Crouching() then 
                            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
                        else
                            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
                        end
                    end
                else 
                    if not bot:IsFrozen() then 
                        bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
                    end
                end
                return
            elseif IsValid(controller.Target) and not controller.Target:IsPlayer() then
                if not bot:IsFrozen() then 
                    bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:GetPos() - bot:GetShootPos()):Angle()))
                end
            elseif curgoal then
                if controller.LookAtTime > CurTime() then
                    local ang = LerpAngle(lerpc, bot:EyeAngles(), controller.LookAt)
                    if not bot:IsFrozen() then 
                        bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
                    end
                else
                    local ang = LerpAngle(lerpc, bot:EyeAngles(), mva)
                    if not bot:IsFrozen() then 
                        bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
                    end
                end
            end
        end
    end

    hook.Add("PlayerDisconnected", "LeadBot_Disconnect", function(bot)
        if SERVER then
            if IsValid(bot.ControllerBot) then
                bot.ControllerBot:Remove()
            end
        end
    end)

    hook.Add("SetupMove", "LeadBot_Control", function(bot, mv, cmd)
        if SERVER then
            if bot:IsLBot() then
                LeadBot.PlayerMove(bot, cmd, mv)
            end
        end
    end)

    hook.Add("StartCommand", "LeadBot_Control", function(bot, cmd)
        if SERVER then
            if bot:IsLBot() then
                LeadBot.StartCommand(bot, cmd)
            end
        end
    end)

    hook.Add("PostPlayerDeath", "LeadBot_Death", function(bot)
        if SERVER then
            if bot:IsLBot() then
                LeadBot.PostPlayerDeath(bot)
            end
        end
    end)

    -- Credit goes out to 女儿 for this infinite ammo code :D --

    local n = 1

    function InfiniteAmmoForSurvivorBots()
        if leadbot_hinfammo:GetInt() < 1 then 
            n = 2
        else
            n = 1
        end
        if n > 0 then
            for k,v in ipairs (player.GetBots()) do
                weapon = v:GetActiveWeapon()
                if IsValid(weapon) and v:Team() == TEAM_SURVIVORS then
                    local maxClip = weapon:GetMaxClip1()
                    local maxClip2 = weapon:GetMaxClip2()
                    local primAmmoType = weapon:GetPrimaryAmmoType()
                    local secAmmoType = weapon:GetSecondaryAmmoType()
                    if maxClip == -1 and maxClip2 == -1 then
                        maxClip = 9999
                        maxClip2 = 9999
                    end
                    if maxClip <= 0 and primAmmoType ~= -1 then maxClip = 1 end
                    if maxClip2 == -1 and secAmmoType ~= -1 then maxClip2 = 1 end
                    if n == 1 then
                        if maxClip >= 0 then weapon:SetClip1(maxClip) end
                        if maxClip2 >= 0 then weapon:SetClip2(maxClip2) end
                    end
                    if primAmmoType ~= -1 then
                        v:SetAmmo( maxClip, primAmmoType)
                    end
                    if secAmmoType ~= -1 and secAmmoType ~= primAmmoType then
                        v:SetAmmo( maxClip2, secAmmoType)
                    end
                end
            end
        end
    end

    hook.Add("Think", "LeadBot_Think", function()
        if SERVER then 
            local startZombsPercent = player.GetCount() * (leadbot_minzombies:GetInt() * 0.01)

            if player.GetCount() >= GetConVar("leadbot_quota"):GetInt() then
                for k, v in ipairs(player.GetBots()) do
                    if k <= math.ceil(startZombsPercent) and v:Team() == TEAM_SURVIVORS and team.NumPlayers(TEAM_ZOMBIE) < math.ceil(startZombsPercent) then
                        v:Kill()
                    end
                end
            end

            if INTERMISSION == 1 and leadbot_hordes:GetInt() >= 1 and GetConVar("leadbot_quota"):GetInt() < 2 then 
                for k, v in ipairs(player.GetHumans()) do
                    if v:Team() == TEAM_ZOMBIE then 
                        v:Redeem()
                    end
                end
            end

            if leadbot_cs:GetInt() >= 1 then 
                for k, v in ipairs(player.GetAll()) do
                    if v:Team() == TEAM_ZOMBIE then
                        playerCSSpeed = playerCSSpeed + 10
                        if v:Health() ~= 1000 then 
                            GAMEMODE:SetPlayerSpeed(v, math.min(playerCSSpeed, 200))
                        else
                            GAMEMODE:SetPlayerSpeed(v, 200)
                        end
                        if v:GetZombieClass() ~= 1 then 
                            v:Kill()
                            v:SetZombieClass(1)
                        end
                    else
                        if v:Health() > 30 then 
                            v:SetMaxHealth(30)
                            v:SetHealth(30)
                        end
                    end
                end
            end

            if team.NumPlayers(TEAM_ZOMBIE) >= 1 and team.NumPlayers(TEAM_ZOMBIE) < player.GetCount() then 
                INTERMISSION = 0
            end

            if leadbot_collision:GetInt() < 1 then
                for k, v in ipairs(player.GetAll()) do
                    v:SetNoCollideWithTeammates(true)
                end
            else 
                for k, v in ipairs(player.GetAll()) do
                    v:SetNoCollideWithTeammates(false)
                end
            end

            InfiniteAmmoForSurvivorBots()
            LeadBot.Think()
        end
    end)

    hook.Add("PlayerSpawn", "LeadBot_Spawn", function(bot)
        if SERVER then 
            if bot:Team() == TEAM_ZOMBIE and leadbot_cs:GetInt() >= 1 then 
                timer.Create(bot:SteamID64() .. " csHealth", 1, 1, function() 
                    bot:SetMaxHealth(1000)
                    bot:SetHealth(1000) 
                end )
            end
            if leadbot_knockback:GetInt() < 1 then 
                bot:AddEFlags(EFL_NO_DAMAGE_FORCES)
            end
            if bot:IsLBot() then
                LeadBot.PlayerSpawn(bot)
            end
        end
    end)

    hook.Add("EntityTakeDamage", "LeadBot_Hurt", function(ply, dmgi) 
        local bot = dmgi:GetAttacker()
        local hp = ply:Health()
        local dmg = dmgi:GetDamage()
        local force = dmgi:GetDamageForce()

        if leadbot_cs:GetInt() >= 1 then 
            if ply:IsPlayer() and bot:IsPlayer() and ply:Team() == TEAM_ZOMBIE and bot:Team() == TEAM_SURVIVORS then 
                playerCSSpeed = 1
                ply:SetVelocity(ply:GetVelocity() + ( force / 4 ) )
            end
         end

        if IsValid(ply) and IsValid(bot) and ply:IsPlayer() and ply:IsLBot() and bot:IsPlayer() then
            LeadBot.PlayerHurt(ply, bot, hp, dmg)
        end
    end)

    hook.Add( "PlayerDeath", "SurvivorBotHealPerKill", function( victim, inflictor, attacker )
        if SERVER then
            timer.Create(victim:SteamID64().."secondwindstopper1", 2.1, 1, function()
                if IsValid(victim) and victim:IsBot() and victim:Alive() and victim:Team() == TEAM_ZOMBIE then
                    victim:Kill()
                end
            end)
            timer.Create(victim:SteamID64().."secondwindstopper2", 2.6, 1, function()
                if IsValid(victim) and victim:IsBot() and victim:Alive() and victim:Team() == TEAM_ZOMBIE then
                    victim:Kill()
                end
            end)
            if leadbot_hregen:GetInt() >= 1 then 
                if attacker:IsPlayer() and victim:IsPlayer() and attacker:Team() == TEAM_ZOMBIE and attacker ~= victim then 
                    for k, v in ipairs(player.GetBots()) do 
                        if v:Team() == TEAM_SURVIVORS then 
                            v:SetHealth(v:Health() + 24)
                        end
                    end
                end
            end
            if leadbot_cs:GetInt() >= 1 then 
                if victim:IsPlayer() and attacker:IsPlayer() and attacker:Team() == TEAM_ZOMBIE and attacker ~= victim then 
                    victim:EmitSound("npc/fast_zombie/fz_scream1.wav", CHAN_REPLACE)  
                end
            end
        end
    end )

    timer.Create("zombieIgnore", 5, -1, function() 
        if SERVER then
            for k, v in ipairs(player.GetBots()) do
                if v:Team() == TEAM_ZOMBIE and team.NumPlayers(TEAM_SURVIVORS) ~= 0 then 
                    for _, ply in RandomPairs(player.GetAll()) do
                        if ply:Team() == TEAM_SURVIVORS then
                            local controller = v.ControllerBot 
                            if IsValid(controller.Target) and not controller.Target:IsPlayer() and controller.Target:Health() <= 0 then 
                                controller.Target = ply
                                controller.ForgetTarget = CurTime() + 5
                            end
                        end
                    end
                end
            end
        end 
    end )

    timer.Create("zombieStuckDetector", 20, -1, function() 
        if SERVER then 
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
        end 
    end )

    timer.Create("zombieNearDetector", 20, -1, function() 
        if SERVER then 
            for _, z in ipairs(player.GetBots()) do  
                local controller = z.ControllerBot 
                if controller.PosGen and !IsValid(controller.Target) then 
                    if z:Team() == TEAM_ZOMBIE and z:LBGetZomSkill() == 1 then 
                        for _, h in ipairs(player.GetAll()) do 
                            if IsValid(h) and h:Team() == TEAM_SURVIVORS and h:GetPos():DistToSqr(z:GetPos()) < controller.PosGen:DistToSqr(z:GetPos()) then 
                                controller.PosGen = h:GetPos()
                                controller.LastSegmented = CurTime() + 4000000
                            end
                        end
                    end
                end
            end 
        end
    end )

    timer.Start("zombieIgnore")
    timer.Start("zombieStuckDetector")
    timer.Start("zombieNearDetector")

    if !DEBUG then return end
end