--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	local swapper

	do --swapper
		swapper = vgui.Create("NecrosisSwapPanel", self)
		self.SwapPanel = swapper

		swapper:Dock(FILL)

		function swapper:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end

		do --general
			local general_panel = vgui.Create("NecrosisSettingsMenuGeneral", swapper)
			swapper.GeneralPanel = general_panel

			swapper:Add("General", general_panel)
		end

		do --controls
			local binds_panel = vgui.Create("NecrosisSettingsMenuBinds", swapper)
			swapper.BindsPanel = binds_panel

			swapper:Add("Controls", binds_panel)
		end

		do --credits
			local credits_panel = vgui.Create("NecrosisSettingsMenuCredits", swapper)
			swapper.CreditsPanel = credits_panel

			swapper:Add("Credits", credits_panel)
		end
	end

	do --tabs
		local tabs = vgui.Create("NecrosisTabs", self)
		self.TabsPanel = tabs

		tabs:Add("General")
		tabs:Add("Controls")
		tabs:Add("Graphics")
		tabs:Add("Credits")
		tabs:Dock(TOP)

		function tabs:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end

		function tabs:OnSelect(key) swapper:Swap(key) end

		tabs:Choose(1)
	end
end

function PANEL:PerformLayout()
	local padding = math.ceil(ScrH() * 0.02)
	local tabs = self.TabsPanel
	local tabs_height = ScrH() * 0.048

	self.SwapPanel:DockPadding(padding, padding, padding, padding)
	tabs:DockMargin(0, 0, 0, tabs_height * 0.2)
	tabs:SetTall(tabs_height)
end

--post
derma.DefineControl("NecrosisSettingsMenu", "", PANEL, "Panel")