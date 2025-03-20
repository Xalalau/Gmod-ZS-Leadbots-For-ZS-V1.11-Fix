-- basically finished :I --f
--      By Tony Dosk Enginooy. 8====================================================================================D 
--         This module is intended to run with ZS v1.11 Fix by Xalalau

if game.SinglePlayer() or CLIENT then
    return
end

--[[GAMEMODE CONFIGURATION START]]--

LeadBot.Gamemode = "zombiesurvival"
LeadBot.RespawnAllowed = true -- allows bots to respawn automatically when dead
LeadBot.PlayerColor = true -- disable this to get the default gmod style players
LeadBot.CheckNavMesh = true -- disable the nav mesh check
LeadBot.TeamPlay = true -- don't hurt players on the bots team
LeadBot.AFKBotOverride = false -- KEEP THIS FALSE OR ELSE CODE BREAKS!
LeadBot.SuicideAFK = false -- kill the player when entering/exiting afk
LeadBot.NoFlashlight = true -- disable flashlight being enabled in dark areas
LeadBot.Strategies = 3 -- how many strategies can the bot pick from

--[[GAMEMODE CONFIGURATION END]]--

ZSB = {
    Map = {},
    Util= {},

    DEBUG = false,
    INTERMISSION = 1,
    INTERMISSION_FAKE_TIMER = 60,
    playerCSSpeed = 200
}

concommand.Add("leadbot_add", CmdAddBot, nil, "Adds a LeadBot")
concommand.Add("leadbot_kick", CmdKickBot, nil, "Kicks LeadBots (all is avaliable!)")
CreateConVar("leadbot_strategy", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enables the strategy system for newly created bots.")
CreateConVar("leadbot_names", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot names, seperated by commas.")
CreateConVar("leadbot_models", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot models, seperated by commas.")
CreateConVar("leadbot_name_prefix", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Bot name prefix")
CreateConVar("leadbot_minzombies", "1", {FCVAR_ARCHIVE}, "What Percentage of Leadbots become Zombies at the Beginning (this includes players as well)", 0, 100)
local leadbot_zchance =
CreateConVar("leadbot_zchance", "0", {FCVAR_ARCHIVE}, "If you want a chance to become a zombie when you spawn", 0 , 1)
local leadbot_hordes = 
CreateConVar("leadbot_hordes", "0", {FCVAR_ARCHIVE}, "If you want to play horde mode instead of using quota", 0 , 1)
CreateConVar("leadbot_hinfammo", "1", {FCVAR_ARCHIVE}, "If you want survivor bots to have an infinite amount of clip ammo so that they survive longer", 0 , 1)
CreateConVar("leadbot_hregen", "1", {FCVAR_ARCHIVE}, "If you want survivor bots to heal every time a survivor dies so that they survive longer", 0 , 1)
CreateConVar("leadbot_zcheats", "0", {FCVAR_ARCHIVE}, "If you want zombie bots to cheat a little so that they're better at killing humans'", 0 , 1)
CreateConVar("leadbot_collision", "0", {FCVAR_ARCHIVE}, "If you want bots to not collide with each other or others", 0 , 1)
CreateConVar("leadbot_knockback", "1", {FCVAR_ARCHIVE}, "If you want to not experience any knockback", 0 , 1)
local leadbot_mapchanges =
CreateConVar("leadbot_mapchanges", "0", {FCVAR_ARCHIVE}, "If you want certain things to be removed from certain maps in order for bots to not get stuck and/or confused", 0, 1)
CreateConVar("leadbot_cs", "0", {FCVAR_ARCHIVE}, "If you want THE counter strike ZM experience", 0 , 1)
CreateConVar("leadbot_skill", "4", {FCVAR_ARCHIVE}, "Changes how good the bots' aims are (4 = random)", 0 , 4)

local zs_roundtime = GetConVar("zs_roundtime")
local zs_human_deadline = GetConVar("zs_human_deadline")

resource.AddFile("sound/intermission.mp3")

include("zs/sv/map_init.lua")
include("zs/sv/player_meta.lua")
include("zs/sv/util.lua")
include("zs/sv/add_bot.lua")

local function IncludeFilesInDir(dir)
    local files, dirs = file.Find(dir .. "/*", "LUA")
    for _, f in ipairs(files) do
        include(dir .. "/" .. f)
    end
    for _, d in ipairs(dirs) do
        IncludeFilesInDir(dir .. "/" .. d)
    end
end

IncludeFilesInDir("leadbot/gamemodes/zs/sv/behavior")

include("zs/sv/behavior_hook.lua")

cvars.AddChangeCallback("leadbot_quota", function(_, oldval, val)
    oldval = tonumber(oldval)
    val = tonumber(val)

    if oldval and val and oldval > 0 and val < 1 then
        RunConsoleCommand("leadbot_kick", "all")
    end
end)

function CmdKickBot(ply, _, args)
    if not args[1] or IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    if args[1] ~= "all" then
        for k, bot in ipairs(player.GetBots()) do
            if string.find(bot:GetName(), args[1]) then
                bot:Kick()
                return
            end
        end
    else
        for k, bot in ipairs(player.GetBots()) do
            bot:Kick()
        end
    end
end

function CmdAddBot(ply, _, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local amount = 1
    
    if tonumber(args[1]) then
        amount = tonumber(args[1])
    end
    
    for i = 1, amount do
        timer.Simple(i * 0.1, function()
            LeadBot.AddBot()
        end)
    end
end

function ZSB.InitPostEntity()
    if not game.SinglePlayer() and leadbot_hordes:GetInt() >= 1 then
        timer.Create("Hordes", 60, -1, function() 
            RunConsoleCommand("leadbot_add", "1")
            ZSB.INTERMISSION = 0
        end )
    
        timer.Create("INTERMISSION_MESSAGE", 1, 60, function() 
            PrintMessage( 4, "Infection begins in " .. ZSB.INTERMISSION_FAKE_TIMER .. " Seconds!")
            ZSB.INTERMISSION_FAKE_TIMER = ZSB.INTERMISSION_FAKE_TIMER - 1
        end)
    end

    ZSB.Map.Init()

    timer.Start("zombieNearDetector")
    timer.Start("zombieStuckDetector")
end

hook.Add("PlayerInitialSpawn", "ZS_LeadBot_RealPlayerInitialSpawn", function(ply)
    if ply:IsBot() then return end

    if leadbot_zchance:GetInt() < 1 and INFLICTION < 0.5 or
       leadbot_zchance:GetInt() < 1 and CurTime() <= zs_roundtime:GetInt()*0.5 and not zs_human_deadline:GetBool()
    then 
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

    if leadbot_hordes:GetInt() >= 1 and player.GetCount() == 1 then
        ply:EmitSound("intermission.mp3", CHAN_REPLACE)
        timer.Start("Hordes")
        timer.Start("INTERMISSION_MESSAGE")
    end

    if leadbot_hordes:GetInt() < 1 and player.GetCount() >= 1 then
        timer.Stop("Hordes")
        timer.Stop("INTERMISSION_MESSAGE")
    end
end)