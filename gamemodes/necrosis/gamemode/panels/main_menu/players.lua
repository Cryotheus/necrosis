--locals
local color_gray = Color(180, 180, 180)
local PANEL = {Paint = false}

--panel function
function PANEL:Init()
	do --header label
		local label = vgui.Create("DLabel", self)
		self.HeaderLabel = label
		
		label:Dock(TOP)
		label:SetContentAlignment(4)
		label:SetNecrosisFont("MainMenuInfo")
		label:SetTextColor(color_gray)
		
		function label:Paint(width, height)
			surface.SetDrawColor(color_gray)
			surface.DrawLine(0, height - 1, width, height - 1)
		end
	end
	
	do --player list
		local player_list = vgui.Create("NecrosisMainMenuPlayerList", self)
		self.PlayerList = player_list
		
		player_list:Dock(FILL)
	end
end

function PANEL:PerformLayout()
	local header_label = self.HeaderLabel
	local text_height = select(2, header_label:GetTextSize())
	
	header_label:DockMargin(0, 0, 0, text_height * 0.5)
	header_label:SetTall(text_height * 1.1)
end

function PANEL:Think()
	local header_label = self.HeaderLabel
	local text = " Players " .. player.GetCount() .. " /" .. game.MaxPlayers() .. " Max"
	
	if header_label:GetText() ~= text then header_label:SetText(text) end
end

--post
derma.DefineControl("NecrosisMainMenuPlayers", "Panel with a NecrosisMainMenuPlayerList embeded.", PANEL, "Panel")