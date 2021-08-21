function CSGOGamemode:PrintMessage(tTextColor, sTextContent)
    MsgC(tTextColor, "[CSGO Gamemode] "..sTextContent.."\n")
end

function CSGOGamemode:HookRegister(sName, sUniqueName, fCallback)
    hook.Add(sName, "CSGO_GM::"..sUniqueName, fCallback)
end

--[[
    Server: Function which you help to coding
]]

function server:GetMaxPlayer()
    return self.MaxPlayers
end

function server:GetStartPlayer()
    return self.PlayerToStart
end

function server:GetBombTimer() --Time which before bomb explode
    return self.BombTimer
end

function server:GetRoundToWin()
    return self.RoundToWin
end

function server:GetATColor()
    return self.TeamATColor
end

function server:GetTColor()
    return self.TeamTColor
end

function server:GetBombSite()
    return self.BombSitePos
end

function server:GetBombModel()
    return self.BombModel
end

function server:GetLaunchGameTime()
    return self.TimerToLaunchGame
end

--[[
    Function: utils function for CSGO
]]

local function FormatSecond(iLeftTime)
    if not isnumber(iLeftTime) then
        return
    end

    return iLeftTime < 10 and "0"..iLeftTime or iLeftTime
end

local function FormatMinutes(iLeftTime)
    if not isnumber(iLeftTime) then
        return
    end

    return iLeftTime < 10 and "0"..iLeftTime or iLeftTime
end

function math.FormatTimer(iLeftTime)
    if iLeftTime >= 60 then
        return FormatMinutes(math.floor(iLeftTime / 60))..":"..FormatSecond(math.Round(iLeftTime % 60))
    end

    return "00:"..FormatSecond(math.Round(iLeftTime))
end
