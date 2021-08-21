CSGOGamemode.Interface = {}
CSGOGamemode.Interface.DeadList = {}
CSGOGamemode.Interface.GameStatement = ""
CSGOGamemode.Interface.WinATRound = 0
CSGOGamemode.Interface.WinTRound = 0
CSGOGamemode.Interface.LastTeamRoundWin = ""
CSGOGamemode.Interface.LaunchingGameText = false
CSGOGamemode.Interface.RoundTimer = 0
CSGOGamemode.Interface.RoundTimer2 = CurTime()


CSGOGamemode.Interface.ColorTeamAT = server:GetATColor()
CSGOGamemode.Interface.ColorTeamT = server:GetTColor()

CSGOGamemode.Interface.PlayersTeamColor = {}

local interfaceManager = CSGOGamemode.Interface
local fontManager = CSGOGamemode.Font
local respManager = CSGOGamemode.Responsive

local iPlayerAliveAT = 0
local iPlayerAliveT = 0
local iDeadListCount = 0

local rajdhani20
fontManager:AddFont("Rajdhani Bold", 7, _, function(sFontName)
    rajdhani20 = sFontName
end)

local rajdhani30
fontManager:AddFont("Rajdhani Bold", 10, _, function(sFontName)
    rajdhani30 = sFontName
end)

local rajdhani40
fontManager:AddFont("Rajdhani Bold", 15, _, function(sFontName)
    rajdhani40 = sFontName
end)

local x, y

respManager:AddResponsive(function(iScreenX, iScreenY)
    x, y = iScreenX, iScreenY
end)

local tHideHUD = 
{
	["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudWeaponSelection"] = true
}
local tStatementPhrase =
{
    ["wait_player"] = "En attente de joueurs",
    ["buy_time"] = "Achetez votre équipement !",
    ["round_time"] = "Tuez touts vos ennemis",
    ["end_round"] = "Round terminé",
    ["launching_game"] = "Lancement de la partie dans : %s"
}
local tColorList =
{
    ["black_trans"] = Color(0,0,0,200),
}
local tHitImage =
{
    ["flashbang"] = Material("vullrell/cs_flashbang.png"),
    ["headshot"] = Material("vullrell/cs_headshot.png"),
    ["noscope"] = Material("vullrell/cs_noscope.png"),
    ["wallbang"] = Material("vullrell/wallbang.png"),
    ["weapon"] = Material("vullrell/cs_weapon.png"),
    ["terrorist"] = Material("vullrell/cs_terrorist.png"),
    ["c-terrorist"] = Material("vullrell/cs_counter_terrorist.png")
}

--[[
    Interface Manager: Draw HUD
]]

local function UnDrawBasic(sDrawName)
    return not tHideHUD[sDrawName]
end
CSGOGamemode:HookRegister("HUDShouldDraw", "UnDrawBasicInterface::InterfaceManager", UnDrawBasic)

local function GetCenterInY(posy, boxSizeY, textSizeY)
    return (boxSizeY - textSizeY) / 2 + posy --(posy * 2 - textSizeY) / 2 + posy
end

local function GetSentenceSize(sentence, font)
    surface.SetFont(font)
    return surface.GetTextSize(sentence)
end

local function DrawKillFeed(tDeadInfo, posy)
    if not tDeadInfo or tDeadInfo["victim_name"] == tDeadInfo["killer_name"] then 
        return
    end
    if not posy then
        posy = y * .01
    end

    surface.SetFont(rajdhani20)
    local iVTextSizeX, iVTextSizeY = GetSentenceSize(tDeadInfo["victim_name"], rajdhani20)
    local iKTextSizeX = GetSentenceSize(tDeadInfo["killer_name"], rajdhani20)
    local iBoxSizeX = x * .0455 + iVTextSizeX + iKTextSizeX
    local iBoxSizeY = y * .025
    local tHitToShow, iHitCount = {}

    tHitToShow[1] = "weapon"

    if tDeadInfo["wallbang"] then
        iBoxSizeX = iBoxSizeX + x * .0155
        tHitToShow[2] = "wallbang"
    end

    if tDeadInfo["headshot"] then
        iBoxSizeX = iBoxSizeX + x * .0155
        tHitToShow[3] = "headshot"
    end

    local iBoxStart = x * .99 - iBoxSizeX

    draw.RoundedBox(2, iBoxStart, posy, iBoxSizeX, iBoxSizeY, Color(0,0,0,150))
    draw.SimpleText(tDeadInfo["victim_name"], rajdhani20, x * .988 - iVTextSizeX, GetCenterInY(posy, iBoxSizeY, iVTextSizeY), tDeadInfo["victim_color"])
    draw.SimpleText(tDeadInfo["killer_name"], rajdhani20, x * .992 - iBoxSizeX, GetCenterInY(posy, iBoxSizeY, iVTextSizeY), tDeadInfo["killer_color"])

    surface.SetDrawColor(color_white)

    local iPosX = iBoxStart + iKTextSizeX + x * .005
    for i = 1, 3 do
        local name = tHitToShow[i]
        if not name then
            continue
        end

        surface.SetMaterial(tHitImage[name])
        surface.DrawTexturedRect(iPosX, posy + y * .004, name == "weapon" and x * .037 or x * .014, iVTextSizeY)

        if name == "weapon" then
            iPosX = iPosX + x * .038
        else
            iPosX = iPosX + x * .0155
        end
    end
