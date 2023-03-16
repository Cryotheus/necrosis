--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	do --kick binder
		local label = vgui.Create("DLabel", self)
		
		label:Dock(TOP)
		label:SetNecrosisFont("SettingsHeader")
		label:SetText("Melee Kick")
		
		local binder = vgui.Create("NecrosisBinder", self)
		
		binder:Dock(TOP)
		binder:SetHeight(120)
		binder:SetCommand("necrosis_kick")
		binder:SetNecrosisFont("SettingsHeader")
	end
	
	do --melee binder
		local label = vgui.Create("DLabel", self)
		
		label:Dock(TOP)
		label:SetNecrosisFont("SettingsHeader")
		label:SetText("Melee Attack")
		
		local binder = vgui.Create("NecrosisBinder", self)
		
		binder:Dock(TOP)
		binder:SetHeight(120)
		binder:SetCommand("+necrosis_melee")
		binder:SetNecrosisFont("SettingsHeader")
	end
	
	do --grenade binder
		local label = vgui.Create("DLabel", self)
		
		label:Dock(TOP)
		label:SetNecrosisFont("SettingsHeader")
		label:SetText("Throw Grenade")
		
		local binder = vgui.Create("NecrosisBinder", self)
		
		binder:Dock(TOP)
		binder:SetHeight(120)
		binder:SetCommand("+necrosis_grenade")
		binder:SetNecrosisFont("SettingsHeader")
	end
	
	do --grenade binder
		local label = vgui.Create("DLabel", self)
		
		label:Dock(TOP)
		label:SetNecrosisFont("SettingsHeader")
		label:SetText("Throw Special Grenade")
		
		local binder = vgui.Create("NecrosisBinder", self)
		
		binder:Dock(TOP)
		binder:SetHeight(120)
		binder:SetCommand("+necrosis_special_grenade")
		binder:SetNecrosisFont("SettingsHeader")
	end
end

--post
derma.DefineControl("NecrosisSettingsMenuBinds", "", PANEL, "EditablePanel")