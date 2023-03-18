--locals
local PANEL = {}
local panel_meta = FindMetaTable("Panel")

--panel functions
function PANEL:GetFont() return self.Label:GetFont() end
function PANEL:GetText() return self.Label:GetText() end
function PANEL:GetTextSize() return self.Label:GetTextSize() end

function PANEL:Init()
	panel_meta.SetText(self, "") --clear the text on this panel
	self:SetMouseInputEnabled(true)

	do --label
		local label = vgui.Create("DLabel", self)
		self.Label = label

		label:Dock(FILL)
		label:SetMouseInputEnabled(false)
	end

	do --binder
		local binder = vgui.Create("NecrosisBinder", self)
		self.Binder = binder

		binder:Dock(RIGHT)
	end
end

function PANEL:PerformLayout(width)
	local margin = math.ceil(ScrH() * 0.005)

	self.Binder:SetWide(math.ceil(width * 0.5) - margin)
	self.Label:DockMargin(0, 0, margin, 0)
end

function PANEL:SetCommand(command) self.Binder:SetCommand(command) end

function PANEL:SetNecrosisFont(name)
	self.Binder:SetNecrosisFont(name)
	self.Label:SetNecrosisFont(name)
end

function PANEL:SetText(text) self.Label:SetText(text) end
function PANEL:SetTextColor(color) self.Label:SetTextColor(color) end
function PANEL:SetTextStyleColor(color) self.Label:SetTextStyleColor(color) end

--post
derma.DefineControl("NecrosisBinderLabeled", "", PANEL, "DLabel")