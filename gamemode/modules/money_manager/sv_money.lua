CSGOGamemode.Money = {}

local tRoundLoose =
{
    ["Diffuser"] = 0,
    ["Terrorist"] = 0
}

local tLoseMoney = {
    1400,
    1900,
    2400,
    2900,
    3400
}

local tListRoundFinish =
{
    ["time_finished"] = function(pPlayer, iLoseMoney, tActualRound)
        if pPlayer:IsDiffuser() then
            return 3250 
        else
            if pPlayer:Alive() then
                return 0
            else
                return iLoseMoney
            end
        end
    end,
    ["bomb_diffused"] = function(pPlayer, iLoseMoney, tActualRound)
        return pPlayer:IsDiffuser() and 3500 or iLoseMoney + 300
    end,
    ["bomb_explode"] = function(pPlayer, iLoseMoney, tActualRound)
        return pPlayer:IsDiffuser() and iLoseMoney or 3500
    end,
    ["team_dead"] = function(pPlayer, iLoseMoney, tActualRound)
        return pPlayer:GetTeam():GetName() == tActualRound:GetWinner():GetName() and 3250 or iLoseMoney
    end
}

function CSGOGamemode.Money:ResetMoney()
    tRoundLoose["Diffuser"] = 0
    tRoundLoose["Terrorist"] = 0

    local tAllPlayer = player.GetAll()
    for i = 1, #tAllPlayer do
        tAllPlayer[i].CSGO_GM_Money = 0
    end
end

--[[
    Money Manager: player metatable
]]

local pPlayer = FindMetaTable("Player")

function pPlayer:GiveMoney()
    local tActualRound = CSGOGamemode.GameManager:GetActualRound()
    local sHowTeamWin = tActualRound:GetHowTeamWinRound()

    if tActualRound:GetRounds() == 1 then
        self:AddMoney(800)
        return
    end

    local sSelfTeam = self:GetTeam():IsDiffuser() and "Diffuser" or "Terrorist"
    local sWinnerTeam = tActualRound:GetWinner():IsDiffuser() and "Diffuser" or "Terrorist"
    local sLooserTeam = sWinnerTeam == "Diffuser" and "Terrorist" or "Diffuser"

    if tRoundLoose[sWinnerTeam] > 0 then
        tRoundLoose[sWinnerTeam] = tRoundLoose[sWinnerTeam] - 1
    end

    if tRoundLoose[sLooserTeam] < 4 then
        tRoundLoose[sLooserTeam] = tRoundLoose[sLooserTeam] + 1
    end

    local iSalaryOfRound = tListRoundFinish[sHowTeamWin](self, tLoseMoney[tRoundLoose[sSelfTeam]+1], tActualRound)

    self:AddMoney(iSalaryOfRound)

    print(self:Nick().." have "..self:GetMoney().."$")

    return self:GetMoney()
end

function pPlayer:AddMoney(amount)
    if amount < 0 then
        if amount >= self:GetNWInt("CSGO_GM_Money") then
            self:SetNWInt("CSGO_GM_Money", 0)
        end

        self:SetNWInt("CSGO_GM_Money", self:GetNWInt("CSGO_GM_Money") - amount)
    end

    if amount > 0 then
        self:SetNWInt("CSGO_GM_Money", self:GetNWInt("CSGO_GM_Money") + amount)
    end

    return self:GetNWInt("CSGO_GM_Money")
end

function pPlayer:GetMoney()
    return self:GetNWInt("CSGO_GM_Money")
end
