--locals
local PANEL = {Paint = false}

--panel function
function PANEL:Init()
	do --header label
		local label = vgui.Create("NecrosisRuledHeader", self)
		self.HeaderLabel = label

		label:Dock(TOP)
		label:SetContentAlignment(4)
		label:SetText("#necrosis.panels.main_menu_game.header")
	end

	do --player list
		local player_list = vgui.Create("NecrosisMainMenuPlayerList", self)
		self.PlayerList = player_list

		player_list:Dock(FILL)
	end
end

function PANEL:PerformLayout() self.HeaderLabel:Scale() end

function PANEL:Think()
	local header_label = self.HeaderLabel
	local text = " Players " .. player.GetCount() .. " /" .. game.MaxPlayers() .. " Max"

	if header_label:GetText() ~= text then header_label:SetText(text) end
end

--post
derma.DefineControl("NecrosisMainMenuPlayers", "Panel with a NecrosisMainMenuPlayerList embeded.", PANEL, "Panel")