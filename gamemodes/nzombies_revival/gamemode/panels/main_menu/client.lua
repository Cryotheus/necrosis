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
	
	do --emergency button for debug
		local button = vgui.Create("DButton", self)
		local indexing_parent = self
		self.CloseButton = button
		
		button:SetFont("DermaLarge")
		button:SetPos(0, 0)
		button:SetSize(400, 120)
		button:SetText("EMERGENCY EXIT")
		button:SetZPos(1000)
		
		function button:DoClick() indexing_parent:Remove() end
		
		function button:Paint(width, height)
			if self.Hovered then
				surface.SetDrawColor(255, 0, 0)
				surface.DrawRect(0, 0, width, height)
				
				self:SetTextColor(color_white)
			else self:SetTextColor(color_transparent) end
		end
	end
	
	do --model
		local model = vgui.Create("ZombinoMainMenuModel", self)
		self.Model = model
	end
	
	do --info footer
		local panel = vgui.Create("DSizeToContents", self)
		
		panel:Dock(BOTTOM)
		--panel:SetHeight(math.max(ScrW() * 32 / 2560, 16))
		
		function panel:PerformLayout() self:SizeToChildren(false, true) end
		
		do --label
			local label = vgui.Create("DLabel", panel)
			
			label:SetAutoStretchVertical(true)
			label:SetText("Zombino v" .. GAMEMODE.Version)
		end
	end
	
	do --top left buttons
		
	end
	
	self:FillScreen()
	self:SetSkyBox("skybox/sky_wasteland02")
	
	gui.HideGameUI()
	hook.Add("OnScreenSizeChanged", self, self.FillScreen)
	self:MakePopup()
	self:DoModal()
	ZOMBIGM:UIMainMenuEnable(self)
end

function PANEL:OnRemove() ZOMBIGM:UIMainMenuDisable() end

function PANEL:Paint()
	if gui.IsGameUIVisible() then
		self.Paint = nil
		
		self:Close()
		
		return
	end
	
	local width_half = ScrW() * 0.5
	local x_fraction = (width_half - gui.MouseX()) / width_half
	local y_fraction = (gui.MouseY() - ScrH() * 0.5) / width_half
	
	local aim = system.HasFocus() and Angle(y_fraction * 30, x_fraction * 30, 0) or angle_zero
	local angles = LerpAngle(RealFrameTime(), self.CameraAngle, aim)
	
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

function PANEL:PerformLayout(width, height)
	local model = self.Model
	local model_width, model_height = width * 0.4, height * 0.8
	--ScrW() * 0.3, ScrH() * 0.2, ScrW() * 0.3, 0
	
	model:SetPos((width - model_width) * 0.5, height - model_height)
	model:SetSize(model_width, model_height)
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