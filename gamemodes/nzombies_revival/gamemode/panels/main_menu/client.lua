--locals
local PANEL = {}

--panel functions
function PANEL:Close()
	--something fancy
	self:Remove()
end

function PANEL:FillScreen()
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
end

function PANEL:Init()
	do
		local button = vgui.Create("DButton", self)
		local indexing_parent = self
		self.CloseButton = button
		
		button:SetPos(0, 0)
		button:SetSize(400, 120)
		button:SetText("Emergency Exit")
		
		function button:DoClick() indexing_parent:Close() end
		function button:Paint() end
	end
	
	do
		local model = vgui.Create("ZombinoMainMenuModel", self)
		
		model:Dock(FILL)
		model:DockMargin(ScrW() * 0.3, ScrH() * 0.2, ScrW() * 0.3, 0)
	end
	
	hook.Add("OnScreenSizeChanged", self, self.FillScreen)
	self:FillScreen()
	self:MakePopup()
	self:DoModal()
	ZOMBIGM:UIMainMenuEnable(self)
	ZOMBIGM:UIMainMenuSetSkyMaterial("skybox/sky_wasteland02")
end

function PANEL:OnRemove() ZOMBIGM:UIMainMenuDisable() end

function PANEL:Paint()
	local width = ScrW()
	local width_half = width * 0.5
	local x = gui.MouseX()
	local y = gui.MouseY()
	local x_fraction = (width_half - x) / width_half
	local y_fraction = (y - ScrH() * 0.5) / width_half
	
	ZOMBIGM:UIMainMenuLook(x_fraction, y_fraction)
end

--post
derma.DefineControl("ZombinoMainMenu", "", PANEL, "EditablePanel")