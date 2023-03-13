--locals
local look_angles = Angle()
local old_functions = {}
local sky_distance = 200
local sky_materials

--local tables
local detoured_hooks = {
	"PreDrawHUD",
	"PreDrawOpaqueRenderables",
	"PreDrawSkyBox",
	"PreDrawTranslucentRenderables",
	"PreDrawViewModel",
}

local sky_quadrant_angles = {180, 180, 180, 180, 0, 0}

local sky_quadrant_normals = {
	Vector(0, 1, 0),
	Vector(0, -1, 0),
	Vector(1, 0, 0),
	Vector(-1, 0, 0),
	Vector(0, 0, -1),
	Vector(0, 0, 1)
}

local sky_quadrant_positions = {
	Vector(0, -sky_distance, 0),
	Vector(0, sky_distance, 0),
	Vector(-sky_distance, 0, 0),
	Vector(sky_distance, 0, 0),
	Vector(0, 0, sky_distance),
	Vector(0, 0, -sky_distance)
}

--local functions
local function always_true() return true end

local function pre_draw_effects_override()
	local angles = look_angles
	
	cam.Start3D(vector_origin, angles, 90)
	cam.IgnoreZ(true)
	--render.Clear(0, 0, 0, 255, true, true)
	render.OverrideDepthEnable(true, false)
	render.SuppressEngineLighting(true)
	
	for index, material in ipairs(sky_materials) do
		render.SetMaterial(material)
		
		render.DrawQuadEasy(
			sky_quadrant_positions[index],
			sky_quadrant_normals[index],
			sky_distance * 2.01, sky_distance * 2.01, --TODO: cache? maybe make width and height fields?
			color_white, --don't use colors here
			sky_quadrant_angles[index]
		)
	end
	
	render.OverrideDepthEnable(false)
	render.SuppressEngineLighting(false)
	cam.IgnoreZ(false)
	cam.End3D()
end

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
	
	look_angles.pitch = 0
	look_angles.yaw = 0
	self.PreDrawEffects = pre_draw_effects_override
	self.UIMainMenuRender = panel
end

function GM:ZombiGMUIMainMenuLook(x_fraction, y_fraction)
	local target_angles = Angle(y_fraction * 30, x_fraction * 30, 0)
	look_angles = LerpAngle(RealFrameTime(), look_angles, target_angles)
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

--GM:ZombiGMUIMainMenuSetSkyMaterial("skybox/sky_wasteland02")
--GM.PreDrawEffects = pre_draw_effects_override

--commands
concommand.Add("zb_debug", function() ZOMBIGM:UIMainMenuOpen() end) --TODO: remove debug