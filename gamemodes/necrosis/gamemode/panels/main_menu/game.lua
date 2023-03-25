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

	do --difficulty panel
		local difficulty = vgui.Create("NecrosisMainMenuGameDifficulty", self)
		self.DifficultyPanel = difficulty

		difficulty:Dock(TOP)
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