--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	self:Resize()
	self:SetDraggable(true)
	self:SetTitle("Settings")
	
	hook.Add("OnScreenSizeChanged", self, self.Resize)
	self:Center()
	self.btnMaxim:SetVisible(false)
	self.btnMinim:SetVisible(false)
	
	do
		local sheet = vgui.Create("NecrosisSettingsMenuSheet", self)
		self.Sheet = sheet
		
		sheet:Dock(FILL)
	end
end

function PANEL:Resize()
	local width = ScrW()
	
	self:SetPos(0, 0)
	self:SetSize(width * 0.6, math.min(ScrH(), width * 0.35))
end

--post
derma.DefineControl("NecrosisSettingsMenu", "", PANEL, "DFrame")