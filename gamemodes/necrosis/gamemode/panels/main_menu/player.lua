--locals
local PANEL = {}

--panel function
function PANEL:Init()
	local indexing_parent = self
	
	do --avatar
		local avatar = vgui.Create("AvatarImage", self)
		self.AvatarImage = avatar
		
		avatar:Dock(LEFT)
		
		do --button
			local button = vgui.Create("DButton", avatar)
			button.Paint = nil
			
			button:Dock(FILL)
			button:SetText("")
			
			function button:DoClick() gui.OpenURL("http://steamcommunity.com/profiles/" .. indexing_parent.Player:SteamID64()) end
		end
	end
	
	do --label
		local label = vgui.Create("DLabel", self)
		self.Label = label
		
		label:Dock(FILL)
		label:SetContentAlignment(4)
		label:SetNecrosisFont("Regular")
	end
end

function PANEL:PerformLayout(width, height)
	self.AvatarImage:SetWide(height)
	self.Label:DockMargin(width * 0.04, 0, 0, 0)
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	
	self.AvatarImage:SetPlayer(ply, 184)
	self.Label:SetText(ply:Nick())
end

--post
derma.DefineControl("NecrosisMainMenuPlayer", "Panel used by NecrosisMainMenuPlayerList.", PANEL, "EditablePanel")