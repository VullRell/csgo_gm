local pPlayer = FindMetaTable("Player")

function pPlayer:SetWalk(bWalk)
    self.is_walking = bWalk
end

function pPlayer:IsWalking()
    return self.is_walking
end

function pPlayer:Spectating()
    return self.CSGO_GM_Spectating
end

function pPlayer:SetPistol(sPistolClass)
    self.CSGO_GM_Pistol = sPistolClass
    self:SetNWString("CSGO_GM_Pistol", sPistolClass)
end

function pPlayer:SetRifle(sRifleClass)
    self.CSGO_GM_Rifle = sRifleClass
    self:SetNWString("CSGO_GM_Rifle", sRifleClass)
end

function pPlayer:SetKnife(sKnifeClass)
    self.CSGO_GM_Knife = sKnifeClass
    self:SetNWString("CSGO_GM_Knife", sKnifeClass)
end

function pPlayer:GetPistol()
    return self.CSGO_GM_Pistol
end

function pPlayer:GetRifle()
    return self.CSGO_GM_Rifle
end

function pPlayer:GetKnife()
    return self.CSGO_GM_Knife
end

function pPlayer:GiveBasicWeapon()
    local sSelfTeam = self:GetTeam()

    if table.IsEmpty(sSelfTeam) then
        return
    end

    if sSelfTeam:IsDiffuser() then
        self:Give("weapon_csgo_knife")
        self:Give("weapon_csgo_usp_silencer")
    else
        self:Give("weapon_csgo_knife_t")
        self:Give("weapon_csgo_glock")
    end

    if self.CSGO_GM_Spectating then
        self.CSGO_GM_Spectating = false
    end
end

function pPlayer:SpectateCSGO(eEntity)
    self:Spectate(4)
    self:SpectateEntity(eEntity)
    self:StripWeapons()
    self.CSGO_GM_Spectating = true
end
