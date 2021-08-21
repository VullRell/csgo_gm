local tStatementList =
{
    {
        ["name"] = "wait_player",
        ["action"] = function()
            CSGOGamemode.Interface.RoundTimer = 0
        end
    },
    {
        ["name"] = "buy_time",
        ["action"] = function()
            CSGOGamemode.Interface.RoundTimer = 10
        end
    },
    {
        ["name"] = "round_time",
        ["action"] = function()
            CSGOGamemode.Interface.RoundTimer = server:GetBombTimer()
        end
    },
    {
        ["name"] = "end_round",
        ["action"] = function()
            CSGOGamemode.Interface.RoundTimer = 5
        end
    },
    {
        ["name"] = "launching_game",
        ["action"] = function()
            local sTextGame = "Lancement de la partie dans "

            local iTimeLeft = LocalPlayer():GetNWInt("CSGO_GM_LaunchingTimer") == 0 and server:GetLaunchGameTime() or LocalPlayer():GetNWInt("CSGO_GM_LaunchingTimer")

            timer.Create("CSGO_GM_LaunchingTimerCL", 1, iTimeLeft - 2, function()
                CSGOGamemode.Interface.LaunchingGameText = sTextGame..math.FormatTimer(iTimeLeft - 2)
                iTimeLeft = iTimeLeft - 1
            end)

            timer.Simple(iTimeLeft, function()
                CSGOGamemode.Interface.LaunchingGameText = false
            end)
        end
    }
}

local function LoadNet()
    CSGOGamemode.NetManager:Register(1, function()
        local tRound = {}
        local tInfoList = 
        {
            "iRoundCount",
            "iATWin",
            "iTWin",
        }

        for i = 1, 3 do
            local sInfoName = tInfoList[i]
            tRound[sInfoName] = net.ReadUInt(5)
        end
        
        CSGOGamemode.Interface.PlayersTeamColor["local"] = string.ToColor(LocalPlayer():GetNWString("CSGO_GM_TeamColor"))

        CSGOGamemode.Interface["round"] = tRound
    end)

    CSGOGamemode.NetManager:Register(2, function()
        local iStatement = net.ReadUInt(3)
        local sTeamWinner = net.ReadString()

        CSGOGamemode.Interface.GameStatement = tStatementList[iStatement]["name"]
        CSGOGamemode.Interface.RoundTimer2 = CurTime()
        tStatementList[iStatement]["action"]()

        if sTeamWinner == "iATWin" then
            CSGOGamemode.Interface.WinATRound = CSGOGamemode.Interface.WinATRound + 1
            CSGOGamemode.Interface.LastTeamRoundWin = "AT"
        elseif sTeamWinner == "iTWin" then
            CSGOGamemode.Interface.WinTRound = CSGOGamemode.Interface.WinTRound + 1
            CSGOGamemode.Interface.LastTeamRoundWin = "T"
        end

        if CSGOGamemode.Interface.GameStatement == "buy_time" then
            hook.Call("OnRoundStart")
        end 
    end)

    CSGOGamemode.NetManager:Register(3, function()
        local iHitCount = net.ReadUInt(3)
        local tAllHit = {}
        for i = 1, iHitCount do
            tAllHit[net.ReadString()] = true
        end

        CSGOGamemode.Interface:AddKill(net.ReadEntity(), net.ReadEntity(), tAllHit)
    end)
end
CSGOGamemode:HookRegister("InitPostEntity", "LoadNet::NetManager", LoadNet)
