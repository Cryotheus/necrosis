--locals
local PANEL = {}

--panel functions
function PANEL:Add(steam_id_64, name, title, description)
	local panel = vgui.Create("DSizeToContents", self)

	panel:Dock(TOP)

	function panel:PerformLayout(width, height)
		local avatar_size = math.max(math.ceil(width * 0.05), 96)
		local description_label = self.DescriptionLabel
		local label_margin = avatar_size * 1.1
		local label_spacing = math.ceil(height * 0.02)

		self.AvatarImage:SetSize(avatar_size, avatar_size)
		self.NameLabel:DockMargin(label_margin, label_spacing, 0, 0)
		self.TitleLabel:DockMargin(label_margin, label_spacing, 0, 0)

		if description_label then
			description_label:SetPos(0, math.max(avatar_size, self.TitleLabel:GetX()) + label_spacing)
			description_label:SetWide(width)
		end

		self:SizeToChildren(false, true)
	end

	do --avatar
		local avatar = vgui.Create("AvatarImage", panel)
		panel.AvatarImage = avatar

		avatar:SetSteamID(steam_id_64, 184)
	end

	do --name label
		local label = vgui.Create("DLabel", panel)
		local found_player
		panel.NameLabel = label

		label:Dock(TOP)
		label:SetAutoStretchVertical(true)
		label:SetContentAlignment(4)
		label:SetNecrosisFont("Regular")

		--find the player if they are on the server
		for index, ply in ipairs(player.GetAll()) do
			if ply:SteamID64() == steam_id_64 then
				found_player = ply

				break
			end
		end

		label:SetText(found_player and found_player:Nick() or name)
	end

	do --title label
		local label = vgui.Create("DLabel", panel)
		panel.TitleLabel = label

		label:Dock(TOP)
		label:SetAutoStretchVertical(true)
		label:SetContentAlignment(4)
		label:SetNecrosisFont("Regular")
		label:SetText(title)
	end

	if description then
		local label = vgui.Create("DLabel", panel)
		panel.DescriptionLabel = label

		label:SetAutoStretchVertical(true)
		label:SetContentAlignment(5)
		label:SetNecrosisFont("Small")
		label:SetText(description)
		label:SetWrap(true)
	end
end

function PANEL:Init()
	self:Add("76561197962184163", "BlacK", "Programmer")
	self:Add("76561198106179251", "Cryotheum", "Pog Rammer", "Made the beautiful menu.")
end

function PANEL:PerformLayout(_width, height)
	local margin = math.ceil(height * 0.02)

	for index, panel in ipairs(self:GetChildren()) do panel:DockMargin(0, 0, 0, margin) end
end

--post
derma.DefineControl("NecrosisSettingsMenuCredits", "Menu with credation of the gamemode developers.", PANEL, "Panel")