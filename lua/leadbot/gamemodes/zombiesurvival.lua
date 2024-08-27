-- basically finished :I --f
--      By Tony Dosk Enginooy. 8====================================================================================D 
--         This file was creater to Zombie Survival v1.11 Fix, by Xalalau. Ty, Tony - Xala

LeadBot.Gamemode = "zombiesurvival"
LeadBot.RespawnAllowed = true -- allows bots to respawn automatically when dead
LeadBot.PlayerColor = true -- disable this to get the default gmod style players
LeadBot.NoNavMesh = false -- disable the nav mesh check
LeadBot.TeamPlay = true -- don't hurt players on the bots team
LeadBot.LerpAim = true -- interpolate aim (smooth aim)
LeadBot.AFKBotOverride = false -- allows for gamemodes such as Dogfight which use IsBot() to pass real humans as bots
LeadBot.SuicideAFK = false -- kill the player when entering/exiting afk
LeadBot.NoFlashlight = true -- disable flashlight being enabled in dark areas
LeadBot.NoSprint = true
LeadBot.Strategies = 3 -- how many strategies can the bot pick from

if engine.ActiveGamemode() == "zombiesurvival" then 
    LeadBot.AFKBotOverride = false
else
    LeadBot.AFKBotOverride = true
end

concommand.Add("leadbot_add", function(ply, _, args) if IsValid(ply) and !ply:IsSuperAdmin() then return end local amount = 1 if tonumber(args[1]) then amount = tonumber(args[1]) end for i = 1, amount do timer.Simple(i * 0.1, function() LeadBot.AddBot() end) end end, nil, "Adds a LeadBot")
concommand.Add("leadbot_kick", function(ply, _, args) if !args[1] or IsValid(ply) and !ply:IsSuperAdmin() then return end if args[1] ~= "all" then for k, v in pairs(player.GetBots()) do if string.find(v:GetName(), args[1]) then v:Kick() return end end else for k, v in pairs(player.GetBots()) do v:Kick() end end end, nil, "Kicks LeadBots (all is avaliable!)")
CreateConVar("leadbot_strategy", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enables the strategy system for newly created bots.")
CreateConVar("leadbot_names", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot names, seperated by commas.")
CreateConVar("leadbot_models", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot models, seperated by commas.")
CreateConVar("leadbot_name_prefix", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot name prefix")
CreateConVar("leadbot_minzombies", "1", {FCVAR_ARCHIVE}, "What Percentage of Leadbots become Zombies at the Beginning (this includes players as well)", 1, 100)
CreateConVar("leadbot_zchance", "0", {FCVAR_ARCHIVE}, "If you want a chance to become a zombie when you spawn", 0 , 1)
CreateConVar("leadbot_hordes", "0", {FCVAR_ARCHIVE}, "If you want to play horde mode instead of using quota", 0 , 1)
CreateConVar("leadbot_hinfammo", "1", {FCVAR_ARCHIVE}, "If you want survivor bots to have an infinite amount of clip ammo so that they survive longer", 0 , 1)
CreateConVar("leadbot_hregen", "1", {FCVAR_ARCHIVE}, "If you want survivor bots to heal with each kill so that they survive longer", 0 , 1)
CreateConVar("leadbot_hrandhp", "0", {FCVAR_ARCHIVE}, "If you want survivor bots to start with a random amount of hp", 0 , 1)
CreateConVar("leadbot_zcheats", "0", {FCVAR_ARCHIVE}, "If you want zombie bots to cheat a little so that they're better at killing humans'", 0 , 1)
CreateConVar("leadbot_collision", "0", {FCVAR_ARCHIVE}, "If you want survivor bots to not collide with each other or others", 0 , 1)
local DEBUG = false
local nextCheck = 0
local INTERMISSION = 1
local INTERMISSION_FAKE_TIMER = 60
local sigil3Valid = false
local sigil2Valid = false
local sigil1Valid = false
resource.AddFile("sound/intermission.mp3")

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
    kleiner = "Isaac Kleiner",
    breen = "Dr. Wallace Breen",
    gman = "The G-Man",
    odessa = "Odessa Cubbage",
    eli = "Eli Vance",
    monk = "Father Grigori",
    mossman = "Judith Mossman",
    mossmanarctic = "Judith Mossman",
    barney = "Barney Calhoun",


    dod_american = "American Soldier",
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
    combineelite = "Elite Combine Soldier",
    stripped = "Stripped Combine Soldier",

    zombie = "Zombie",
    zombiefast = "Fast Zombie",
    zombine = "Zombine",
    corpse = "Corpse",
    charple = "Charple",
    skeleton = "Skeleton",

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
    if !FindMetaTable("NextBot").GetFOV then
        ErrorNoHalt("You must be using the dev version of Garry's mod!\nhttps://wiki.facepunch.com/gmod/Dev_Branch\n")
        return
    end

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

        for _, ply in pairs(player.GetBots()) do
            if ply.OriginalName == name or string.lower(ply:Nick()) == name or name_Default[name] and ply:Nick() == name_Default[name] then
                name = ""
            end
        end

        if name == "" then
            local i = 0
            while name == "" do
                i = i + 1
                local str = player_manager.TranslateToPlayerModelName(table.Random(player_manager.AllValidModels()))
                for _, ply in pairs(player.GetBots()) do
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

        for i, namestr in pairs(name_Generated) do
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

    bot.LeadBot_Config = {model, color, weaponcolor, strategy}

    -- for legacy purposes, will be removed soon when gamemodes are updated
    bot.BotStrategy = strategy
    bot.OriginalName = original_name
    bot.ControllerBot = ents.Create("leadbot_navigator")
    bot.ControllerBot:Spawn()
    bot.ControllerBot:SetOwner(bot)
    bot.LeadBot = true
    LeadBot.AddBotOverride(bot)
    LeadBot.AddBotControllerOverride(bot, bot.ControllerBot)
    MsgN("[LeadBot] Bot " .. name .. " with strategy " .. bot.BotStrategy .. " added!")
end

if not game.SinglePlayer() or GetConVar("leadbot_hordes"):GetInt() >= 1 then
    timer.Create("Hordes", 60, 9999, function() 
        RunConsoleCommand("leadbot_add", "1")
        INTERMISSION = 0
         end )

    timer.Create("INTERMISSION_MESSAGE", 1, 60, function() 
        PrintMessage( 4, "Infection begins in " .. INTERMISSION_FAKE_TIMER .. " Seconds!")
        INTERMISSION_FAKE_TIMER = INTERMISSION_FAKE_TIMER - 1
         end )
end

hook.Add( "PlayerInitialSpawn", "BotSpawnLogic", function( ply )
    if not game.SinglePlayer() then 
        if not ply:IsBot() and GetConVar("leadbot_zchance"):GetInt() == 0 and INFLICTION < 0.5 or not ply:IsBot() and GetConVar("leadbot_zchance"):GetInt() == 0 and (CurTime() <= GetConVar("zs_roundtime"):GetInt()*0.5 and not GetConVar("zs_human_deadline"):GetBool()) then 
            timer.Simple(2, function() ply:Redeem() end)
        end

        if ply:IsBot() then 
            for k, v in pairs(player.GetBots()) do
                if GetConVar("leadbot_quota"):GetInt() > 1 and GetConVar("leadbot_hordes"):GetInt() < 1 then
                    v:Redeem()
                    v:SetMaxHealth(1000000)
                    if GetConVar("leadbot_hcheats"):GetInt() >= 1 then 
                        v:SetHealth(math.random(1, 200))
                    end
                end
            end
        end

        if GetConVar("leadbot_hordes"):GetInt() >= 1 and player.GetCount() == 1 then
            timer.Start("Hordes")
            timer.Start("INTERMISSION_MESSAGE")
            RunConsoleCommand("play", "intermission.mp3")
        end
        if GetConVar("leadbot_hordes"):GetInt() < 1 and player.GetCount() >= 1 then
            timer.Stop("Hordes")
            timer.Stop("INTERMISSION_MESSAGE")
        end
    end
end )

hook.Add( "Think", "INTERMISSION_REVIVER", function()
    local startZombsPercent = player.GetCount() * (GetConVar("leadbot_minzombies"):GetInt() * 0.01)

    for k, v in pairs(player.GetBots()) do
        if player.GetCount() >= GetConVar("leadbot_quota"):GetInt() then
            if k <= math.ceil(startZombsPercent) and v:Team() ~= TEAM_ZOMBIE and team.NumPlayers(TEAM_ZOMBIE) < math.ceil(startZombsPercent) then
                v:Kill()
            end
        end
    end

    if INTERMISSION == 1 and GetConVar("leadbot_hordes"):GetInt() >= 1 and GetConVar("leadbot_quota"):GetInt() < 2 then 
        for k, v in pairs(player.GetHumans()) do
            if v:Team() ~= TEAM_SURVIVORS then 
                v:Redeem()
            end
        end
    end

    if team.NumPlayers(TEAM_ZOMBIE) >= 1 and team.NumPlayers(TEAM_ZOMBIE) < player.GetCount() then 
        INTERMISSION = 0
    end
end )

-- Credid goes out to 女儿 for this infinite ammo code :D --

local n = 1

function InfiniteAmmo()
    if GetConVar("leadbot_hcheats"):GetInt() < 1 then 
        n = 2
    else
        n = 1
    end
    if n > 0 then
        for k,v in pairs (player.GetAll()) do
            weapon = v:GetActiveWeapon()
            if IsValid(weapon) and v:IsBot() and v:Team() ~= TEAM_ZOMBIE then
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
                    if maxClip > 0 then weapon:SetClip1(maxClip) end
                    if maxClip2 > 0 then weapon:SetClip2(maxClip2) end
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

hook.Add("Think", "InfiniteAmmo",InfiniteAmmo)

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
    for _, bot in pairs(player.GetBots()) do
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

    classes = math.random(1, 8)
    classesHealthStrat = math.random(1, 4)

    if bot:Team() ~= TEAM_SURVIVORS then

        bot:StripWeapon("weapon_zs_swissarmyknife")

        if bot:LBGetStrategy() ~= 1 or bot:LBGetStrategy() ~= 6 or bot:LBGetStrategy() ~= 7 then 
            if classes == 1 then 
                bot:SetZombieClass(1)
            elseif classes == 2 and INFLICTION >= 0.5 then
                bot:SetZombieClass(2)
            elseif classes == 3 and INFLICTION >= 0.65 then
                bot:SetZombieClass(3)
            elseif classes == 4 and INFLICTION >= 0.75 then 
                bot:SetZombieClass(4)
            elseif classes == 5 and INFLICTION >= 0.4 then
                bot:SetZombieClass(5)
            elseif classes == 6 and INFLICTION >= 0.26  then
                bot:SetZombieClass(6)
            elseif classes == 7 and INFLICTION >= 0.3333 then
                bot:SetZombieClass(7)
            elseif classes == 8 and INFLICTION >= 0.6 then
                bot:SetZombieClass(8)
            else
                bot:SetZombieClass(1)
            end
        else
            if classesHealthStrat == 1 and INFLICTION >= 0.5 then
                bot:SetZombieClass(2)
            elseif classesHealthStrat == 2 and INFLICTION >= 0.4 then
                bot:SetZombieClass(5)
            elseif classesHealthStrat == 3 and INFLICTION >= 0.26  then
                bot:SetZombieClass(6)
            elseif classesHealthStrat == 4 and INFLICTION >= 0.3333 then
                bot:SetZombieClass(7)
            else
                bot:SetZombieClass(1)
            end
        end
    
        if bot:GetZombieClass(1) then 
            bot:Give("weapon_zs_zombie")
            bot:SelectWeapon("weapon_zs_zombie")
        elseif bot:GetZombieClass(2) then
            bot:Give("weapon_zs_fastzombie")
            bot:SelectWeapon("weapon_zs_fastzombie")
        elseif bot:GetZombieClass(3) then
            bot:Give("weapon_zs_poisonzombie")
            bot:SelectWeapon("weapon_zs_poisonzombie")
        elseif bot:GetZombieClass(4) then
            bot:Give("weapon_zs_chemzombie")
            bot:SelectWeapon("weapon_zs_chemzombie")
        elseif bot:GetZombieClass(5) then
            bot:Give("weapon_zs_wraith")
            bot:SelectWeapon("weapon_zs_wraith")
        elseif bot:GetZombieClass(6) then
            bot:Give("weapon_zs_headcrab")
            bot:SelectWeapon("weapon_zs_headcrab")
        elseif bot:GetZombieClass(7) then
            bot:Give("weapon_zs_fastheadcrab")
            bot:SelectWeapon("weapon_zs_fastheadcrab")
        elseif bot:GetZombieClass(8) then
            bot:Give("weapon_zs_poisonheadcrab")
            bot:SelectWeapon("weapon_zs_poisonheadcrab")
        elseif bot:GetZombieClass(9) then
            bot:Give("weapon_zs_zombietorso")
            bot:SelectWeapon("weapon_zs_zombietorso")
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

        --if hp <= 0 and ply:Team() ~= TEAM_ZOMBIE and math.random(2) == 1 then
            --LeadBot.TalkToMe(bot, "downed")
        --end

        if hp >= dmg and ply:Team() ~= TEAM_ZOMBIE and ply:Health() <= 10 and math.random(10) == 1 then -- don't spam
            LeadBot.TalkToMe(bot, "help")
        end

        if hp >= dmg and ply:Team() ~= TEAM_ZOMBIE and not bot:IsNPC() and ply:Health() <= 40 and math.random(2) == 1 then -- don't spam
            LeadBot.TalkToMe(bot, "pain")
        end

        if ply:Team() ~= TEAM_ZOMBIE then 
            if hp >= dmg and not bot:IsNPC() and bot:Team() ~= ply:Team() or hp >= dmg and bot:IsNPC() then
                controller.Target = bot
                controller.ForgetTarget = CurTime() + 4
            end
        end

        if ply:Team() ~= TEAM_SURVIVORS then
            if hp >= dmg and not bot:IsNPC() and bot:Team() ~= ply:Team() and hurtdistance < ply:GetPos():DistToSqr(controller.PosGen) then
                controller.PosGen = bot:GetPos()
                controller.LastSegmented = CurTime() + 5 
                controller.LookAtTime = CurTime() + 2
                controller.LookAt = (bot:GetPos() - ply:GetPos()):Angle()
            end
        end

        if ply:Team() ~= TEAM_SURVIVORS then
            if hp >= dmg and not bot:IsNPC() and bot:Team() ~= ply:Team() and IsValid(controller.Target) and ply:GetPos():DistToSqr(controller.Target:GetPos()) > hurtdistance then
                controller.Target = bot
                controller.ForgetTarget = CurTime() + 4
            end
        end
    end
end

hook.Add("EntityTakeDamage", "LeadBot_Hurt", function(ply, dmgi)
    local bot = dmgi:GetAttacker()
    local hp = ply:Health()
    local dmg = dmgi:GetDamage()

    if IsValid(ply) and ply:IsPlayer() and ply:IsLBot() and not bot:IsNPC() then
        LeadBot.PlayerHurt(ply, bot, hp, dmg)
    end
end)

cvars.AddChangeCallback("leadbot_quota", function(_, oldval, val)
    oldval = tonumber(oldval)
    val = tonumber(val)

    if oldval and val and oldval > 0 and val < 1 then
        RunConsoleCommand("leadbot_kick", "all")
    end
end)

local function addSpots()
    local areas = navmesh.GetAllNavAreas()
    local hidingspots = {}
    local spotsReset = {}

    for _, area in pairs(areas) do
        local spots = area:GetHidingSpots(1)
        -- local spots2 = area:GetHidingSpots(8)
        local spotsReset2 = {}

        for _, spot in pairs(spots) do
            if !util.QuickTrace(spot, Vector(0, 0, 72)).Hit and !util.QuickTrace(spot, Vector(0, 0, 72)).Hit and !util.TraceHull({start = spot, endpos = spot + Vector(0, 0, 72), mins = Vector(-16, -16, 0), maxs = Vector(16, 16, 72)}).HitWorld then
                table.Add(hidingspots, spots)
                table.insert(spotsReset2, spot)
            end
        end

        table.insert(spotsReset, {area, spotsReset2})

        -- table.Add(hidingspots, spots2)

        -- the reason why we don't use spots2 is because these are barely hidden
        -- we should only use it when there are not enough normal hiding spots to diversify hiding places
    end

    MsgN("Found " .. #hidingspots .. " default hiding spots!")
    if #hidingspots < 1 then return end
    --[[MsgN("Teleporting to one...")
    ply:SetPos(table.Random(hidingspots))]]

    HidingSpots = spotsReset
end

function LeadBot.StartCommand(bot, cmd)
    local buttons = IN_SPEED
    local botWeapon = bot:GetActiveWeapon()
    local controller = bot.ControllerBot
    local target = controller.Target

    if !IsValid(controller) then return end

    if LeadBot.NoSprint then
        buttons = 0
    end

    if bot:Team() ~= TEAM_ZOMBIE then 
        if IsValid(botWeapon) and botWeapon:Clip1() == 0 and not !IsValid(target) or IsValid(botWeapon) and !IsValid(target) and botWeapon:Clip1() <= (botWeapon:GetMaxClip1() / 2) then
            buttons = buttons + IN_RELOAD
        end

        if IsValid(target) and math.random(2) == 1 then
            buttons = buttons + IN_ATTACK
        end
    end
    if bot:Team() ~= TEAM_SURVIVORS then 
        if bot:GetZombieClass() > 5 or bot:GetZombieClass() < 5 then 
            if IsValid(target) then
                if math.random(2) == 1 then 
                    buttons = buttons + IN_ATTACK
                else
                    if target:IsPlayer() and controller:CanSee(target) then 
                        buttons = buttons + IN_ATTACK2
                    end
                end
            end
        else
            if IsValid(target) and target:GetPos():DistToSqr(bot:GetPos()) < 10750 then
                if math.random(2) == 1 then 
                    buttons = buttons + IN_ATTACK
                else
                    buttons = buttons + IN_ATTACK2
                end
            end
        end

        if !IsValid(target) then
            if math.random(2) == 1 then 
                if bot:GetZombieClass() > 3 or bot:GetZombieClass() < 3 then
                    if bot:GetZombieClass() > 8 or bot:GetZombieClass() < 8 then 
                        buttons = buttons + IN_ATTACK2
                    end
                end
            else
                if bot:GetZombieClass() > 5 and bot:GetZombieClass() < 8 then 
                    buttons = buttons + IN_ATTACK
                end
            end
        end
    end

    if bot:GetMoveType() == MOVETYPE_LADDER then
        local pos = controller.goalPos
        local ang = ((pos + bot:GetCurrentViewOffset()) - bot:GetShootPos()):Angle()

        if pos.z > controller:GetPos().z then
            controller.LookAt = Angle(-30, ang.y, 0)
        else
            controller.LookAt = Angle(30, ang.y, 0)
        end

        controller.LookAtTime = CurTime() + 0.1
        controller.NextJump = -1
        buttons = buttons + IN_FORWARD
    end

    if controller.NextDuck > CurTime() then
        buttons = buttons + IN_DUCK
    elseif controller.NextJump == 0 then
        controller.NextJump = CurTime() + 1
        buttons = buttons + IN_JUMP
    end

    if bot:GetVelocity():LengthSqr() <= 225 and !IsValid(target) then 
        buttons = buttons + IN_JUMP
        if bot:Team() ~= TEAM_SURVIVORS then 
            if bot:GetZombieClass() > 8 or bot:GetZombieClass() < 8 then
                if bot:GetZombieClass() > 5 or bot:GetZombieClass() < 5 then
                    buttons = buttons + IN_ATTACK
                end
            end
        end
    end 

    if !bot:IsOnGround() and controller.NextJump > CurTime() then
        buttons = buttons + IN_DUCK
    end

    bot:SelectWeapon((IsValid(controller.Target) and controller.Target:GetPos():DistToSqr(controller:GetPos()) < 129000 and "weapon_shotgun") or "weapon_smg1")
    cmd:ClearButtons()
    cmd:ClearMovement()
    cmd:SetButtons(buttons)
end

function LeadBot.PlayerMove(bot, cmd, mv)

    if #HidingSpots < 1 then
        addSpots()
    end

    if GetConVar("leadbot_collision"):GetInt() < 1 then
        bot:SetNoCollideWithTeammates(true)
    else 
        bot:SetNoCollideWithTeammates(false)
    end

    if bot:GetZombieClass() > 5 and bot:Team() ~= TEAM_SURVIVORS then 
        if bot:GetZombieClass() == 8 and GetConVar("leadbot_zcheats"):GetInt() >= 1 then 
            bot:Freeze(false)
        else

        end
        bot:SetJumpPower(300)
    end
    if bot:GetZombieClass() <= 4 and bot:Team() ~= TEAM_SURVIVORS then
        GAMEMODE:SetPlayerSpeed(bot, ZombieClasses[bot:GetZombieClass()].Speed)
        if bot:GetZombieClass() ~= 9 then
            bot:SetJumpPower(200)
        end
    end
    if bot:GetZombieClass() == 5 and GetConVar("leadbot_zcheats"):GetInt() >= 1 then 
        GAMEMODE:SetPlayerSpeed(bot, ZombieClasses[bot:GetZombieClass()].Speed)
    elseif bot:GetZombieClass() == 5 and GetConVar("leadbot_zcheats"):GetInt() < 1 then 

    end

    if GetConVar("leadbot_hordes"):GetInt() >= 1 and bot:Team() ~= TEAM_ZOMBIE then 
        bot:Kill()
    end

    local controller = bot.ControllerBot

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

    if controller.Target == nil then 
        mv:SetForwardSpeed(1200)
    end

    if (bot.NextSpawnTime and bot.NextSpawnTime + 1 > CurTime()) or !IsValid(controller.Target) or controller.ForgetTarget < CurTime() or controller.Target:Health() < 1 then
        controller.Target = nil
    end

    if bot:Team() ~= TEAM_ZOMBIE then 
        if !IsValid(controller.Target) then
            for _, ply in RandomPairs(player.GetAll()) do
                if ply ~= bot and ply:Team() ~= bot:Team() and ply:Alive() and IsValid(ply) and controller:CanSee(ply) then
                    controller.Target = ply
                    controller.ForgetTarget = CurTime() + 4
                end
                if ply ~= bot and ply:Team() ~= bot:Team() and ply:Alive() and IsValid(ply) and ply:GetPos():DistToSqr(bot:GetPos()) <= 15000 then
                    if ply:GetZombieClass() > 5 or ply:GetZombieClass() < 5 then
                        if ply:GetZombieClass() > 4 or ply:GetZombieClass() < 4 then
                            controller.Target = ply
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end
            for _, close in RandomPairs(player.GetAll()) do
                if close ~= bot and close:Team() ~= bot:Team() and close:Alive() and IsValid(close) and close:GetPos():DistToSqr(bot:GetPos()) <= 15000 then
                    if close:GetZombieClass() > 5 or close:GetZombieClass() < 5 then
                        if close:GetZombieClass() > 4 or close:GetZombieClass() < 4 then
                            controller.Target = close
                            controller.ForgetTarget = CurTime() + 4
                        end
                    end
                end
            end
        elseif controller.ForgetTarget < CurTime() and controller:CanSee(controller.Target) then
            controller.ForgetTarget = CurTime() + 4
        end

        if IsValid(controller.Target) then
            for _, zom in RandomPairs(player.GetAll()) do
                if zom ~= bot and zom:Team() ~= bot:Team() and zom:Alive() and IsValid(zom) and zom:GetPos():DistToSqr(bot:GetPos()) < controller.Target:GetPos():DistToSqr(bot:GetPos()) then
                    controller.Target = zom
                    controller.ForgetTarget = CurTime() + 4
                end
            end
        end
    end

    if bot:Team() ~= TEAM_SURVIVORS then 
        if !IsValid(controller.Target) then
            for _, ply in RandomPairs(player.GetAll()) do
                if ply ~= bot and ply:Team() ~= bot:Team() and ply:Alive() and IsValid(ply) and controller:CanSee(ply) then
                    controller.PosGen = ply:GetPos()
                    controller.LastSegmented = CurTime() + 5
                    controller.LookAtTime = CurTime() + 2
                    controller.LookAt = (ply:GetPos() - bot:GetPos()):Angle()
                end 
                if ply ~= bot and ply:Team() ~= bot:Team() and ply:Alive() and controller:CanSee(ply) and ply:GetPos():DistToSqr(bot:GetPos()) < 15000 then
                    controller.Target = ply
                    if not UNLIFE then
                        controller.ForgetTarget = CurTime() + 4
                    else
                        controller.ForgetTarget = CurTime() + 10
                    end
                end
            end
        elseif controller.ForgetTarget < CurTime() and controller:CanSee(controller.Target) then
            controller.ForgetTarget = CurTime() + 4
        end

        if IsValid(controller.Target) then
            for _, hum in RandomPairs(player.GetAll()) do
                if hum ~= bot and hum:Team() ~= bot:Team() and hum:Alive() and IsValid(hum) and controller.Target:IsPlayer() then
                    if bot:LBGetStrategy() == 0 and hum:GetPos():DistToSqr(bot:GetPos()) < controller.Target:GetPos():DistToSqr(bot:GetPos()) and controller:CanSee(hum) then 
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 1 and hum:Health() < controller.Target:Health() and controller:CanSee(hum) then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 2 and hum:Frags() < controller.Target:Frags() and controller:CanSee(hum) then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 3 and hum:GetPos():DistToSqr(bot:GetPos()) < controller.Target:GetPos():DistToSqr(bot:GetPos()) then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 4 and hum:GetPos():DistToSqr(bot:GetPos()) < controller.Target:GetPos():DistToSqr(bot:GetPos()) and hum:Health() < controller.Target:Health() then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 5 and hum:GetPos():DistToSqr(bot:GetPos()) < controller.Target:GetPos():DistToSqr(bot:GetPos()) and hum:Frags() < controller.Target:Frags() then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 6 and hum:GetPos():DistToSqr(bot:GetPos()) < 100000 and hum:Health() < controller.Target:Health() then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    elseif bot:LBGetStrategy() == 7 and hum:GetPos():DistToSqr(bot:GetPos()) < 100000 and hum:Frags() < controller.Target:Frags() then
                        controller.Target = hum
                        controller.ForgetTarget = CurTime() + 4
                    end
                end
            end
        end
    end

    local dt = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45, bot)

    local dtn = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45 - bot:GetViewOffsetDucked(), bot)

    local dtp = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45 + bot:GetViewOffsetDucked(), bot)

    local dtne = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45 - bot:GetViewOffsetDucked() - bot:GetViewOffsetDucked(), bot)

    local dtpe = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45 + bot:GetViewOffsetDucked() + bot:GetViewOffsetDucked(), bot)

    local dtnse = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45 - bot:GetViewOffsetDucked() - bot:GetViewOffsetDucked() - bot:GetViewOffsetDucked(), bot)

    local dtpse = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45 + bot:GetViewOffsetDucked() + bot:GetViewOffsetDucked() + bot:GetViewOffsetDucked(), bot)

    local pwt = util.QuickTrace(bot:GetPos(), bot:GetForward() * 360, bot)

    if IsValid(pwt.Entity) and pwt.Entity:IsPlayer() and pwt.Entity:Team() ~= bot:Team() then
        controller.Target = pwt.Entity
        controller.ForgetTarget = CurTime() + 4
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_door_rotating" then
        dt.Entity:Fire("OpenAwayFrom", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_door_rotating" then
        dt.Entity:Fire("OpenAwayFrom", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_door" then
        dt.Entity:Fire("Open", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_door" then
        dt.Entity:Fire("Open", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_door_rotating" then
        dt.Entity:Fire("Unlock", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_door_rotating" then
        dt.Entity:Fire("Unlock", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_door" then
        dt.Entity:Fire("Unlock", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_door" then
        dt.Entity:Fire("Unlock", bot, 0)
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_movelinear" then
        if dt.Entity:GetName() ~= "BunkerDoor" then
            dt.Entity:Fire("Open", bot, 0)
        else
            dt.Entity:Fire("Close", bot, 0)
        end
    end

    if IsValid(dtp.Entity) and dtp.Entity:GetClass() == "func_movelinear" then
        if dtp.Entity:GetName() ~= "BunkerDoor" then
            dtp.Entity:Fire("Open", bot, 0)
        else
            dtp.Entity:Fire("Close", bot, 0)
        end
    end

    if IsValid(dtn.Entity) and dtn.Entity:GetClass() == "func_movelinear" then
        if dtn.Entity:GetName() ~= "BunkerDoor" then
            dtn.Entity:Fire("Open", bot, 0)
        else
            dtn.Entity:Fire("Close", bot, 0)
        end
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_breakable" then
        if bot:Team() ~= TEAM_SURVIVORS then
            controller.Target = dt.Entity
        end
    end

    if IsValid(dtn.Entity) and dtn.Entity:GetClass() == "func_breakable" then
        if not game.GetMap() == "zs_pub" or not game.GetMap() == "zs_ascent" then
            if bot:Team() ~= TEAM_SURVIVORS then
                controller.Target = dtn.Entity
            end
        end
    end

    if IsValid(dtp.Entity) and dtp.Entity:GetClass() == "func_breakable" then
        if not game.GetMap() == "zs_pub" or not game.GetMap() == "zs_ascent" then
            if bot:Team() ~= TEAM_SURVIVORS then
                controller.Target = dtp.Entity
            end
        end
    end

    if IsValid(dtne.Entity) and dtne.Entity:GetClass() == "func_breakable" then
        if not game.GetMap() == "zs_pub" or not game.GetMap() == "zs_ascent" then
            if bot:Team() ~= TEAM_SURVIVORS then
                controller.Target = dtne.Entity
            end
        end
    end

    if IsValid(dtpe.Entity) and dtpe.Entity:GetClass() == "func_breakable" then
        if not game.GetMap() == "zs_pub" or not game.GetMap() == "zs_ascent" then
            if bot:Team() ~= TEAM_SURVIVORS then
                controller.Target = dtpe.Entity
            end
        end
    end

    if IsValid(dtnse.Entity) and dtnse.Entity:GetClass() == "func_breakable" then
        if not game.GetMap() == "zs_pub" or not game.GetMap() == "zs_ascent" then
            if bot:Team() ~= TEAM_SURVIVORS then
                controller.Target = dtnse.Entity
            end
        end
    end

    if IsValid(dtpse.Entity) and dtpse.Entity:GetClass() == "func_breakable" then
        if not game.GetMap() == "zs_pub" or not game.GetMap() == "zs_ascent" then
            if bot:Team() ~= TEAM_SURVIVORS then
                controller.Target = dtpse.Entity
            end
        end
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            controller.Target = dt.Entity
        end
    end

    if IsValid(dtn.Entity) and dtn.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if not game.GetMap() == "zs_aztec_v2" or not game.GetMap() == "zs_ziggurat-v1" then
                controller.Target = dtn.Entity
            end
        end
    end

    if IsValid(dtp.Entity) and dtp.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if not game.GetMap() == "zs_aztec_v2" or not game.GetMap() == "zs_ziggurat-v1" then
                controller.Target = dtp.Entity
            end
        end
    end

    if IsValid(dtne.Entity) and dtne.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if not game.GetMap() == "zs_aztec_v2" or not game.GetMap() == "zs_ziggurat-v1" then
                controller.Target = dtne.Entity
            end
        end
    end

    if IsValid(dtpe.Entity) and dtpe.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if not game.GetMap() == "zs_aztec_v2" or not game.GetMap() == "zs_ziggurat-v1" then
                controller.Target = dtpe.Entity
            end
        end
    end

    if IsValid(dtnse.Entity) and dtnse.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if not game.GetMap() == "zs_aztec_v2" or not game.GetMap() == "zs_ziggurat-v1" then
                controller.Target = dtnse.Entity
            end
        end
    end

    if IsValid(dtpse.Entity) and dtpse.Entity:GetClass() == "func_physbox" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if not game.GetMap() == "zs_aztec_v2" or not game.GetMap() == "zs_ziggurat-v1" then
                controller.Target = dtpse.Entity
            end
        end
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            controller.Target = dt.Entity
        end
    end

    if IsValid(dtn.Entity) and dtn.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if game.GetMap() ~= "zs_bunkerhouse" then
                controller.Target = dtn.Entity
            end
        end
    end

    if IsValid(dtp.Entity) and dtp.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if game.GetMap() ~= "zs_bunkerhouse" then
                controller.Target = dtp.Entity
            end
        end
    end

    if IsValid(dtne.Entity) and dtne.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if dtne.Entity:GetModel() == "models/props_junk/vent001.mdl" then
                dtne.Entity:Fire("Break", bot, 0)
            end
            if game.GetMap() ~= "zs_bunkerhouse" then
                controller.Target = dtne.Entity
            end
        end
    end

    if IsValid(dtpe.Entity) and dtpe.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if dtpe.Entity:GetModel() == "models/props_junk/vent001.mdl" then
                dtpe.Entity:Fire("Break", bot, 0)
            end
            if game.GetMap() ~= "zs_bunkerhouse" then
                controller.Target = dtpe.Entity
            end
        end
    end

    if IsValid(dtnse.Entity) and dtnse.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if game.GetMap() ~= "zs_bunkerhouse" then
                controller.Target = dtnse.Entity
            end
        end
    end

    if IsValid(dtpse.Entity) and dtpse.Entity:GetClass() == "prop_physics" then
        if bot:Team() ~= TEAM_SURVIVORS and controller.Target == nil or bot:Team() ~= TEAM_SURVIVORS and not controller.Target:IsPlayer() then
            if game.GetMap() ~= "zs_bunkerhouse" then
                controller.Target = dtpse.Entity
            end
        end
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "func_breakable_surf" then
        controller.Target = dt.Entity
    end

    if IsValid(dt.Entity) and dt.Entity:GetClass() == "prop_dynamic" then
        dt.Entity:Fire("Break", bot, 0)
    end

    if bot:Team() ~= TEAM_SURVIVORS and bot.hidingspot or bot:LBGetStrategy() <= 3 and bot.hidingspot then
        bot.hidingspot = nil
    end

    if DEBUG then
        debugoverlay.Text(bot:EyePos(), bot:Nick(), 0.03, false)
        local min, max = bot:GetHull()
        debugoverlay.Box(bot:GetPos(), min, max, 0.03, Color(255, 255, 255, 0))

        if bot.hidingspot then
            debugoverlay.Text(bot.hidingspot, bot:Nick() .. "'s hiding spot!", 0.1, false)
        end
    end

    if !IsValid(controller.Target) and (!controller.PosGen or bot:GetPos():DistToSqr(controller.PosGen) < 1000 or controller.LastSegmented < CurTime()) then
        -- find a random spot on the map if human, and then do it again in 5 seconds!
        if bot:Team() ~= TEAM_ZOMBIE and bot:LBGetStrategy() <= 3 then
            controller.PosGen = controller:FindSpot("random", {radius = 1000000})
            controller.LastSegmented = CurTime() + 5
        elseif bot:Team() ~= TEAM_ZOMBIE and bot:LBGetStrategy() > 3 and bot:LBGetStrategy() < 7 then 
            -- hiding ai
            if !bot.hidingspot then
                local area = table.Random(HidingSpots)

                if #area[2] > 0 and controller.loco:IsAreaTraversable(area[1]) then
                    local spot = table.Random(area[2])
                    bot.hidingspot = spot
                end
            else
                local dist = bot:GetPos():DistToSqr(bot.hidingspot)
                if dist < 1200 then -- we're here
                    controller.PosGen = nil
                else -- we need to run...
                    controller.PosGen = bot.hidingspot
                end
            end

            controller.LastSegmented = CurTime() + 1000000

        elseif bot:Team() ~= TEAM_ZOMBIE and bot:LBGetStrategy() >= 7 then 
            for k, v in RandomPairs(player.GetAll()) do 
                if IsValid(v) and v:Team() ~= TEAM_ZOMBIE then 
                    controller.PosGen = v:GetPos()
                    controller.LastSegmented = CurTime() + 1000000
                end
            end
        end
        -- find survivor position and update every 5 seconds to find campers
        if bot:Team() ~= TEAM_SURVIVORS and team.NumPlayers(TEAM_SURVIVORS) ~= 0 then
            for k, v in RandomPairs(player.GetAll()) do 
                if IsValid(v) and v:Team() ~= TEAM_ZOMBIE then 
                    controller.PosGen = v:GetPos()
                    controller.LastSegmented = CurTime() + 1000000
                end
            end
        end
    elseif IsValid(controller.Target) then
        -- move to our target
        local distance = controller.Target:GetPos():DistToSqr(bot:GetPos())
        controller.PosGen = controller.Target:GetPos()

        -- back up if the target is really close
        -- TODO: find a random spot rather than trying to back up into what could just be a wall
        -- something like controller.PosGen = controller:FindSpot("random", {pos = bot:GetPos() - bot:GetForward() * 350, radius = 1000})?

        if bot:Health() > 70 then 
            if bot:Team() ~= TEAM_ZOMBIE and distance <= 45000 then
                mv:SetForwardSpeed(-1200)
            end
        elseif bot:Health() <= 70 and bot:Health() > 40 then 
            if bot:Team() ~= TEAM_ZOMBIE and distance <= 90000 then
                mv:SetForwardSpeed(-1200)
            end
        elseif bot:Health() <= 40 and bot:Health() > 10 then 
            if bot:Team() ~= TEAM_ZOMBIE and distance <= 135000 then
                mv:SetForwardSpeed(-1200)
            end
        elseif bot:Health() <= 10 then 
            if bot:Team() ~= TEAM_ZOMBIE and distance <= 180000 then
                mv:SetForwardSpeed(-1200)
            end
        end

        local tier2 = GetConVar("zs_rewards_1"):GetInt()
        local tier3 = GetConVar("zs_rewards_3"):GetInt()
        local tier4 = GetConVar("zs_rewards_4"):GetInt()

        if bot:Team() ~= TEAM_ZOMBIE and distance > 30000 then 
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
        elseif bot:Team() ~= TEAM_ZOMBIE and distance <= 30000 then 
            if bot:LBGetStrategy() == 0 or bot:LBGetStrategy() == 7 then 
                if bot:Frags() >= tier4 then
                    bot:SelectWeapon("weapon_zs_sweepershotgun")
                    bot:SelectWeapon("weapon_zs_slugrifle")
                else 
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
                end
            elseif bot:LBGetStrategy() == 1 or bot:LBGetStrategy() == 5 then 
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
            elseif bot:LBGetStrategy() == 2 or bot:LBGetStrategy() == 3 then 
                if bot:Frags() < tier2 then 
                    bot:SelectWeapon("weapon_zs_battleaxe")
                    bot:SelectWeapon("weapon_zs_peashooter")
                elseif bot:Frags() >= tier2 then
                    bot:SelectWeapon("weapon_zs_deagle")
                    bot:SelectWeapon("weapon_zs_magnum")
                    bot:SelectWeapon("weapon_zs_glock3")
                end
            elseif bot:LBGetStrategy() == 4 or bot:LBGetStrategy() == 6 then 
                bot:SelectWeapon("weapon_zs_battleaxe")
                bot:SelectWeapon("weapon_zs_peashooter")
            end
        end
        if bot:Team() ~= TEAM_SURVIVORS and distance <= 1000000000 then 
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

        if bot:GetVelocity():Length2DSqr() <= 225 then
            if controller.NextCenter < CurTime() then
                controller.strafeAngle = ((controller.strafeAngle == 1 and 2) or 1)
                controller.NextCenter = CurTime() + math.Rand(0.3, 0.65)
            elseif controller.nextStuckJump < CurTime() then
                if !bot:Crouching() then
                    controller.NextJump = 0
                end
                controller.nextStuckJump = CurTime() + math.Rand(1, 2)
            end
        end

        if controller.NextCenter > CurTime() then
            if controller.strafeAngle == 1 then
                mv:SetSideSpeed(1500)
            elseif controller.strafeAngle == 2 then
                mv:SetSideSpeed(-1500)
            else
                if bot:Team() ~= TEAM_ZOMBIE then
                    mv:SetForwardSpeed(-1500)
                end
            end
        end

        -- jump
        if controller.NextJump ~= 0 and curgoal.type > 1 and controller.NextJump < CurTime() or controller.NextJump ~= 0 and curgoal.area:GetAttributes() == NAV_MESH_JUMP and controller.NextJump < CurTime() then
            controller.NextJump = 0
        end

        -- duck
        if curgoal.area:GetAttributes() == NAV_MESH_CROUCH then
            controller.NextDuck = CurTime() + 0.1
        end

        controller.goalPos = goalpos

        if DEBUG then
            controller.P:Draw()
        end

        mva = ((goalpos + bot:GetCurrentViewOffset()) - bot:GetShootPos()):Angle()

        mv:SetMoveAngles(mva)
    else
        if bot:Team() ~= TEAM_ZOMBIE then
            mv:SetForwardSpeed(-1200)
        end
        if bot:Team() ~= TEAM_SURVIVORS then
            mv:SetForwardSpeed(1200)
        end
    end

    if IsValid(controller.Target) and controller.Target:IsPlayer() then
        if controller.Target:GetZombieClass() < 2 or controller.Target:GetZombieClass() == 5 then
            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
        end
        if controller.Target:GetZombieClass() >= 2 and controller.Target:GetZombieClass() < 5 then
            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
        end
        if controller.Target:GetZombieClass() >= 6 then
            bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - controller.Target:GetViewOffsetDucked() - controller.Target:GetViewOffsetDucked() - bot:GetShootPos()):Angle()))
        end
        return
    elseif IsValid(controller.Target) and not controller.Target:IsPlayer() then
        bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:GetPos() - bot:GetShootPos()):Angle()))
    elseif curgoal then
        if controller.LookAtTime > CurTime() then
            local ang = LerpAngle(lerpc, bot:EyeAngles(), controller.LookAt)
            bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
        else
            local ang = LerpAngle(lerpc, bot:EyeAngles(), mva)
            bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
        end
    elseif bot.hidingspot then
        bot.NextSearch = bot.NextSearch or CurTime()
        bot.SearchAngle = bot.SearchAngle or Angle(0, 0, 0)

        if bot.NextSearch < CurTime() then
            bot.NextSearch = CurTime() + math.random(2, 3)
            bot.SearchAngle = Angle(math.random(-40, 40), math.random(-180, 180), 0)
        end

        bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), bot.SearchAngle))
    end
