--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	local indexing_parent = self

	do --the actual ready button panel
		local button = vgui.Create("DButton", self)
		self.ReadyButton = button

		button:Dock(TOP)
		button:SetNecrosisFont("Big")

		function button:DoClickGameActive() RunConsoleCommand("necrosis_dropin") end

		function button:DoClickGameInactive()
			self:Toggle()

			if self:GetToggle() then RunConsoleCommand("necrosis_dropin")
			else RunConsoleCommand("necrosis_dropout") end
		end

		function button:DoClickPlaying() RunConsoleCommand("necrosis_dropout") end
	end

	do --spectate button
		local button = vgui.Create("DButton", self)
		self.SpectateButton = button

		button:Dock(TOP)
		button:SetNecrosisFont("Big")
		button:SetText("Spectate")

		function button:DoClick()
			indexing_parent.ReadyButton:SetToggle(false)
			RunConsoleCommand("necrosis_spectate")
		end
	end

	hook.Add("NecrosisGameFinish", self, self.Update)
	hook.Add("NecrosisGameStart", self, self.Update)
	self:SetIsToggle(true)
	self:Update(NECROSIS.Difficulty)
end

function PANEL:OnRemove()
	hook.Remove("NecrosisGameFinish", self)
	hook.Remove("NecrosisGameStart", self)
end

function PANEL:PerformLayout(width)
	local button_height = math.max(width * 0.25, ScrH() * 0.08, 64)

	self.ReadyButton:SetHeight(button_height)
	self.SpectateButton:DockMargin(0, math.max(ScrH() * 0.002, 2))
	self.SpectateButton:SetHeight(button_height * 0.75)
	self:SizeToChildren(false, true)
end

function PANEL:Update(difficulty_index)
	local active = difficulty_index and true or false
	local local_player = LocalPlayer()
	local ready_button = self.ReadyButton
	local spectate_button = self.SpectateButton
	ready_button.DoClick = difficulty_index and ready_button.DoClickGameActive or ready_button.DoClickGameInactive

	ready_button:SetIsToggle(active)
	spectate_button:SetVisible(active)

	if local_player:IsValid() then
		if local_player:NecrosisPlaying() then
			ready_button.DoClick = ready_button.DoClickPlaying
			
			ready_button:SetText("#necrosis.panels.main_menu_game_ready_button.dropout")
		elseif local_player:NecrosisDroppingIn() then ready_button:SetToggle(true)
		else ready_button:SetToggle(false) end
	else ready_button:SetText(active and "#necrosis.panels.main_menu_game_ready_button.dropin" or "#necrosis.panels.main_menu_game_ready_button") end

	self:InvalidateLayout(true)
end

--post
derma.DefineControl("NecrosisMainMenuGameReadyButton", "Button that readies or drops in the player.", PANEL, "DSizeToContents")