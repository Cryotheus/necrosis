--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	do --binds
		local page = vgui.Create("NecrosisSettingsMenuBinds", self)
		
		page:Dock(FILL)
		self:AddSheet("Bindings", page, "icon16/keyboard.png")
	end
	
	do --audio
		local page = vgui.Create("NecrosisSettingsMenuAudio", self)
		
		page:Dock(FILL)
		self:AddSheet("Audio", page, "icon16/sound.png")
	end
	
	do --graphics
		local page = vgui.Create("EditablePanel", self)
		
		page:Dock(FILL)
		self:AddSheet("Graphics", page, "icon16/monitor.png")
	end
	
	do --credits
		local page = vgui.Create("EditablePanel", self)
		
		page:Dock(FILL)
		self:AddSheet("Credits", page, "icon16/star.png")
	end
end

--post
derma.DefineControl("NecrosisSettingsMenuSheet", "", PANEL, "DPropertySheet")