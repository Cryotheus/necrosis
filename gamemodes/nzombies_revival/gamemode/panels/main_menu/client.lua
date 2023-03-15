--locals
local PANEL = {}
local sky_distance = 200
local sky_quadrant_angles = {180, 180, 180, 180, 0, 0}

--local tables
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

--panel functions
function PANEL:Close()
	--something fancy
	self:Remove()
end

function PANEL:FillScreen()
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
end

function PANEL:Init()
	self.CameraAngle = Angle(0, 0, 0)
	
	do
		local button = vgui.Create("DButton", self)
		local indexing_parent = self
		self.CloseButton = button
		
		button:SetPos(0, 0)
		button:SetSize(400, 120)
		button:SetText("Emergency Exit")
		
		function button:DoClick() indexing_parent:Close() end
		function button:Paint() end
	end
	
	do
		local model = vgui.Create("ZombinoMainMenuModel", self)
		
		model:Dock(FILL)
		model:DockMargin(ScrW() * 0.3, ScrH() * 0.2, ScrW() * 0.3, 0)
	end
	
	self:FillScreen()
	self:SetSkyBox("skybox/sky_wasteland02")
	
	hook.Add("OnScreenSizeChanged", self, self.FillScreen)
	self:MakePopup()
	self:DoModal()
	ZOMBIGM:UIMainMenuEnable(self)
end

function PANEL:OnRemove() ZOMBIGM:UIMainMenuDisable() end

function PANEL:Paint()
	local width_half = ScrW() * 0.5
	local x_fraction = (width_half - gui.MouseX()) / width_half
	local y_fraction = (gui.MouseY() - ScrH() * 0.5) / width_half
	
	local angles = LerpAngle(RealFrameTime(), self.CameraAngle, Angle(y_fraction * 30, x_fraction * 30, 0))
	
	self.CameraAngle:Set(angles)
	
	cam.Start3D(vector_origin, angles, 90)
	cam.IgnoreZ(true)
	render.OverrideDepthEnable(true, false)
	render.SuppressEngineLighting(true)
	
	for index, material in ipairs(self.SkyBoxMaterials) do
		render.SetMaterial(material)
		
		render.DrawQuadEasy(
			sky_quadrant_positions[index],
			sky_quadrant_normals[index],
			sky_distance * 2.01, sky_distance * 2.01, --TODO: cache? maybe make width and height fields?
			color_white, --must be white, if you want to modify the color use the color mod shader
			sky_quadrant_angles[index]
		)
	end
	
	render.OverrideDepthEnable(false)
	render.SuppressEngineLighting(false)
	cam.IgnoreZ(false)
	cam.End3D()
end

function PANEL:SetSkyBox(path)
	self.SkyBoxMaterials = {
		Material(path .. "ft"),
		Material(path .. "bk"),
		Material(path .. "lf"),
		Material(path .. "rt"),
		Material(path .. "up"),
		Material(path .. "dn"), nil --the nil is here to overwrite the second return of Material
	}
end

--post
derma.DefineControl("ZombinoMainMenu", "", PANEL, "EditablePanel")