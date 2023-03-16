--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	self:DockPadding(16, 16, 16, 16)
	
	do --music slider
		local slider = vgui.Create("DNumSlider", self)
		local necrosis_music_volume = GetConVar("necrosis_music_volume")
		
		slider:Dock(TOP)
		slider:SetConVar("necrosis_music_volume")
		slider:SetMinMax(necrosis_music_volume:GetMin(), necrosis_music_volume:GetMax())
		slider:SetText("Music Volume")
	end
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(0, 0, width, height)
end

--post
derma.DefineControl("NecrosisSettingsMenuAudio", "", PANEL, "EditablePanel")