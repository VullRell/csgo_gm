-- CSGOGamemode.ServerManager = {}
-- CSGOGamemode.ServerManager.__index = CSGOGamemode.ServerManager
-- CSGOGamemode.ServerManager.AllServer = {}

-- function CSGOGamemode.ServerManager:SetupSever(iMaxPlayers, tAllTeams)
--     local iServerID = #CSGOGamemode.ServerManager.AllServer + 1

--     local tServerInfo = {}
--     tServerInfo["id"] = iServerID
--     tServerInfo["max_players"] = iMaxPlayers
--     tServerInfo["players"] = {}
--     tServerInfo["total_players"] = 0
--     tServerInfo["teams"] = {}

--     CSGOGamemode.ServerManager.AllServer[iServerID] = tServerInfo

--     for sTeamName, tTeamInfo in pairs(tAllTeams) do
--         tServerInfo["teams"][sTeamName] = CSGOGamemode.TeamManager:NewTeam(iServerID, sTeamName, tTeamInfo["max_players"], tTeamInfo["color"])
--     end

--     setmetatable(tServerInfo, CSGOGamemode.ServerManager)
--     return tServerInfo
-- end

-- function CSGOGamemode.ServerManager:SearchServer()
--     for _, tServerInfo in pairs(CSGOGamemode.ServerManager.AllServer) do
--         if tServerInfo:IsFull() then continue end
--         return tServerInfo
--     end
-- end

-- function CSGOGamemode.ServerManager:GetPlayers()
--     return self["total_players"]
-- end

-- function CSGOGamemode.ServerManager:GetServerByID(iServerID)
--     return CSGOGamemode.ServerManager.AllServer[iServerID]
-- end

-- function CSGOGamemode.ServerManager:IsFull()
--     return self:GetPlayers() >= self["max_players"]
-- end

-- function CSGOGamemode.ServerManager:GetID()
--     return self["id"]
-- end

-- function CSGOGamemode.ServerManager:AddPlayer(ply)
--     if self:IsFull() then
--         return
--     end

--     ply.CSGO_GM_ActualServer = self:GetID()
--     ply.CSGO_GM_ServerPlayerIndex = table.insert(CSGOGamemode.ServerManager.AllServer[self:GetID()]["players"], ply)
--     CSGOGamemode.ServerManager.AllServer[self:GetID()]["total_players"] = self:GetPlayers() + 1

--     for sTeamName, tTeam in pairs(self["teams"]) do
--         if not tTeam:CanJoin() then continue end
--         ply:JoinTeam(self:GetID(), tTeam:GetName())
--         print(ply:SteamID64().." try to join "..tTeam:GetName().." team")
--         break
--     end

--     print(ply:SteamID64().." have joined the server with id : "..self:GetID())
--     print(self:IsFull())
--     print(self:GetPlayers() >= self["max_players"],  self:GetPlayers(), self["max_players"])
--     if self:IsFull() then
--         print("ok")
--         self:StartGame()
--         return
--     end
-- end

-- function CSGOGamemode.ServerManager:RemovePlayer(ply)
--     CSGOGamemode.ServerManager.AllServer[self:GetID()]["players"][ply.CSGO_GM_ServerPlayerIndex] = nil
--     CSGOGamemode.ServerManager.AllServer[self:GetID()]["total_player"] = self:GetPlayers() - 1

--     print(ply:SteamID64().." have left the server with id : "..self:GetID())

--     ply:LeaveTeam(self:GetID())
-- end