end

local iImageSizeX, iImageSizeY = 1920 * .4875, 1080 * .028

local function DrawCSGOInterface()
    --[[
        Header Hud: Start
    ]]
    draw.RoundedBox(0, x * .4745, y * .03, x * .025, y * .025, Color(0,0,0,150))
    draw.RoundedBox(0, x * .501, y * .03, x * .025, y * .025, Color(0,0,0,150))
    draw.RoundedBox(0, x * .4749, y * .003, x * .0515, y * .025, Color(0,0,0,150))

    draw.SimpleText(interfaceManager.WinATRound, rajdhani30, x * .4875, y * .028, interfaceManager.ColorTeamAT, TEXT_ALIGN_CENTER)
    draw.SimpleText(interfaceManager.WinTRound, rajdhani30, x * .5125, y * .028, interfaceManager.ColorTeamT, TEXT_ALIGN_CENTER)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(tHitImage["c-terrorist"])
    surface.DrawTexturedRect(x * .4425, y * .003, x * .03, y * .0525)

    surface.SetMaterial(tHitImage["terrorist"])
    surface.DrawTexturedRect(x * .528, y * .003, x * .03, y * .0525)

    draw.SimpleTextOutlined(iPlayerAliveAT, rajdhani40, x * .457, y * .0075, color_white, TEXT_ALIGN_CENTER, _, 2, color_black)
    draw.SimpleTextOutlined(iPlayerAliveT, rajdhani40, x * .542, y * .0075, color_white, TEXT_ALIGN_CENTER, _, 2, color_black)
    draw.SimpleTextOutlined("Alive", rajdhani20, x * .457, y * .0375, color_white, TEXT_ALIGN_CENTER, _, 1, color_black)
    draw.SimpleTextOutlined("Alive", rajdhani20, x * .542, y * .0375, color_white, TEXT_ALIGN_CENTER, _, 1, color_black)

    local iRoundTimer = interfaceManager.RoundTimer2 - CurTime() + interfaceManager.RoundTimer

    if interfaceManager.RoundTimer > 0 and interfaceManager.RoundTimer2 > 0 then
        draw.SimpleText(math.FormatTimer(iRoundTimer), rajdhani30, x / 2, y * .0025, color_white, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText("00:00", rajdhani30, x / 2, y * .001, color_red, TEXT_ALIGN_CENTER)
    end


    if interfaceManager.LaunchingGameText then
        draw.SimpleText(interfaceManager.LaunchingGameText, rajdhani30, x / 2, y * .4, color_white, TEXT_ALIGN_CENTER)
    end

    if iDeadListCount <= 0 then
        return
    end

    if iDeadListCount == 1 then
        local iDeadPos = #interfaceManager.DeadList
        local tDeadInfo = interfaceManager.DeadList[iDeadPos]

        if not tDeadInfo then
            iDeadListCount = 0
            return
        end

        DrawKillFeed(tDeadInfo)

        if CurTime() - tDeadInfo["timer"] >= 5 then
            interfaceManager.DeadList[iDeadPos] = nil
            iDeadListCount = 0
        end
    else
        local iBoxPosY = y * .01
        for i = 1, #interfaceManager.DeadList do
            local tDeadInfo = interfaceManager.DeadList[i]

            if not tDeadInfo then
                continue
            end

            DrawKillFeed(tDeadInfo, iBoxPosY)
            iBoxPosY = iBoxPosY + y * .035

            if CurTime() - tDeadInfo["timer"] >= 5 then
                interfaceManager.DeadList[i] = nil
                iDeadListCount = iDeadListCount - 1
            end
        end
    end
end
CSGOGamemode:HookRegister("HUDPaint", "DrawInterface::InterfaceManager", DrawCSGOInterface)

--[[
    Interface Manager: Bomb UI
]]

function CSGOGamemode.Interface:DiffuseMenu()
	local diffuse_menu = vgui.Create("DFrame")
	diffuse_menu:SetSize(x * .125, y * .03)
	diffuse_menu:Center()
	diffuse_menu:SetTitle("")
	diffuse_menu:ShowCloseButton(false)
	diffuse_menu:SetDraggable(false)
	timer.Create("successful_defusing", 5, 1, function()
		diffuse_menu:Close()
		net.Start("VRBomb_Net")
			net.WriteBool(true)
		net.SendToServer()
	end)
	local diffuse_time = CurTime()
	function diffuse_menu:Paint(w, h)
		local diffuse_length = diffuse_time - CurTime() + 5
	
		if diffuse_length > 0 then
			draw.RoundedBox(4, 0, 0, w, h, Color(45,45,45,240))
			draw.RoundedBox(2, w * .01, h * .7, diffuse_length * 47, h * .1, color_white)
			draw.SimpleText("Diffuse Time : "..math.FormatTimer(diffuse_length), "DermaDefault", w * .01, h * .1, color_white, TEXT_ALIGN_LEFT)
		end
	
		if LocalPlayer():KeyReleased(IN_USE) then
			net.Start("VRBomb_Net")
				net.WriteBool(false)
			net.SendToServer()
			timer.Destroy("successful_defusing")
			self:Close()
		end
	end
end

--[[
    Interface Manager: Utils
]]

function CSGOGamemode.Interface:AddKill(eKiller, eVictim, tHitList)
    if not eKiller or not eVictim then
        return
    end

    if not eKiller:IsPlayer() then
        return
    end

    local iTablePos = #interfaceManager.DeadList + 1
    interfaceManager.DeadList[iTablePos] = tHitList
    interfaceManager.DeadList[iTablePos]["killer_name"] = eKiller:Nick()
    interfaceManager.DeadList[iTablePos]["victim_name"] = eVictim:Nick()
    interfaceManager.DeadList[iTablePos]["killer_color"] = eKiller:GetColorTeam()
    interfaceManager.DeadList[iTablePos]["victim_color"] = eVictim:GetColorTeam()
    interfaceManager.DeadList[iTablePos]["timer"] = CurTime()

    if interfaceManager.GameStatement == "wait_player" then
        return
    end

    if eVictim:IsAT() then
        iPlayerAliveAT = iPlayerAliveAT - 1
    else
        iPlayerAliveT = iPlayerAliveT - 1
    end

    iDeadListCount = iDeadListCount + 1
end

--[[
    Interface Manager: player metatable
]]

local pPlayer = FindMetaTable("Player")

function pPlayer:GetColorTeam()
    if self == LocalPlayer() then
        return interfaceManager.PlayersTeamColor["local"]
    end

    if not interfaceManager.PlayersTeamColor[self:Nick()] then
        interfaceManager.PlayersTeamColor[self:Nick()] = string.ToColor(self:GetNWString("CSGO_GM_TeamColor"))
    end

    return interfaceManager.PlayersTeamColor[self:Nick()]
end

function pPlayer:IsAT()
    return self:GetColorTeam() == interfaceManager.ColorTeamAT
end

--[[
    Interface Manager: Hook for interface
]]

local function ResetAlivePlayer()
    timer.Simple(0, function()
        iPlayerAliveAT = 0
        iPlayerAliveT = 0

        local tAllPlayer = player.GetAll()
        for i = 1, #tAllPlayer do
            if tAllPlayer[i]:IsAT() then
                iPlayerAliveAT = iPlayerAliveAT + 1
            else
                iPlayerAliveT = iPlayerAliveT + 1
            end
        end
    end)
end
CSGOGamemode:HookRegister("OnRoundStart", "ResetAlivePlayer::InterfaceManager", ResetAlivePlayer)

local function SelectWeapon()
    if input.WasKeyPressed(KEY_1) then
        local sRifleClass = LocalPlayer():GetNWString("CSGO_GM_Rifle")
        if sRifleClass == "" then
            return
        end

        input.SelectWeapon(LocalPlayer():GetWeapon(sRifleClass))
        return
    elseif input.WasKeyPressed(KEY_2) then
        local sPistolClass = LocalPlayer():GetNWString("CSGO_GM_Pistol")
        if sPistolClass == "" then
            return
        end

        input.SelectWeapon(LocalPlayer():GetWeapon(sPistolClass))
        return
    elseif input.WasKeyPressed(KEY_3) then
        local sKnifeClass = LocalPlayer():GetNWString("CSGO_GM_Knife")
        if sKnifeClass == "" then
            return
        end

        input.SelectWeapon(LocalPlayer():GetWeapon(sKnifeClass))
        return
    elseif input.WasKeyPressed(KEY_5) then
        if not LocalPlayer():HasWeapon("vr_bomb") then
            return
        end

        input.SelectWeapon(LocalPlayer():GetWeapon("vr_bomb"))
        return
    end
end
CSGOGamemode:HookRegister("PlayerBindPress", "SelectWeapon::InterfaceManager", SelectWeapon)
