--locals
local color_gray = Color(180, 180, 180)
local PANEL = {}

--panel functions
function PANEL:Scale()
	local text_height = select(2, self:GetTextSize())

	self:DockMargin(0, 0, 0, text_height)
	self:SetTall(text_height * 1.1)

	return text_height
end

function PANEL:Init()
	self:SetNecrosisFont("Tiny")
	self:SetTextColor(color_gray)
	self:SetContentAlignment(5)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(self:GetTextColor())
	surface.DrawLine(0, height - 1, width, height - 1)
end

--post
derma.DefineControl("NecrosisRuledHeader", "A label with a line under it.", PANEL, "DLabel")