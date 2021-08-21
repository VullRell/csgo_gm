AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.PrintName = "Valise explosive"
SWEP.Author = "VullRell"
SWEP.Instructions = "[VullRell's bomb] Press right click to setup bomb, Left click to drop it"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.WorldModel = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "VullRell"
SWEP.Cooldown = CurTime()

SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    if CLIENT then
        surface.PlaySound("vullrell/c4_draw.wav")
    end
    if CLIENT or not IsValid(self:GetOwner()) then return true end
    self:GetOwner():DrawWorldModel(false)
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PreDrawViewModel()
    return true
end

if not SERVER then
    return
end

local tBombSite = server:GetBombSite()

function SWEP:PrimaryAttack()
    if CurTime() - self.Cooldown < .1 then
        return
    end

    self.Cooldown = CurTime()
    
    local pPlayer = self:GetOwner()
    local bFindPlayer = false

    for _, tVectorList in pairs(tBombSite) do
        local tEntitiesInSite = ents.FindInBox(tVectorList[1], tVectorList[2])

        for k = 1, #tEntitiesInSite do
            if tEntitiesInSite[k]:IsPlayer() and tEntitiesInSite[k] == pPlayer then
                bFindPlayer = true
                break
            end
        end

        if bFindPlayer then
            break
        end
    end

    if not bFindPlayer then
        return
    end

    pPlayer:ConCommand("+duck")

    self:EmitSound("vullrell/c4_initiate.wav")

    --Drop the bomb and start the timer
    pPlayer:StripWeapon("vr_bomb")
    pPlayer:ConCommand("-duck")

    local entBomb = ents.Create("vr_bomb_item")
    entBomb:SetPos(pPlayer:GetEyeTrace().HitPos + Vector(0,0,250))
    entBomb:Spawn()

    self:EmitSound("vullrell/c4_plant.wav", 100)
end

function SWEP:Reload()
    --Explode instant the bomb !
    local pPlayer = self:GetOwner()

    pPlayer:doExplosion(1600)
    pPlayer:Kill()
end
