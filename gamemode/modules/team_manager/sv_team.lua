CSGOGamemode.TeamManager = {}
CSGOGamemode.TeamManager.AllTeams = {}
CSGOGamemode.TeamManager.__index = CSGOGamemode.TeamManager

function CSGOGamemode.TeamManager:NewTeam(sTeamName, bIsDiffuser, iMaxPlayers)
    local team = {}
    team["name"] = sTeamName
    team["isDiffuser"] = bIsDiffuser
    team["max_players"] = iMaxPlayers
    team["player_count"] = 0
    team["players_list"] = {}

    setmetatable(team, CSGOGamemode.TeamManager)
    CSGOGamemode.TeamManager.AllTeams[sTeamName] = team

    if bIsDiffuser then
        CSGOGamemode.TeamManager.diffuserTeam = team
    else
        CSGOGamemode.TeamManager.terroristTeam = team
    end

    return team
end

--[[
    Team Manager: Get metatable info
]]

function CSGOGamemode.TeamManager:GetName()
    return self["name"]
end

function CSGOGamemode.TeamManager:IsDiffuser()
    return self["isDiffuser"]
end

function CSGOGamemode.TeamManager:HasPlayer(pPlayer)
    return self["players_list"][pPlayer]
end

function CSGOGamemode.TeamManager:GetPlayers()
    return self["players_list"]
end

function CSGOGamemode.TeamManager:GetPlayerCount()
    return self["player_count"]
end

function CSGOGamemode.TeamManager:GetColor()
    return self:IsDiffuser() and server:GetATColor() or server:GetTColor()
end

function CSGOGamemode.TeamManager:CanJoin()
    return self["player_count"] + 1 <= self["max_players"]
end

--[[
    Team Manager: Set metatable info
]]


function CSGOGamemode.TeamManager:AddPlayerCount(int)
    if not isnumber(int) then
        return
    end

    if int > 0 then
        self["player_count"] = self["player_count"] + int
    elseif int < 0 then
        self["player_count"] = self["player_count"] - (int*-1)
    end
end

--[[
    Team Manager: Utils
]]

function CSGOGamemode.TeamManager:GetTeams()
    return CSGOGamemode.TeamManager.AllTeams
end

function CSGOGamemode.TeamManager:GetTeamByName(sTeamName)
    return CSGOGamemode.TeamManager.AllTeams[sTeamName] or {}
end

local iLastTeamJoin = 1
local tAllTeams

function CSGOGamemode.TeamManager:SearchTeam(pPlayer)
    if CSGOGamemode.GameManager:GameStarted() then
        pPlayer:Kick("[CSGO] The game have been already started")
        return
    end

    if player.GetCount() >= server:GetMaxPlayer() then
        pPlayer:Kick("[CSGO] There are most player !")
        return
    end

    tAllTeams = tAllTeams or CSGOGamemode.TeamManager.GetTeams()

    local i = 1
    for sTeamName, tTeamInfo in pairs(tAllTeams) do
        if iLastTeamJoin % 2 == i or not tTeamInfo:CanJoin() then
            i = i + 1
            continue
        end
        
        pPlayer:JoinTeam(sTeamName)
        iLastTeamJoin = iLastTeamJoin + 1
        return
    end

    pPlayer:Kick("[CSGO] All teams is full !")
end

function CSGOGamemode.TeamManager:GetDiffuserTeam()
    return CSGOGamemode.TeamManager.diffuserTeam
end

function CSGOGamemode.TeamManager:GetTerroristTeam()
    return CSGOGamemode.TeamManager.terroristTeam
end

    --[[
        Hook which influence the function of utils
    ]]

local function changeLastTeam()
    iLastTeamJoin = iLastTeamJoin - 1
end
CSGOGamemode:HookRegister("PlayerDisconnected", "VRHook::ChangeTeam::TeamManager", changeLastTeam)

--[[
    Team Manager: player meta
]]

local pPlayer = FindMetaTable("Player")

function pPlayer:JoinTeam(sTeamName)
    local tNewPlayerTeam = CSGOGamemode.TeamManager:GetTeamByName(sTeamName)
    if not tNewPlayerTeam then
        return
    end

    if tNewPlayerTeam:CanJoin() then
        if tNewPlayerTeam:HasPlayer(self) then
            return
        end

        tNewPlayerTeam:AddPlayerCount(1)
        tNewPlayerTeam["players_list"][self] = true
    end
    
    self.CSGO_GM_ActualTeam = tNewPlayerTeam
    self:SetNWString("CSGO_GM_TeamColor", string.FromColor(tNewPlayerTeam:GetColor()))

    print(self:SteamID64().." have joined "..sTeamName)

    if player.GetCount() >= server:GetStartPlayer() then
        CSGOGamemode.GameManager:Start()
    else
        CSGOGamemode.NetManager:SendNet(2, function()
            net.WriteUInt(1, 3)
        end, self)
    end

    return tNewPlayerTeam
end

function pPlayer:GetTeam()
    return self.CSGO_GM_ActualTeam
end

function pPlayer:GetTeamShortName()
    return self:GetTeam():IsDiffuser() and "AT" or "T"
end

function pPlayer:LeaveTeam()
    local tPlayerTeam = self:GetTeam()

    if table.IsEmpty(tPlayerTeam) then
        return
    end

    tPlayerTeam:AddPlayerCount(-1)
    tPlayerTeam["players_list"][self] = nil

    print(self:SteamID64().." have left "..tPlayerTeam:GetName())
end
