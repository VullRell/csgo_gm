AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")  
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel(server:GetBombModel())
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:SetUseType(SIMPLE_USE) 
    self:DropToFloor()

    timer.Create("vr_bomb_Entity:"..self:EntIndex(), server:GetBombTimer(), 1, function()
        self:doExplosion(1600)
        self:Remove()
    end)
end

function ENT:OnRemove()
    timer.Destroy("vr_bomb_Entity:"..self:EntIndex())
end

function ENT:Diffuse(pPlayer)
    if self:IsDiffusing() then
        return
    end

    net.Start("VRBomb_Net")
    net.Send(pPlayer)

    pPlayer:setDiffusingEntity(self)
    self.isDiffusing = true
    self.diffusingTime = CurTime()

    timer.Simple(6, function()
        self.isDiffusing = false
    end)
end

function ENT:IsDiffusing()
    return self.isDiffusing
end

function ENT:Use(_, pPlayer)
    if pPlayer:GetTeam():IsDiffuser() then
        self:Diffuse(pPlayer)
    end
end
