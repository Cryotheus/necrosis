--locals
--local large_margin = 16
local PANEL = {}
local sky_distance = 200
local sky_quadrant_angles = {180, 180, 180, 180, 0, 0}
local necrosis_music_volume = CreateConVar("necrosis_music_volume", "1.2", FCVAR_ARCHIVE, "Music volume", 0, 5)

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
	local main_menu = self
	self.CameraAngle = Angle(0, 0, 0)
	
	do --emergency button for debug
		local button = vgui.Create("DButton", self)
		self.CloseButton = button
		
		button:SetFont("DermaLarge")
		button:SetPos(0, 0)
		button:SetSize(400, 120)
		button:SetText("EMERGENCY EXIT")
		button:SetZPos(1000)
		
		function button:DoClick() main_menu:Remove() end
		
		function button:Paint(width, height)
			if self.Hovered then
				surface.SetDrawColor(255, 0, 0)
				surface.DrawRect(0, 0, width, height)
				
				self:SetTextColor(color_white)
			else self:SetTextColor(color_transparent) end
		end
	end
	
	do --model
		local model = vgui.Create("NecrosisMainMenuModel", self)
		self.Model = model
		
		model:SetZPos(-1)
	end
	
	do --header
		local panel = vgui.Create("DPanel", self)
		self.HeaderPanel = panel
		
		panel:Dock(TOP)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end
		
		do --label
			local label = vgui.Create("DLabel", panel)
			panel.TitleLabel = label
			
			label:SetContentAlignment(5)
			label:SetFont("DermaLarge")
			label:SetText(game.SinglePlayer() and "SINGLEPLAYER" or game.IsDedicated() and "MULTIPLAYER" or "PEER TO PEER")
		end
	end
	
	do --footer
		local panel = vgui.Create("DPanel", self)
		self.FooterPanel = panel
		
		panel:Dock(BOTTOM)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end
		
		do --label
			local label = vgui.Create("DLabel", panel)
			panel.VersionLabel = label
			
			label:SetContentAlignment(5)
			label:SetFont("DermaDefaultBold")
			label:SetText("Necrosis v" .. GAMEMODE.Version)
		end
	end
	
	self:FillScreen()
	self:PlayMusic("sound/necrosis/music/main_menu.mp3", "https://cdn.discordapp.com/attachments/652513124611522563/1085636070735102143/mainmenu.mp3")
	self:SetSkyBox("skybox/sky_wasteland02")
	
	cvars.AddChangeCallback("necrosis_music_volume", function() if self:IsValid() then self:MusicVolume(necrosis_music_volume:GetFloat()) end end, "NecrosisMainMenu")
	gui.HideGameUI()
	hook.Add("OnScreenSizeChanged", self, self.FillScreen)
	self:MakePopup()
	self:DoModal()
	GAMEMODE:UIMainMenuEnable(self)
end

function PANEL:MusicVolume(volume)
	local stream = self.MusicStream
	
	if IsValid(stream) then stream:SetVolume(volume) end
end

function PANEL:OnRemove()
	local stream = self.MusicStream
	
	if IsValid(stream) then stream:Stop() end
	
	GAMEMODE:UIMainMenuDisable()
end

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
	
	model:SetPos((width - model_width) * 0.5, height - model_height)
	model:SetSize(model_width, model_height)
	
	self.FooterPanel:SetTall(math.ceil(height * 0.03) * 2)
end

function PANEL:PlayMusic(sound_path, fallback_url)
	local exists = file.Exists(sound_path, "GAME")
	
	local function callback(stream, ...)
		if stream and stream:IsValid() then
			if self:IsValid() then
				self.MusicStream = stream
				
				stream:SetVolume(necrosis_music_volume:GetFloat())
				stream:EnableLooping(true)
			else steam:Stop() end
		end
	end
	
	if exists then sound.PlayFile(sound_path, "noblock", callback)
	else sound.PlayURL(fallback_url, "noblock", callback) end
end

function PANEL:PlayMusic(sound_path, fallback_url)
	local exists = file.Exists(sound_path, "GAME"); --we NEED the semicolon here
	
	(exists and sound.PlayFile or sound.PlayURL)(exists and sound_path or fallback_url, "noblock", function(stream, ...)
		if stream and stream:IsValid() then
			if self:IsValid() then
				self.MusicStream = stream
				
				stream:SetVolume(necrosis_music_volume:GetFloat())
				stream:EnableLooping(true)
			else steam:Stop() end
		end
	end)
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
derma.DefineControl("NecrosisMainMenu", "", PANEL, "EditablePanel")