--locals
local PANEL = {}

--panel function
function PANEL:AddPlayer(ply)
	local panel = vgui.Create("NecrosisMainMenuPlayer", self)
	self.Players[ply] = panel
	
	panel:Dock(TOP)
	panel:SetPlayer(ply)
	panel:SetZPos(ply:UserID() % 32768) --really hope you don't let your server run for that long
	self.ScrollPanel:AddItem(panel)
end

function PANEL:Init()
	self.Players = {}
	
	do --scroller
		local scroller = vgui.Create("DScrollPanel", self)
		self.ScrollPanel = scroller
		
		scroller:Dock(FILL)
	end
	
	hook.Add("OnEntityCreated", self, function(self, entity) if entity:IsPlayer() then self:AddPlayer(entity) end end)
	hook.Add("EntityRemoved", self, function(self, entity) if entity:IsPlayer() then self:RemovePlayer(entity) end end)
	
	for index, ply in ipairs(player.GetAll()) do self:AddPlayer(ply) end
end

function PANEL:PerformLayout(width)
	local panel_height = math.max(width * 0.1, 32)
	
	for ply, panel in pairs(self.Players) do
		if panel:IsVisible() then
			panel:DockMargin(0, 0, width * 0.04, 0)
			panel:SetTall(panel_height)
		end
	end
end

function PANEL:RemovePlayer(ply)
	local players = self.Players
	local panel = players[ply]
	
	if panel then
		panel.Removing = true
		self.Think = self.ThinkCleanup
		
		panel:SetVisible(false)
	end
end

function PANEL:ThinkCleanup()
	local players = self.Players
	self.Think = nil
	
	for ply, panel in pairs(players) do
		if not IsValid(ply) then
			players[ply] = nil
			
			panel:Remove()
		else panel.Removing = nil end
	end
end

--post
derma.DefineControl("NecrosisMainMenuPlayerList", "Scroll panel of NecrosisMainMenuPlayer panels.", PANEL, "EditablePanel")