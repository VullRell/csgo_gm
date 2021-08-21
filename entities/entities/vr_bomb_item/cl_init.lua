include("shared.lua")

math.Round = math.Round

ENT.timerBeforeExplode = 0

function ENT:Draw()
    self:DrawModel()

	if self.timerBeforeExplode == 0 then
		self.timerBeforeExplode = CurTime()
	end

	local iLeftTime = self.timerBeforeExplode - CurTime() + 35
end
