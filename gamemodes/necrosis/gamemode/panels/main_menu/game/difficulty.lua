--locals
local circle = Material("pyrition/gui/circle_64.png")
local PANEL = {}

--panel function
function PANEL:Init()
	local indexing_parent = self

	do --header label
		local label = vgui.Create("NecrosisRuledHeader", self)
		self.HeaderLabel = label

		label:Dock(TOP)
		label:SetContentAlignment(6)
		label:SetText("#necrosis.panels.main_menu_game_difficulty.header")
	end

	do --difficulty options
		local chosen_difficulty = NECROSIS.DifficultyVoted
		local difficulty_buttons = {}
		local panel = vgui.Create("NecrosisColumnSizer", self)
		self.DifficultyPanel = panel

		panel:Dock(TOP)
		panel:SetColumns(4)
		panel:SetVisible(false)

		function panel:OnRemove() hook.Remove("NecrosisDifficultyVoteCountChanged", self) end

		function panel:UpdateCounts(votes)
			for class, vote_count in pairs(votes) do
				local button = difficulty_buttons[class]

				if IsValid(button) then button.VoteCount = vote_count end
			end
		end
		
		hook.Add("NecrosisDifficultyVoteCountChanged", panel, panel.UpdateCounts)

		--difficulties
		for index, difficulty_table in ipairs(GAMEMODE.DifficultyList) do
			local class = difficulty_table.Class
			local icon_button = vgui.Create("NecrosisMaterialDesignIconScalerButton", panel)
			local overlay = vgui.Create("Panel", icon_button)
			difficulty_buttons[class] = icon_button
			icon_button.NecrosisDifficultyIndex = index
			icon_button.VoteCount = NECROSIS.DifficultyVoteCount[class] or 0

			overlay:Dock(FILL)
			overlay:SetMouseInputEnabled(false)

			icon_button:SetIcon(difficulty_table.Icon)
			icon_button:SetIsToggle(true)
			icon_button:SetNecrosisFont("Tiny")
			table.insert(difficulty_buttons, icon_button)

			function icon_button:DoClick()
				local index = index

				if self:GetToggle() then
					index = nil

					self:SetToggle(false)
				else for index, button in ipairs(difficulty_buttons) do button:SetToggle(button == self) end end

				indexing_parent:SetDifficulty(index)
				GAMEMODE:DifficultyVote(index)
			end

			function overlay:Paint(width, height)
				local text_width, text_height = icon_button:GetTextSize()
				local vote_count = icon_button.VoteCount

				if vote_count ~= 0 then
					local x = width * 0.9 - math.max(text_height, text_width)
					local y = height * 0.9 - text_height

					local size_half = math.ceil((width - x) * 0.4)
					local size = size_half * 2

					surface.SetDrawColor(96, 96, 96, 224)
					surface.SetMaterial(circle)
					surface.DrawTexturedRect(x - size_half, y - size_half, size, size)
					
					draw.SimpleText(tostring(vote_count), icon_button:GetFont(), x - text_height * 0.1, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			if chosen_difficulty == difficulty_table.Class then
				self.DifficultyIndex = index

				icon_button:SetToggle(true)
			end
		end
	end

	do --difficulty description
		local label = vgui.Create("DLabel", self)
		self.DifficultyLabel = label

		label:Dock(TOP)
		label:SetAutoStretchVertical(true)
		label:SetContentAlignment(5)
		label:SetNecrosisFont("Medium")
		label:SetText("")
		label:SetVisible(false)
	end

	do --difficulty description
		local label = vgui.Create("DLabel", self)
		self.DifficultyDescriptionLabel = label

		label:Dock(TOP)
		label:SetAutoStretchVertical(true)
		label:SetContentAlignment(5)
		label:SetNecrosisFont("Regular")
		label:SetText("")
		label:SetVisible(false)
		label:SetWrap(true)
	end

	self:UpdateVisibility()
end

function PANEL:OnRemove() hook.Remove("NecrosisDifficultyVoteCountChanged", self) end

function PANEL:PerformLayout()
	self.HeaderLabel:Scale()
	self:SizeToChildren(false, true)
end

function PANEL:SetDifficulty(index)
	self.DifficultyIndex = index

	self:Think()
end

function PANEL:SetVisibleDifficulty(index)
	if index then
		local class = GAMEMODE:DifficultyGet(index).Class
		local description_label = self.DifficultyDescriptionLabel
		local difficulty_label = self.DifficultyLabel
		self.VisibleDifficultyIndex = index

		description_label:SetText("#necrosis.difficulties." .. class .. ".description")
		description_label:SetVisible(true)
		difficulty_label:SetText("#necrosis.difficulties." .. class)
		difficulty_label:SetVisible(true)
	else
		self.VisibleDifficultyIndex = nil

		self.DifficultyDescriptionLabel:SetVisible(false)
		self.DifficultyLabel:SetVisible(false)
	end
end

function PANEL:ThinkHover()
	local index
	local panel = vgui.GetHoveredPanel()
	local world = vgui.GetWorldPanel()

	while IsValid(panel) and panel ~= world do
		if panel.NecrosisDifficultyIndex then
			index = panel.NecrosisDifficultyIndex

			break
		end

		panel = panel:GetParent()
	end

	if index == nil then index = self.DifficultyIndex end
	if index ~= self.VisibleDifficultyIndex then self:SetVisibleDifficulty(index) end
end

function PANEL:UpdateVisibility()
	local difficulty_options = self.DifficultyPanel

	if NECROSIS.GameActive then
		local difficulty_index = NECROSIS.Difficulty
		self.Think = nil

		difficulty_options:SetVisible(false)
		self:SetVisibleDifficulty(difficulty_index ~= 0 and difficulty_index)
	else
		self.Think = self.ThinkHover

		difficulty_options:SetVisible(true)
	end
end

--post
derma.DefineControl("NecrosisMainMenuGameDifficulty", "Panel with details about the current game's difficulty.", PANEL, "DSizeToContents")