--locals
local PANEL = {}

--local tables
local colors = {
	Color(96, 96, 96),
	Color(188, 188, 188),
	Color(224, 224, 224),
	Color(255, 255, 255)
}

--panel functions
function PANEL:Init()
	local indexing_parent = self

	do --the resume button
		local button = vgui.Create("DButton", self)
		button.Paint = self.PaintButton
		self.ResumeButton = button

		button:Dock(TOP)
		button:SetNecrosisFont("Big")
		button:SetText("#necrosis.panels.main_menu_game_ready_button.resume")
		button:SetVisible(false)

		function button:DoClick() GAMEMODE:UIMainMenuClose() end
	end

	do --the drop in/ready button
		local button = vgui.Create("DButton", self)
		button.Paint = self.PaintButton
		self.ReadyButton = button

		button:Dock(TOP)
		button:SetNecrosisFont("Big")

		function button:DoClickGameActive()
			GAMEMODE:UIMainMenuClose()
			RunConsoleCommand("necrosis_dropin")
		end

		function button:DoClickGameInactive()
			self:Toggle()

			if self:GetToggle() then RunConsoleCommand("necrosis_dropin")
			else RunConsoleCommand("necrosis_dropout") end
		end

		function button:DoClickPlaying() RunConsoleCommand("necrosis_dropout") end
	end

	do --spectate button
		local button = vgui.Create("DButton", self)
		button.Paint = self.PaintButton
		self.SpectateButton = button

		button:Dock(TOP)
		button:SetNecrosisFont("Big")
		button:SetText("#necrosis.panels.main_menu_game_ready_button.spectate")

		function button:DoClick()
			GAMEMODE:UIMainMenuClose()
			indexing_parent.ReadyButton:SetToggle(false)
			RunConsoleCommand("necrosis_spectate")
		end
	end

	hook.Add("NecrosisGameFinish", self, self.Update)
	hook.Add("NecrosisGameStart", self, self.Update)
	hook.Add("NecrosisPlayerTeamUpdated", self, self.TeamChanged)
	self:Update(NECROSIS.Difficulty)
end

function PANEL:OnRemove()
	hook.Remove("NecrosisGameFinish", self)
	hook.Remove("NecrosisGameStart", self)
	hook.Remove("NecrosisPlayerTeamUpdated", self)
end

function PANEL:PaintButton(width, height)
	local color_index = 2

	if self.Depressed or self:IsSelected() or self:GetToggle() then color_index = 4
	elseif self:GetDisabled() then color_index = 1
	elseif self.Hovered then color_index = 3 end

	self:SetTextColor(colors[color_index])

	surface.SetDrawColor(0, 0, 0, 160)
	surface.DrawRect(0, 0, width, height)
end

function PANEL:PerformLayout(width)
	local button_height = math.max(width * 0.25, ScrH() * 0.08, 64)
	local spacing = math.max(ScrH() * 0.01, 4)

	self.ReadyButton:DockMargin(0, spacing, 0, 0)
	self.ReadyButton:SetHeight(button_height)
	self.ResumeButton:SetHeight(button_height)
	self.SpectateButton:DockMargin(0, spacing, 0, 0)
	self.SpectateButton:SetHeight(button_height * 0.75)

	--must be done last
	self:SizeToChildren(false, true)
end

function PANEL:TeamChanged(ply, _new_team, _old_team)
	---The NecrosisPlayerTeamUpdated hook.
	if ply == LocalPlayer() then self:Update(NECROSIS.Difficulty) end
end

function PANEL:Update(difficulty_index)
	local active = difficulty_index and true or false
	local local_player = LocalPlayer()
	local ready_button = self.ReadyButton
	local spectate_button = self.SpectateButton
	ready_button.DoClick = difficulty_index and ready_button.DoClickGameActive or ready_button.DoClickGameInactive

	spectate_button:SetVisible(active)

	if local_player:IsValid() then
		self.ResumeButton:SetVisible(local_player:NecrosisPlaying() or active and local_player:NecrosisDroppingIn() or local_player:NecrosisIsSpectator())

		if local_player:NecrosisPlaying() then
			ready_button.DoClick = ready_button.DoClickPlaying

			ready_button:SetIsToggle(false)
			ready_button:SetText("#necrosis.panels.main_menu_game_ready_button.dropout")
			ready_button:SetToggle(false)
			self:InvalidateLayout(true)

			return
		elseif local_player:NecrosisDroppingIn() then
			ready_button:SetIsToggle(true)
			ready_button:SetText("#necrosis.panels.main_menu_game_ready_button.dropout")
			ready_button:SetToggle(true)
			self:InvalidateLayout(true)

			return
		end
	end

	ready_button:SetIsToggle(true)
	ready_button:SetText(active and "#necrosis.panels.main_menu_game_ready_button.dropin" or "#necrosis.panels.main_menu_game_ready_button")
	ready_button:SetToggle(false)
	self:InvalidateLayout(true)
end

--post
derma.DefineControl("NecrosisMainMenuGameReadyButton", "Buttons that players use to ready up, drop in, or spectate.", PANEL, "DSizeToContents")