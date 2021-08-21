CSGOGamemode.GameManager = {}
CSGOGamemode.GameManager.__index = CSGOGamemode.GameManager

local iBombTimer = server:GetBombTimer()
local iRoundToWin = server:GetRoundToWin()
local sTimerName = "VRRoundTimer::EndRound::GameManager"
local tActualRound
local bGameStart

function CSGOGamemode.GameManager:Start()
    local tNewGame = {}
    tNewGame["iRoundCount"] = 1
    tNewGame["iATWin"] = 0
    tNewGame["iTWin"] = 0
    tNewGame["iCurrentTime"] = CurTime()
    tNewGame["tTeamWinRound"] = {}
    tNewGame["sHowWinRound"] = ""
    tNewGame["bBombPlanting"] = false

    setmetatable(tNewGame, CSGOGamemode.GameManager)
    tNewGame:SendPacket()

    timer.Create("CSGO_GM_LaunchingTimerSV", server:GetLaunchGameTime(), 1, function()
        if player.GetCount() < server:GetStartPlayer() then
            return
        end

        hook.Add("OnBombIsDiffused", "VRHook::Diffusing::GameManager", function()
            timer.Destroy(sTimerName)
            self:ChangeRound(sDiffuserTeam, "bomb_diffused")
        end)
        hook.Add("OnBombExploded", "VRHook::BombExplosion::GameManager", function()
            timer.Destroy(sTimerName)
            self:ChangeRound(sDiffuserTeam, "bomb_explode")
        end)

        tActualRound = tNewGame
        tNewGame:Setup()
        bGameStart = true
    end)

    return tNewGame
end

--[[
    Round Manager: Get metatable info
]]

function CSGOGamemode.GameManager:GetRounds()
    return self["iRoundCount"]
end

function CSGOGamemode.GameManager:GetATRoundWin()
    return self["iATWin"]
end

function CSGOGamemode.GameManager:GetTRoundWin()
    return self["iTWin"]
end

function CSGOGamemode.GameManager:GetRoundTimeLeft()
    return self["iCurrentTime"]
end

function CSGOGamemode.GameManager:GetBombPlanted()
    return self["bBombPlanting"]
end

function CSGOGamemode.GameManager:GetWinner()
    return self["tTeamWinRound"]
end

function CSGOGamemode.GameManager:GetHowTeamWinRound()
    return self["sHowWinRound"]
end

--[[
    Round Manager: Utils
]]

local teamManag

function CSGOGamemode.GameManager:Setup()
    if not teamManag then
        teamManag = CSGOGamemode.TeamManager
    end

    local tAllPlayer = player.GetAll()
    local iRandomBomb = math.random(1, teamManag:GetTerroristTeam():GetPlayerCount())

    for i = 1, #tAllPlayer do
        local pPlayer = tAllPlayer[i]

        if pPlayer:Spectating() then
            pPlayer:UnSpectate()
        end

        pPlayer:SpawnToSide()

        timer.Simple(.1, function()
            pPlayer:Lock()
        end)

        if not pPlayer:GetTeam():IsDiffuser() and i == iRandomBomb then
            pPlayer:Give("vr_bomb")
        end

        pPlayer:GiveMoney()
    end

    self["bBombPlanting"] = false

    CSGOGamemode.NetManager:SendNet(2, function()
        net.WriteUInt(2, 3)
    end)

    timer.Simple(10, function()
        CSGOGamemode.NetManager:SendNet(2, function()
            net.WriteUInt(3, 3)
        end)

        timer.Create(sTimerName, iBombTimer, 1, function()
            self:ChangeRound(true, "time_finished")
        end)
        self["iCurrentTime"] = CurTime()

        for i = 1, #tAllPlayer do
            tAllPlayer[i]:UnLock()
        end
    end)
end

function CSGOGamemode.GameManager:ChangeRound(bDiffuserWin, sWinType)
    print("[Change Round] Win type : "..sWinType)
    self["iCurrentTime"] = CurTime()
    self["iRoundCount"] = self["iRoundCount"] + 1
    self["tTeamWinRound"] = bDiffuserWin and teamManag:GetDiffuserTeam() or teamManag:GetTerroristTeam()
    self["sHowWinRound"] = sWinType

    local sActualTeam = bDiffuserWin and "iATWin" or "iTWin"
    self[sActualTeam] = self[sActualTeam] + 1
    
    CSGOGamemode.NetManager:SendNet(2, function()
        net.WriteUInt(4, 3)
        net.WriteString(sActualTeam)
    end)

    print(sActualTeam.." win the round !")

    if self[sActualTeam] >= iRoundToWin then
        print(sActualTeam.." has won !")
        tActualRound = nil
        bGameStart = false
        return
    end

    timer.Simple(5, function()
        self:Setup()
    end)

    return self
end

function CSGOGamemode.GameManager:SendPacket()
    CSGOGamemode.NetManager:SendNet(1, function()
        net.WriteUInt(1, 1)
        net.WriteUInt(0, 1)
        net.WriteUInt(0, 1)
    end)
    CSGOGamemode.NetManager:SendNet(2, function()
        net.WriteUInt(5, 3)
    end)
end

function CSGOGamemode.GameManager:GetActualRound()
    return tActualRound
end

function CSGOGamemode.GameManager:GameStarted()
    return bGameStart
end
