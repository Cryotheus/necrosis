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
function GM:ZombiGMUIMainMenuDisable()
	self.UIMainMenuRender = false
	
	--undo detours
	for index, hook_name in ipairs(detoured_hooks) do self[hook_name], old_functions[hook_name] = old_functions[hook_name] end
	
	self.PreDrawEffects = nil
end

function GM:ZombiGMUIMainMenuEnable(panel)
	--make detours for the hooks
	--did it like this because I wanted to see how high I could get the main menu frame rate :p
	for index, hook_name in ipairs(detoured_hooks) do old_functions[hook_name], self[hook_name] = self[hook_name], always_true end
	
	--self.PreDrawEffects = pre_draw_effects_override
	self.UIMainMenuRender = panel
end

function GM:ZombiGMUIMainMenuOpen()
	if self.UIMainMenuRender then return end
	
	vgui.Create("ZombinoMainMenu")
end

function GM:ZombiGMUIMainMenuSetSkyMaterial(path)
	sky_materials = {
		Material(path .. "ft"),
		Material(path .. "bk"),
		Material(path .. "lf"),
		Material(path .. "rt"),
		Material(path .. "up"),
		Material(path .. "dn"), nil --the nil is here to overwrite the second return of Material
	}
end

--commands
concommand.Add("zb_debug", function() ZOMBIGM:UIMainMenuOpen() end) --TODO: remove debug

--hooks
hook.Add("Tick", "ZombiGMUIMainMenu", function()
	if not LocalPlayer():IsValid() then ZOMBIGM:UIMainMenuOpen() end
	
	hook.Remove("Tick", "ZombiGMUIMainMenu")
end)