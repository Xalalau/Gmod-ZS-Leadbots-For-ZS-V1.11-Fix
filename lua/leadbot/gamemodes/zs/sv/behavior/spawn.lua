-- Cache cvars
local leadbot_cs = GetConVar("leadbot_cs")
local leadbot_knockback = GetConVar("leadbot_knockback")

local survivorClasses = {
    default = 1
}

local zombieClasses
zombieClasses = {
    default = 1,
    [0.5] = {
        toDefault = { [9] = true, [11] = true },
        new = { 1, 5, 6, 7 },
        default = 1,
        getNew = function(bot)
            local clsTab = zombieClasses[0.5]
            local rand = math.random(1, 6)
            local randCls = clsTab.new[rand]
            local zombie = randCls and ZombieClasses[randCls]
            local curCls =  bot:GetZombieClass()
            return (rand > 3 or clsTab.toDefault[curCls]) and clsTab.default or
                    zombie and INFLICTION >= zombie.Threshold and randCls or 
                    clsTab.default
        end
    },
    [0.75] = {
        toDefault = { [9] = true, [11] = true },
        new = { 1, 2, 3, 5, 6, 7, 8 },
        default = 2,
        getNew = function(bot)
            local clsTab = zombieClasses[0.75]
            local totalValidCls = #clsTab.new
            local rand = math.random(1, totalValidCls * 2)
            local randCls = clsTab.new[rand]
            local zombie = randCls and ZombieClasses[randCls]
            local curCls = bot:GetZombieClass()
            return (rand > totalValidCls or clsTab.toDefault[curCls]) and clsTab.default or
                    INFLICTION >= zombie.Threshold and randCls or 
                    clsTab.default
        end
    },
    [1] = {
        toDefault = { [9] = true, [11] = true },
        new = { 1, 2, 3, 4, 5, 6, 7, 8 },
        newWithWeight = { [9] = 4, [12] = 2 },
        default = 4,
        getNew = function(bot)
            local clsTab = zombieClasses[1]
            local totalValidCls = #clsTab.new
            local rand = math.random(1, totalValidCls * 2)
            local randCls = clsTab.new[rand]
            local zombie = randCls and ZombieClasses[randCls]
            local zombieWeight9 = ZombieClasses[clsTab.newWithWeight[9]]
            local zombieWeight12 = ZombieClasses[clsTab.newWithWeight[12]]
            local curCls =  bot:GetZombieClass()
            return rand >= 12 and INFLICTION >= zombieWeight12.Threshold and clsTab.newWithWeight[12] or
                   rand >= 9 and rand < 12 and INFLICTION >= zombieWeight9.Threshold and clsTab.newWithWeight[9] or
                   clsTab.toDefault[curCls] and clsTab.default or
                   rand < totalValidCls and INFLICTION >= zombie.Threshold and randCls or 
                   clsTab.default
        end
    }
}

local function GetClsTab()
    local clsTab
    local lastGotInfliction

    for maxInfliction, newClsTab in pairs(zombieClasses) do
        if not isnumber(maxInfliction) then continue end

        if INFLICTION <= maxInfliction then
            if not lastGotInfliction or maxInfliction < lastGotInfliction then
                lastGotInfliction = maxInfliction
                clsTab = newClsTab
            end
        end
    end

    return clsTab
end

local function StripHumanWeapons(bot)
    local weaps = bot:GetWeapons()

    for _, weap in ipairs(weaps) do
        local weapClass = weap:GetClass()

        if weapons.IsBasedOn(weapClass, "weapon_zs_base") then
            bot:StripWeapon(weapClass)
        end
    end
end

local function SetKnockBack(bot)
    if leadbot_knockback:GetInt() < 1 then 
        bot:AddEFlags(EFL_NO_DAMAGE_FORCES)
    else
        bot:RemoveEFlags(EFL_NO_DAMAGE_FORCES)
    end
end

function LeadBot.Spawn(bot)
    SetKnockBack(bot)

    if bot:Team() == TEAM_SURVIVORS then
        bot:SetZombieClass(survivorClasses.default)
    end

    if bot:Team() == TEAM_ZOMBIE then
        StripHumanWeapons(bot)

        if leadbot_cs:GetBool() then 
            timer.Simple(1, function() 
                if not IsValid(bot) then return end
    
                bot:SetMaxHealth(1000)
                bot:SetHealth(1000) 
            end)
    
            bot:SetZombieClass(zombieClasses.default)
        else
            local clsTab = GetClsTab()
            local nesCls = clsTab.getNew(bot)
    
            bot:SetZombieClass(nesCls)
        end
    end
end