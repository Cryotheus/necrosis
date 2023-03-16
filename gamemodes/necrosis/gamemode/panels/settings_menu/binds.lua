--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	local left_panel
	local right_panel
	
	do
		left_panel = vgui.Create("EditablePanel", self)
		self.LeftPanel = left_panel
		
		left_panel:Dock(FILL)
	end
	
	do
		right_panel = vgui.Create("EditablePanel", self)
		self.RightPanel = right_panel
		
		right_panel:Dock(RIGHT)
	end
	
	do --kick binder
		local binder = vgui.Create("NecrosisBinderLabeled", left_panel)
		self.KickBinderPanel = binder
		
		binder:Dock(TOP)
		binder:SetCommand("necrosis_kick")
		binder:SetHeight(120)
		binder:SetNecrosisFont("SettingsHeader")
		binder:SetText("Melee Kick")
	end
	
	do --melee binder
		local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
		self.MeleeBinderPanel = binder
		
		binder:Dock(TOP)
		binder:SetCommand("+necrosis_melee")
		binder:SetHeight(120)
		binder:SetNecrosisFont("SettingsHeader")
		binder:SetText("Melee Attack")
	end
	
	do --grenade binder
		local binder = vgui.Create("NecrosisBinderLabeled", left_panel)
		self.GrenadeBinderPanel = binder
		
		binder:Dock(TOP)
		binder:SetCommand("+necrosis_grenade")
		binder:SetHeight(120)
		binder:SetNecrosisFont("SettingsHeader")
		binder:SetText("Throw Grenade")
	end
	
	do --special grenade binder
		local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
		self.SpecialGrenadeBinderPanel = binder
		
		binder:Dock(TOP)
		binder:SetCommand("+necrosis_special_grenade")
		binder:SetHeight(120)
		binder:SetNecrosisFont("SettingsHeader")
		binder:SetText("Throw Special Grenade")
	end
end

function PANEL:PerformLayout(width)
	local divide = math.ceil(ScrH() * 0.02)
	local margin = math.ceil(ScrH() * 0.005)
	
	self.LeftPanel:DockMargin(0, 0, divide, 0)
	self.RightPanel:SetWide(math.ceil(width * 0.5) - divide)
	
	self.KickBinderPanel:DockMargin(0, 0, 0, margin)
	self.MeleeBinderPanel:DockMargin(0, 0, 0, margin)
	self.GrenadeBinderPanel:DockMargin(0, 0, 0, margin)
	self.SpecialGrenadeBinderPanel:DockMargin(0, 0, 0, margin)
end

--post
derma.DefineControl("NecrosisSettingsMenuBinds", "", PANEL, "EditablePanel")