--locals
local color_gray = Color(180, 180, 180)
local PANEL = {Paint = false}

--panel function
function PANEL:Init()
	do --header label
		local label = vgui.Create("DLabel", self)
		self.HeaderLabel = label

		label:Dock(TOP)
		label:SetContentAlignment(6)
		label:SetNecrosisFont("Tiny")
		label:SetText("Game")
		label:SetTextColor(color_gray)

		function label:Paint(width, height)
			surface.SetDrawColor(color_gray)
			surface.DrawLine(0, height - 1, width, height - 1)
		end
	end

	do --difficulty section
		local description_label
		local difficulty_label
		local sizer = vgui.Create("DSizeToContents", self)
		self.DifficultySizer = sizer

		sizer:Dock(TOP)

		function sizer:PerformLayout() self:SizeToChildren(false, true) end

		do
			local label = vgui.Create("DLabel", sizer)
			sizer.DifficultyLabel = label

			label:Dock(TOP)
			label:SetAutoStretchVertical(true)
			label:SetContentAlignment(5)
			label:SetNecrosisFont("Medium")
			label:SetText("DIFFICULTY")
		end

		do --difficulty options
			local panel = vgui.Create("NecrosisColumnSizer", sizer)
			sizer.DifficultyPanel = panel

			panel:Dock(TOP)
			panel:SetColumns(4)

			do --diffculties
				local difficulty_buttons = {}

				for index, difficulty_info in ipairs{
					{"Easy", "emoticon-happy-outline", "Much easier than normal."},
					{"Normal", "emoticon-neutral-outline", "The intended difficulty; play this for your first time!"},
					{"Hard", "emoticon-angry-outline", "Zombies are much tougher, and hit much harder."},
					{"Nightmare", "skull-outline", "Zombies are much tougher, and hit much harder. If anyone goes down, everyone goes down. Only for the most skilled of squads."},
				} do
					local name, icon, description = unpack(difficulty_info)
					local icon_button = vgui.Create("NecrosisMaterialDesignIconScalerButton", panel)

					icon_button:SetIcon(icon)
					icon_button:SetIsToggle(true)
					table.insert(difficulty_buttons, icon_button)

					function icon_button:DoClick()
						for index, button in ipairs(difficulty_buttons) do button:SetToggle(button == self) end

						description_label:SetText(description)
						difficulty_label:SetText(string.upper(name))
						sizer:InvalidateLayout(true)
					end
				end
			end
		end

		do --difficulty description
			difficulty_label = vgui.Create("DLabel", sizer)

			difficulty_label:Dock(TOP)
			difficulty_label:SetAutoStretchVertical(true)
			difficulty_label:SetContentAlignment(5)
			difficulty_label:SetNecrosisFont("Medium")
			difficulty_label:SetText("")
		end

		do --difficulty description
			description_label = vgui.Create("DLabel", sizer)

			description_label:Dock(TOP)
			description_label:SetAutoStretchVertical(true)
			description_label:SetContentAlignment(5)
			description_label:SetNecrosisFont("Regular")
			description_label:SetText("")
			description_label:SetWrap(true)
		end
	end
end

function PANEL:PerformLayout()
	local header_label = self.HeaderLabel
	local text_height = select(2, header_label:GetTextSize())

	header_label:DockMargin(0, 0, 0, text_height)
	header_label:SetTall(text_height * 1.1)
end

--post
derma.DefineControl("NecrosisMainMenuGame", "Panel with details about the current game.", PANEL, "Panel")