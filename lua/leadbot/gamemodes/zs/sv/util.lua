ZSUtil = {}

function ZSUtil.chance(chance)
    return math.random(0, 100) <= chance
end





function ZSUtil.IsFacingEnt(ent1, ent2)
    if not IsValid(ent1) or not IsValid(ent2) then return false end

    local eyePos = ent1:EyePos()
    local eyeAngles = ent1:EyeAngles()

    local forward = eyeAngles:Forward()
    local toEnt = ent2:GetPos() - eyePos
    toEnt:Normalize()

    local dotProduct = forward:Dot(toEnt)

    return dotProduct > 0.55
end





local wantedCmdClasses = {
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true,
    ["func_breakable"] = true,
    ["func_physbox"] = true,
    ["prop_physics"] = true,
    ["func_breakable_surf"] = true,
    ["prop_dynamic"] = true,
    ["player"] = true,
    ["predicted_viewmodel"] = true
}
local wantedCmdEnts = {
    ["NPCs"] = {}
}
for k,v in pairs(wantedCmdClasses) do
    wantedCmdEnts[k] = {}
end

local nextBotEntsScanDelay = 0.5
local nextBotEntsScan = {
    -- [bot] = { next = time, foundEnts = table }
}

function ZSUtil.findEnts(bot)
    local lastScan = nextBotEntsScan[bot]
    local now = CurTime()

    if lastScan and lastScan.next > now then
        return lastScan.foundEnts
    end

    -- Find visible near targets
        -- ents.FindInBox uses a Spatial Partition to avoid looping through all entities,
    local nearEnts = ents.FindInBox(bot:GetPos() + Vector(1500, 1500, 1500), bot:GetPos() - Vector(1500, 1500, 1500))

    local foundEnts = {
        area = table.Copy(wantedCmdEnts),
        near = table.Copy(wantedCmdEnts),
        facing = table.Copy(wantedCmdEnts)
    }

    for k, ent in ipairs(nearEnts) do
        if IsValid(ent) and (wantedCmdClasses[ent:GetClass()] or ent:IsNPC()) then
            if bot:VisibleVec(ent:GetPos()) then
                local index = ent:IsNPC() and "NPCs" or ent:GetClass()

                table.insert(foundEnts.area[index], ent)

                if ZSUtil.IsFacingEnt(bot, ent) then
                    table.insert(foundEnts.facing[index], ent)
                end

                if ent:GetPos():DistToSqr(bot:GetPos()) < 90 then
                    table.insert(foundEnts.near[index], ent)
                end
            end
        end
    end

    if lastScan then
        lastScan.next = now + nextBotEntsScanDelay
        lastScan.foundEnts = foundEnts
    else
        nextBotEntsScan[bot] = {
            next = now + nextBotEntsScanDelay,
            foundEnts = foundEnts    
        }
    end

    return foundEnts    
end