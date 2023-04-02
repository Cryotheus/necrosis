--locals
local PANEL = {Paint = false}

--panel function
function PANEL:Init()
	do --header label
		local label = vgui.Create("NecrosisRuledHeader", self)
		self.HeaderLabel = label

		label:Dock(TOP)
		label:SetContentAlignment(6)
		label:SetText("#necrosis.panels.main_menu_game.header")
	end

	do --ready button
		local button = vgui.Create("NecrosisMainMenuGameReadyButton", self)
		self.ReadyButton = button

		button:Dock(TOP)
	end

	do --difficulty panel
		local difficulty = vgui.Create("NecrosisMainMenuGameDifficulty", self)
		self.DifficultyPanel = difficulty

		difficulty:Dock(TOP)
	end
end

function PANEL:PerformLayout() self.ReadyButton:DockMargin(0, 0, 0, self.HeaderLabel:Scale()) end

--post
derma.DefineControl("NecrosisMainMenuGame", "Panel with details about the current game.", PANEL, "Panel")