end

hook.Add("PlayerDisconnected", "LeadBot_Disconnect", function(bot)
    if IsValid(bot.ControllerBot) then
        bot.ControllerBot:Remove()
    end
end)

hook.Add("SetupMove", "LeadBot_Control", function(bot, mv, cmd)
    if bot:IsLBot() then
        LeadBot.PlayerMove(bot, cmd, mv)
    end
end)

hook.Add("StartCommand", "LeadBot_Control", function(bot, cmd)
    if bot:IsLBot() then
        LeadBot.StartCommand(bot, cmd)
    end
end)

hook.Add("PostPlayerDeath", "LeadBot_Death", function(bot)
    if bot:IsLBot() then
        LeadBot.PostPlayerDeath(bot)
    end
end)

hook.Add("Think", "LeadBot_Think", function()
    LeadBot.Think()
end)

hook.Add("PlayerSpawn", "LeadBot_Spawn", function(bot)
    if bot:IsLBot() then
        LeadBot.PlayerSpawn(bot)
    end
end)

hook.Add( "PlayerDeath", "SurvivorBotHealPerKill", function( victim, inflictor, attacker )
    if GetConVar("leadbot_hcheats"):GetInt() >= 1 then 
        if IsValid(attacker) and attacker:IsPlayer() and attacker:IsBot() and attacker:Team() ~= TEAM_ZOMBIE then 
            attacker:SetMaxHealth(1000000)
            if attacker:Frags() <= GetConVar("zs_rewards_2"):GetInt() then
                attacker:SetHealth(attacker:Health() + (60 / GetConVar("zs_rewards_2"):GetInt()))
            elseif attacker:Frags() > GetConVar("zs_rewards_2"):GetInt() and attacker:Frags() <= GetConVar("zs_rewards_6"):GetInt() then
                attacker:SetHealth(attacker:Health() + math.Round((60 / (GetConVar("zs_rewards_6"):GetInt() - GetConVar("zs_rewards_2"):GetInt()))))
            else 
                attacker:SetHealth(attacker:Health() + (60 / GetConVar("zs_rewards_6"):GetInt()))
            end
        end
    end
end )

