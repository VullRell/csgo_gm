--[[
    Role manager: player metatable
]]

local pPlayer = FindMetaTable("Player")

function pPlayer:SetAdmin()
    local bIsAlreadyAdmin = sql.Query("SELECT * FROM CSGO_GM_Admin WHERE SteamID64 = "..SQLStr(self:SteamID64())..";")

    if bIsAlreadyAdmin then
        return true
    end

    self:SetUserGroup("admin")
    sql.Query("INSERT INTO CSGO_GM_Admin VALUES("..SQLStr(self:SteamID64())..");")

    return true
end

--[[
    Role manager: hooks
]]

local function SetGroup(pPlayer)
    local group = sql.Query("SELECT * FROM CSGO_GM_Admin WHERE SteamID64 = "..SQLStr(pPlayer:SteamID64())..";")

    if not group then
        return
    end

    pPlayer:SetUserGroup("admin")
end
CSGOGamemode:HookRegister("PlayerAuthed", "SetGroup::GroupManager", SetGroup)

--[[
    Role manager: command
]]

concommand.Add("CSGO_GM_AddAdmin", function(pPlayer, _, args)
    if pPlayer and not pPlayer:IsAdmin() then
        return
    end

    if #args[1] != 17 then
        return
    end

    local secondPlayer = player.GetBySteamID64(args[1])

    if not secondPlayer then
        return
    end

    secondPlayer:SetAdmin()
end)
