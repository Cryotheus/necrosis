--locals
local old_functions = {}

--local tables
local detoured_hooks = {
	"PreDrawHUD",
	"PreDrawOpaqueRenderables",
	"PreDrawSkyBox",
	"PreDrawTranslucentRenderables",
	"PreDrawViewModel",
}

--local functions
local function always_true() return true end

--gamemode
function GM:NecrosisUIMainMenuDisable()
	self.UIMainMenuPanel = false

	--undo detours
	for index, hook_name in ipairs(detoured_hooks) do self[hook_name], old_functions[hook_name] = old_functions[hook_name] end

	self.PreDrawEffects = nil
end

function GM:NecrosisUIMainMenuEnable(panel)
	--make detours for the hooks
	--did it like this because I wanted to see how high I could get the main menu frame rate :p
	for index, hook_name in ipairs(detoured_hooks) do old_functions[hook_name], self[hook_name] = self[hook_name], always_true end

	--self.PreDrawEffects = pre_draw_effects_override
	self.UIMainMenuPanel = panel
end

function GM:NecrosisUIMainMenuOpen()
	if self.UIMainMenuPanel then return end

	vgui.Create("NecrosisMainMenu")
end

function GM:NecrosisUIMainMenuSetSkyMaterial(path)
	sky_materials = {
		Material(path .. "ft"),
		Material(path .. "bk"),
		Material(path .. "lf"),
		Material(path .. "rt"),
		Material(path .. "up"),
		Material(path .. "dn"), nil --the nil is here to overwrite the second return of Material
	}
end

--hooks
hook.Add("Tick", "NecrosisUIMainMenu", function()
	if not LocalPlayer():IsValid() then GAMEMODE:UIMainMenuOpen() end

	hook.Remove("Tick", "NecrosisUIMainMenu")
end)