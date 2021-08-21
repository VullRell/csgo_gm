AddCSLuaFile()

--[[
    Don't touch the code which is below !
]]

if not SERVER then
    return
end

util.AddNetworkString("VRBomb_Net")

timer.Simple(1, function()
    util.PrecacheModel(server:GetBombModel())
end)

local eEntity = FindMetaTable("Entity")

function eEntity:doExplosion(radius)
    local entTerrorist
    if self:IsWeapon() then
        entTerrorist = self:GetOwner()
    else
        entTerrorist = self
    end

    local data = EffectData()
    data:SetOrigin(self:GetPos())

    util.Effect("Explosion", data, true, true)
    util.BlastDamage(self, entTerrorist, self:GetPos(), radius, 1000)

    hook.Call("OnBombExploded")
end

local pPlayer = FindMetaTable("Player")

function pPlayer:setDiffusingEntity(entBomb)
    self.diffusingBomb = entBomb
end

function pPlayer:getDiffusingEntity()
    return self.diffusingBomb
end

local function DiffuseEntity(_, ply)
    local succesfulDiffuse = net.ReadBool()
    local entBomb = ply:getDiffusingEntity()

    if not IsValid(entBomb) or entBomb:GetClass() != "vr_bomb" or not entBomb:IsDiffusing() then
        return
    end

    if not succesfulDiffuse then
        entBomb.isDiffusing = false
    end

    if succesfulDiffuse and CurTime() - entBomb.diffusingTime >= 5 then
        entBomb:Remove()
        hook.Call("OnBombIsDiffused")
    end
end
net.Receive("VRBomb_Net", DiffuseEntity)
