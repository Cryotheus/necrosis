--locals
local PANEL = {Paint = false}

--globals

--panel function
function PANEL:Init()
	local indexing_parent = self

	do --header label
		local label = vgui.Create("DLabel", self)
		self.DifficultyLabel = label

		label:Dock(TOP)
		label:SetAutoStretchVertical(true)
		label:SetContentAlignment(5)
		label:SetNecrosisFont("Medium")
		label:SetText("#necrosis.panels.main_menu_game_difficulty.header")
	end

	do --difficulty options
		local chosen_difficulty = GAMEMODE.DifficultyVoted
		local panel = vgui.Create("NecrosisColumnSizer", self)
		self.DifficultyPanel = panel

		panel:Dock(TOP)
		panel:SetColumns(4)

		do --diffculties
			local difficulty_buttons = {}

			for index, difficulty_table in ipairs(GAMEMODE.DifficultyList) do
				local icon_button = vgui.Create("NecrosisMaterialDesignIconScalerButton", panel)
				icon_button.NecrosisDifficultyIndex = index

				icon_button:SetIcon(difficulty_table.Icon)
				icon_button:SetIsToggle(true)
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

				if chosen_difficulty == difficulty_table.Class then
					self.DifficultyIndex = index

					icon_button:SetToggle(true)
				end
			end
		end
	end

	do --difficulty description
		local difficulty_label = vgui.Create("DLabel", self)
		self.DifficultyLabel = difficulty_label

		difficulty_label:Dock(TOP)
		difficulty_label:SetAutoStretchVertical(true)
		difficulty_label:SetContentAlignment(5)
		difficulty_label:SetNecrosisFont("Medium")
		difficulty_label:SetText("")
		difficulty_label:SetVisible(false)
	end

	do --difficulty description
		local description_label = vgui.Create("DLabel", self)
		self.DifficultyDescriptionLabel = description_label

		description_label:Dock(TOP)
		description_label:SetAutoStretchVertical(true)
		description_label:SetContentAlignment(5)
		description_label:SetNecrosisFont("Regular")
		description_label:SetText("")
		description_label:SetVisible(false)
		description_label:SetWrap(true)
	end

	hook.Add("NecrosisDifficultyVoteCountChanged", self)
end

function PANEL:OnRemove() hook.Remove("NecrosisDifficultyVoteCountChanged", self) end

function PANEL:PerformLayout()
	--more?
	self:SizeToChildren(false, true)
end

function PANEL:SetDifficulty(index)
	self.DifficultyIndex = index

	self:Think()
end

function PANEL:SetVisibleDifficulty(index)
	self.VisibleDifficultyIndex = index

	if index then
		local class = GAMEMODE:DifficultyGet(index).Class
		local description_label = self.DifficultyDescriptionLabel
		local difficulty_label = self.DifficultyLabel

		description_label:SetText("#necrosis.difficulties." .. class .. ".description")
		description_label:SetVisible(true)
		difficulty_label:SetText("#necrosis.difficulties." .. class)
		difficulty_label:SetVisible(true)
	else
		self.DifficultyDescriptionLabel:SetVisible(false)
		self.DifficultyLabel:SetVisible(false)
	end
end

function PANEL:Think()
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

--post
derma.DefineControl("NecrosisMainMenuGameDifficulty", "Panel with details about the current game's difficulty.", PANEL, "DSizeToContents")