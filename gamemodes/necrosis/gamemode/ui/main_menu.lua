--gamemode
function GM:HUDPaint()
	if NECROSIS.UIMainMenuPanel then return end

	hook.Call("HUDDrawTargetID", self)
	hook.Call("HUDDrawPickupHistory", self)
	hook.Call("DrawDeathNotice", self, 0.85, 0.04)
end

function GM:HUDShouldDraw(_name)
	if NECROSIS.UIMainMenuPanel then return false end

	return true
end

function GM:NecrosisUIMainMenuDisable() NECROSIS.UIMainMenuPanel = false end
function GM:NecrosisUIMainMenuEnable(panel) NECROSIS.UIMainMenuPanel = panel end

function GM:NecrosisUIMainMenuOpen()
	if NECROSIS.UIMainMenuPanel then return end

	vgui.Create("NecrosisMainMenu")
end

function GM:PreDrawEffects()
	if not NECROSIS.GameActive then
		if gui.IsGameUIVisible() then render.Clear(0, 0, 0, 255, true, true)
		else self:UIMainMenuOpen() end
	end
end

function GM:UIMainMenuClose() if NECROSIS.UIMainMenuPanel then NECROSIS.UIMainMenuPanel:Close() end end

--hooks
hook.Add("Tick", "NecrosisUIMainMenu", function()
	if not LocalPlayer():IsValid() then GAMEMODE:UIMainMenuOpen() end

	hook.Remove("Tick", "NecrosisUIMainMenu")
end)