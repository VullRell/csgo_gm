--[[
    Weapon Manager: Metatable
]]

local tKnifeTable =
{
    ["weapon_csgo_knife"] = true,
    ["weapon_csgo_knife_t"] = true
}
local tPistolTable =
{
    ["weapon_csgo_usp_silencer"] = true,
    ["weapon_csgo_glock"] = true
}
local tRifleTable = {}

local function GetWeaponClass(eWeapon)
    if tRifleTable[eWeapon:GetClass()] then
        return "Rifle"
    elseif tPistolTable[eWeapon:GetClass()] then
        return "Pistol"
    elseif tKnifeTable[eWeapon:GetClass()] then
        return "Knife"
    end
end

local eEntity = FindMetaTable("Entity")

function eEntity:GetCSGOClass()
    if not self:IsWeapon() then
        return false
    end

    if not self.CSGO_GM_Class then
        self.CSGO_GM_Class = GetWeaponClass(self)
    end

    return self.CSGO_GM_Class
end

--[[
    Weapon Manager: Hook
]]

local function GiveWeapon(pPlayer, eWeapon)
    local sWeaponClass = eWeapon:GetClass()
    local sWeaponCSGOClass = eWeapon:GetCSGOClass()

    if sWeaponCSGOClass == "Rifle" and pPlayer:GetRifle() == "" then
        pPlayer:SetRifle(sWeaponClass)
        return true
    elseif sWeaponCSGOClass == "Pistol" and pPlayer:GetPistol() == "" then 
        pPlayer:SetPistol(sWeaponClass)
        return true    
    elseif sWeaponCSGOClass == "Knife" and pPlayer:GetKnife() == "" then
        pPlayer:SetKnife(sWeaponClass)
        return true
    elseif sWeaponClass == "vr_bomb" then
        return true
    end

    return false
end
CSGOGamemode:HookRegister("PlayerCanPickupWeapon", "GiveWeapon::WeaponManager", GiveWeapon)

local function RemoveWeapon(pPlayer)
    pPlayer:SetRifle("")
    pPlayer:SetPistol("")
    pPlayer:SetKnife("")
end
CSGOGamemode:HookRegister("PlayerDeath", "RemoveWeapon::PlayerManager", RemoveWeapon)
