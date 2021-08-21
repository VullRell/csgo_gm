CSGOGamemode.Spawn = {}
CSGOGamemode.Spawn.SpawnList = 
{
    ["AT"] = {},
    ["T"] = {}
}

CSGOGamemode.Spawn.__index = CSGOGamemode.Spawn

--[[
    Spawn manager: Metatable
]]

--lua_run CSGOGamemode.Spawn:Add(Vector(21323, 2122, 122), "AT")

function CSGOGamemode.Spawn:Add(vPos, sWhichTeam)
    if not isvector(vPos) or sWhichTeam != "AT" and sWhichTeam != "T" then 
        return
    end

    local tNewSpawn = {}
    tNewSpawn["pos"] = vPos
    tNewSpawn["team"] = sWhichTeam

    setmetatable(tNewSpawn, CSGOGamemode.Spawn)
    tNewSpawn:Save()

    return tNewSpawn
end

function CSGOGamemode.Spawn:GetPos()
    return self["pos"]
end

function CSGOGamemode.Spawn:GetSide()
    return self["team"]
end

function CSGOGamemode.Spawn:Save()
    local bPosExist = sql.Query("SELECT * FROM CSGO_GM_Spawn WHERE Position = "..SQLStr(self:GetPos())..";")

    if bPosExist then
        return false
    end

    self.SpawnList[self:GetSide()][ #self.SpawnList[self:GetSide()] + 1 ] = self
    sql.Query("INSERT INTO CSGO_GM_Spawn VALUES("..SQLStr(self:GetPos())..","..SQLStr(self:GetSide())..");")

    return true
end

--[[
    Spawn Manager: Utils
]]

function CSGOGamemode.Spawn:Load()
    local tAllSpawns = sql.Query("SELECT * FROM CSGO_GM_Spawn")

    if not tAllSpawns then
        return false
    end

    for i = 1, #tAllSpawns do
        local tSpawnInfo = tAllSpawns[i]
        
        if not tSpawnInfo.Side or not tSpawnInfo.Position then
            continue
        end

        self.SpawnList[tSpawnInfo.Side][ #self.SpawnList[tSpawnInfo.Side] + 1 ] = self:Add(Vector(tSpawnInfo.Position), tSpawnInfo.Side)
    end
end

--Load spawn when server load file
CSGOGamemode.Spawn:Load()

function CSGOGamemode.Spawn:GetSpawnCount(sSpawnSide)
    return #self.SpawnList[sSpawnSide]
end

function CSGOGamemode.Spawn:GetSpawn(iSpawnID, sSpawnSide)
    return self.SpawnList[sSpawnSide][iSpawnID]
end

--[[
    Spawn manager: Player meta
]]

local pPlayer = FindMetaTable("Player")

local tSpawnTake = {}
local iPlayerSpawned = 0
local spawnManager = CSGOGamemode.Spawn

function pPlayer:SpawnToSide()
    local sTeamShortName = self:GetTeamShortName()
    local iSpawnCount = spawnManager:GetSpawnCount(sTeamShortName)
    local iNewSpawn = math.random(1, iSpawnCount)

    while tSpawnTake[iNewSpawn] do
        iNewSpawn = math.random(1, iSpawnCount)
    end

    if not self:Alive() then
        self:Spawn()
    end

    local tNewSpawn = spawnManager:GetSpawn(iNewSpawn, sTeamShortName)
    
    if not tNewSpawn then
        return
    end

    self:SetPos(tNewSpawn:GetPos())

    tSpawnTake[iNewSpawn] = true
    iPlayerSpawned = iPlayerSpawned + 1

    if iPlayerSpawned == player.GetCount() then
        tSpawnTake = {}
        iPlayerSpawned = 0
    end
end

--[[
    Spawn manager: command
]]

concommand.Add("CSGO_GM_AddSpawn", function(pPlayer, _, args)
    if not IsValid(pPlayer) or not pPlayer:IsPlayer() then
        return
    end

    if not pPlayer:IsAdmin() then
        return
    end

    if args[1] != "AT" and args[1] != "T" then
        return
    end

    spawnManager:Add(pPlayer:GetPos(), args[1])
    pPlayer:PrintMessage(HUD_PRINTTALK, "Spawn successfuly added for "..args[1].." and position "..tostring(pPlayer:GetPos()))
end)
