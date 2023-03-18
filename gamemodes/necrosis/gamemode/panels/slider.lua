--TODO: (Cryotheum) rewrite this. entirely.
--locals
local PANEL = {}

--panel functions
function PANEL:Init() self:SetRange(0, 1) end

function PANEL:Paint(width, height)
	local half_height = height * 0.5

	surface.SetDrawColor(180, 180, 180)
	surface.DrawLine(0, half_height, width, half_height)
end

function PANEL:SetConVar(variable)
	if isstring(variable) then variable = GetConVar(variable) end

	local minimum, maximum = variable:GetMin(), variable:GetMax()
	self.ConVar = variable
	self.ConVarName = variable:GetName()

	self:SetRange(minimum, maximum)
	self:SetSlideX(math.Remap(variable:GetFloat(), minimum, maximum, 0, 1))

	function self:OnValueChanged() self.Think = self.ThinkConVarChanged end
end

function PANEL:SetRange(minimum, maximum)
	self.Maximum = maximum
	self.Minimum = minimum
end

function PANEL:SetSlideX(value)
	self.m_fSlideX = value
	self:InvalidateLayout()

	if self.OnValueChanged then self:OnValueChanged(math.Remap(value, 0, 1, self.Minimum, self.Maximum)) end
end

function PANEL:ThinkConVarChanged()
	self.Think = nil

	RunConsoleCommand(self.ConVarName, math.Remap(self.m_fSlideX, 0, 1, self.Minimum, self.Maximum))
end

--post
derma.DefineControl("NecrosisSlider", "", PANEL, "DSlider")