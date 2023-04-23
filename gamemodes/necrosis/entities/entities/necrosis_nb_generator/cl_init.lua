include("shared.lua")

--entit functions
function ENT:Draw()
	cam.IgnoreZ(true)
		render.SuppressEngineLighting(true)
			self:DrawModel()
		render.SuppressEngineLighting(false)
	cam.IgnoreZ(false)
end

function ENT:DrawTranslucent() end
function ENT:FireAnimationEvent(_position, _angles, _event, _options) end
function ENT:ImpactTrace() return true end
function ENT:Initialize() self:SetInternalFunctions() end
function ENT:OnReloaded() self:SetInternalFunctions() end

function ENT:SetInternalFunctions()
	self.DrawTranslucent = self.DrawModel
	self.Think = nil
end