timer.Create("zombieIgnore", 10, 9999, function() for k, v in pairs(player.GetBots()) do
    if v:Team() ~= TEAM_SURVIVORS and team.NumPlayers(TEAM_SURVIVORS) ~= 0 then 
            for _, ply in RandomPairs(player.GetAll()) do
                if ply:Team() ~= TEAM_ZOMBIE then
                    local controller = v.ControllerBot 
                    if IsValid(controller.Target) and not controller.Target:IsPlayer() then
                        controller.Target = ply
                        controller.ForgetTarget = CurTime() + 5
                    end
                end
            end
        end
    end end )

timer.Create("zombieStuckDetector", 20, 9999, function() for k, v in pairs(player.GetBots()) do
    local controller = v.ControllerBot 
                if v:Team() ~= TEAM_SURVIVORS then
                    if v:GetVelocity():Length2DSqr() <= 225 and v:Team() ~= TEAM_SURVIVORS then
                        if controller.Target == nil or v:GetZombieClass() > 5 and v:GetZombieClass() ~= 9 or v:GetZombieClass() == 4 then 
                            v:Kill()
                        end
                    end
                end
    end end )

timer.Start("zombieIgnore")
timer.Start("zombieStuckDetector")

function LeadBot.PostPlayerDeath(bot)
    bot.hidingspot = nil
end

if !DEBUG then return end

concommand.Add("hidingSpot", function(ply, _, args)
    addSpots()
end)