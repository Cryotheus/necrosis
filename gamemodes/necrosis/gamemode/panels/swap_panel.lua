--locals
local PANEL = {}

--panel functions
function PANEL:Add(key, panel)
	local existing = self.Panels[key]
	
	if existing then
		if panel == existing then return end
		
		existing:Remove()
	end
	
	self.Panels[key] = panel
	
	panel:Dock(FILL)
	panel:SetParent(self)
	panel:SetVisible(false)
end

function PANEL:Init() self.Panels = {} end

function PANEL:Swap(key)
	local current = self.ActivePanel
	
	if IsValid(current) then current:SetVisible(false) end
	
	local panel = self.Panels[key]
	
	if IsValid(panel) then
		self.ActivePanel = panel
		
		panel:SetVisible(true)
	else self.ActivePanel = nil end
end

--post
derma.DefineControl("NecrosisSwapPanel", "A panel that swaps its content panels.", PANEL, "EditablePanel")