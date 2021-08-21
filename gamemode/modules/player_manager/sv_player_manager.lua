local function InitPlayerInfo(pPlayer)
    pPlayer.CSGO_GM_AntiSpam = CurTime()
    pPlayer.CSGO_GM_ActualTeam = {}
    pPlayer.CSGO_GM_Spectating = false
    pPlayer.CSGO_GM_FirstSpawn = true
    pPlayer.CSGO_GM_Pistol = ""
    pPlayer.CSGO_GM_Rifle = ""
    pPlayer.CSGO_GM_Knife = ""

    pPlayer:SetNWInt("CSGO_GM_Money", 0)

    CSGOGamemode.TeamManager:SearchTeam(pPlayer)

    if timer.Exists("CSGO_GM_LaunchingTimerSV") then
        pPlayer:SetNWInt("CSGO_GM_LaunchingTimer", timer.TimeLeft("CSGO_GM_LaunchingTimerSV") + 1)
        timer.Simple(1, function()
            CSGOGamemode.NetManager:SendNet(2, function()
                net.WriteUInt(5, 3)
            end)
        end)
    end
end
CSGOGamemode:HookRegister("PlayerInitialSpawn", "InitParam::PlayerManager", InitPlayerInfo)

local function SetMovement(pPlayer)
    pPlayer:SetSlowWalkSpeed(80)
    pPlayer:SetWalkSpeed(240)
    pPlayer:SetJumpPower(180)
    pPlayer:SetRunSpeed(240)
    pPlayer:GiveBasicWeapon()
end
CSGOGamemode:HookRegister("PlayerSpawn", "SetMovement::PlayerManager", SetMovement)

local function DropWeapons(pPlayer, iKey)
    if iKey != IN_ZOOM then
        return
    end

    local eWeapon = pPlayer:GetActiveWeapon()
    if not IsValid(eWeapon) then
        return
    end

    local sWeaponCSGOClass = eWeapon:GetCSGOClass()
    if sWeaponCSGOClass == "Knife" then
        return
    elseif sWeaponCSGOClass == "Rifle" then
        pPlayer:SetRifle("")
    elseif sWeaponCSGOClass == "Pistol" then
        pPlayer:SetPistol("")
    end

    local vVector, tAngle = pPlayer:GetBonePosition(pPlayer:LookupBone("ValveBiped.Bip01_R_Hand"))

    pPlayer:DropWeapon(eWeapon, vVector)
    pPlayer:SelectWeapon(pPlayer:GetKnife())
end
CSGOGamemode:HookRegister("KeyPress", "DropWeapons::PlayerManager", DropWeapons)

local function InitSpectateMode(pSelf)
    if not CSGOGamemode.GameManager:GameStarted() then
        return 
    end

    local sPlyTeam = pSelf:GetTeam()
    local tAllPlayer = player.GetAll()
    local bFindPlayerToSpec = false

    for i = 1, #player.GetAll() do
        local pPlayer = tAllPlayer[i]
        
        if pPlayer:GetTeam() != sPlyTeam or not pPlayer:Alive() then
            continue
        end

        pSelf:SpectateCSGO(pPlayer)
        bFindPlayerToSpec = true

        print(pSelf:SteamID64().." are on spectate mode !")
        break
    end

    if not sPlyTeam:IsDiffuser() and CSGOGamemode.GameManager:GetBombPlanted() or bFindPlayerToSpec then
        return
    end

    CSGOGamemode.GameManager:GetActualRound():ChangeRound(not sPlyTeam:IsDiffuser(), "team_dead")
end
CSGOGamemode:HookRegister("PlayerDeath", "SetToSpectate::PlayerManager", InitSpectateMode)

local function BulletTrace(pPlayer, killer, bullet)
    local tAllHit = {}
    local vVictimPos = bullet:GetDamagePosition()
    local vKillerPos = killer:GetPos()

    local tBulletTrace = util.TraceLine({
        start = vKillerPos,
        endpos = vVictimPos,
        filter = function(ent)
            return ent:GetClass() == "prop_physics"
        end
    })
    if tBulletTrace.HitWorld or tBulletTrace.HitTexture != "**empty**" then
        tAllHit["wallbang"] = true
        print(pPlayer:SteamID64().." was killed troughout a wall !")
    end
    if pPlayer:LastHitGroup() == 1 then
        tAllHit["headshot"] = true
        print(pPlayer:SteamID64().." was dead with headshot !")
    end

    local iTableCount = table.Count(tAllHit)
    CSGOGamemode.NetManager:SendNet(3, function()
        net.WriteUInt(iTableCount, 3)
        for hit in pairs(tAllHit) do
            net.WriteString(hit)
        end
        net.WriteEntity(killer)
        net.WriteEntity(pPlayer)
    end)
end
CSGOGamemode:HookRegister("DoPlayerDeath", "BulletInfo::PlayerManager", BulletTrace)

local function RespawnBlock(pPlayer)
    return CSGOGamemode.GameManager:GameStarted() and pPlayer:Spectating()
end
CSGOGamemode:HookRegister("PlayerDeathThink", "EnableRespawn::PlayerManager", RespawnBlock)

local function CanHear(players, self)
	return players:GetPos():DistToSqr( self:GetPos() ) > 25000
end
CSGOGamemode:HookRegister("PlayerCanHearPlayersVoice", "PeopleCanHear::PlayerManager", CanHear)

local function FallDamage(pPlayer, speed)
    local health = pPlayer:Health()
    local new_speed = speed / 17 - 10
    pPlayer:SetHealth(pPlayer:Health() - new_speed)
end
CSGOGamemode:HookRegister("GetFallDamage", "SetFallDamage::PlayerManager", FallDamage)

local function LeaveGame(pPlayer)
    pPlayer:LeaveTeam()
end
CSGOGamemode:HookRegister("PlayerDisconnected", "LeaveGame", LeaveGame)
