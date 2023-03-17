--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	self:DockPadding(16, 16, 16, 16)
	
	do --music slider
		local label = vgui.Create("DLabel", self)
		
		label:Dock(TOP)
		label:SetNecrosisFont("Small")
		label:SetText("Music Volume")
		
		local slider = vgui.Create("NecrosisSlider", self)
		
		slider:Dock(TOP)
		slider:SetConVar("necrosis_music_volume")
	end
end

--post
derma.DefineControl("NecrosisSettingsMenuGeneral", "", PANEL, "EditablePanel")