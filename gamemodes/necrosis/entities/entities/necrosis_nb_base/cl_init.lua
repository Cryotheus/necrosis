include("shared.lua")

--entit functions
function ENT:Draw() end
function ENT:DrawTranslucent() end
function ENT:FireAnimationEvent(_position, _angles, _event, _options) end

function ENT:Initialize()
	self:SetInternalFunctions()
	self:SharedInitialize()
end

function ENT:OnReloaded() self:SetInternalFunctions() end

function ENT:SetInternalFunctions()
	self.Draw = self.DrawModel
	self.DrawTranslucent = self.DrawModel
	self.Think = nil
end