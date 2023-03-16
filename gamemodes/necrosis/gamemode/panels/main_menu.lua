--locals
local color_gray = Color(180, 180, 180)
local color_pale_blue = Color(182, 202, 214)
--local large_margin = 16
local material_gradient_up = Material("gui/gradient_up")
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

--local function
local function get_text_size(panel)
	surface.SetFont(panel:GetFont())
	
	return surface.GetTextSize(panel:GetText())
end

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
	local local_player = LocalPlayer()
	local main_menu = self
	local swapper
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
	
	do --the stage
		swapper = vgui.Create("NecrosisSwapPanel", self)
		self.SwapperPanel = swapper
		
		swapper:Dock(FILL)
		
		do --settings
			local settings = vgui.Create("NecrosisSettingsMenu", self)
			
			swapper:Add("Settings", settings)
		end
	end
	
	do --header
		local panel = vgui.Create("DPanel", self)
		panel.Paint = nil
		self.HeaderPanel = panel
		
		panel:Dock(TOP)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end
		
		function panel:PerformLayout(_width, height) self.BottomPanel:SetTall(height * 0.4) end
		
		do --top
			local top_panel = vgui.Create("DPanel", panel)
			top_panel.Paint = nil
			panel.TopPanel = top_panel
			
			top_panel:Dock(FILL)
			
			function top_panel:PerformLayout(width, height)
				local play_label = self.PlayLabel
				local play_width, play_height = get_text_size(play_label)
				local profile_panel = self.ProfilePanel
				
				play_label:DockMargin(0, height * 0.9 - play_height, 0, 0)
				play_label:SetWide(play_width + width * 0.1)
				
				profile_panel:DockMargin(0, height * 0.4, width * 0.05, 0)
				profile_panel:SetWide(width * 0.25)
			end
			
			do --play label
				local label = vgui.Create("DLabel", top_panel)
				top_panel.PlayLabel = label
				
				label:Dock(LEFT)
				label:SetContentAlignment(6)
				label:SetNecrosisFont("MainMenuTitle")
				label:SetText(game.SinglePlayer() and "SINGLEPLAYER" or game.IsDedicated() and "MULTIPLAYER" or "HOSTED MULTIPLAYER")
				
				function label:Paint(width, height)
					local text_height = select(2, get_text_size(self))
					local text_y = (height + text_height) * 0.5
					
					surface.SetDrawColor(192, 192, 192)
					surface.DrawLine(0,  text_y, width, text_y)
				end
			end
			
			do --profile panel
				local profile_panel = vgui.Create("DPanel", top_panel)
				profile_panel.Paint = nil
				top_panel.ProfilePanel = profile_panel
				
				profile_panel:Dock(RIGHT)
				
				function profile_panel:PerformLayout(_width, height)
					self.AvatarPanel:SetWide(height)
					self.LevelLabel:SetWide(height * 1.35)
				end
				
				do --avatar
					local avatar = vgui.Create("AvatarImage", profile_panel)
					profile_panel.AvatarPanel = avatar
					
					avatar:Dock(LEFT)
					
					--wait until the player is valid to set the avatar
					if local_player:IsValid() then avatar:SetPlayer(local_player, 184)
					else hook.Add("InitPostEntity", avatar, function(self)
						hook.Remove("InitPostEntity", self)
						self:SetPlayer(LocalPlayer(), 184)
					end) end
				end
				
				do --level
					local label = vgui.Create("DLabel", profile_panel)
					profile_panel.LevelLabel = label
					
					label:Dock(LEFT)
					label:SetContentAlignment(5)
					label:SetNecrosisFont("MainMenuLevel")
					label:SetText("24")
				end
				
				do --progress bar and name
					local fill_panel = vgui.Create("DPanel", profile_panel)
					fill_panel.Paint = nil
					profile_panel.FillPanel = fill_panel
					
					fill_panel:Dock(FILL)
					
					function fill_panel:PerformLayout(_width, height) self.BarPanel:SetTall(height * 0.3) end
					
					do --name label
						local label = vgui.Create("DLabel", fill_panel)
						fill_panel.NameLabel = label
						
						label:Dock(FILL)
						label:SetNecrosisFont("MainMenuName")
						
						--set the label to their name or wait until the player is valid to do so
						if local_player:IsValid() then label:SetText(local_player:Nick())
						else hook.Add("InitPostEntity", label, function(self)
							hook.Remove("InitPostEntity", self)
							self:SetText(LocalPlayer():Nick())
						end) end
					end
					
					do --level bar
						local bar = vgui.Create("DPanel", fill_panel)
						fill_panel.BarPanel = bar
						
						bar:Dock(BOTTOM)
						
						function bar:Paint(width, height)
							surface.SetDrawColor(255, 255, 255, 64)
							surface.DrawRect(0, 0, width, height)
							
							surface.SetDrawColor(255, 255, 255)
							surface.DrawRect(0, 0, math.Remap(math.sin(CurTime()), -1, 1, 0, width), height)
						end
					end
				end
			end
		end
		
		do --bottom
			local bottom_panel = vgui.Create("DPanel", panel)
			bottom_panel.Paint = nil
			panel.BottomPanel = bottom_panel
			
			bottom_panel:Dock(BOTTOM)
			
			function bottom_panel:PerformLayout(width)
				local tabs_panel = self.TabsPanel
				
				tabs_panel:DockMargin(width * 0.05, 0, 0, 0)
				tabs_panel:SetWide(math.ceil(width * 0.4))
			end
			
			do --tabs
				local buttons = {}
				local tabs_panel = vgui.Create("DPanel", bottom_panel)
				bottom_panel.TabsPanel = tabs_panel
				tabs_panel.Buttons = buttons
				tabs_panel.Paint = nil
				
				tabs_panel:Dock(LEFT)
				
				function tabs_panel:PerformLayout(width)
					local button_count = #buttons
					local last_x = 0
					
					for index, button in ipairs(buttons) do
						local next_x = math.Round(index / button_count * width)
						
						button:SetWide(next_x - last_x)
						
						last_x = next_x
					end
				end
				
				for index, key in ipairs{"Play", "Weapons", "Operators", "Settings", "Store"} do
					local button = vgui.Create("DButton", tabs_panel)
					buttons[index] = button
					
					button:Dock(LEFT)
					button:SetContentAlignment(5)
					button:SetIsToggle(true)
					button:SetNecrosisFont("MainMenuTab")
					button:SetText(string.upper(key))
					
					function button:DoClick()
						button:Toggle()
						swapper:Swap(key)
						
						--disable all other buttons
						for index, sub_button in ipairs(buttons) do if sub_button ~= button then sub_button:SetToggle(false) end end
					end
					
					function button:Paint(width, height)
						if button:GetToggle() then
							local stripe_height = math.ceil(height * 0.1)
							
							self:SetTextColor(color_pale_blue)
							
							--gradient
							surface.SetDrawColor(color_pale_blue.r, color_pale_blue.g, color_pale_blue.b, 128)
							surface.SetMaterial(material_gradient_up)
							surface.DrawTexturedRect(0, 0, width, height)
							
							--stripe
							surface.SetDrawColor(255, 255, 255)
							surface.DrawRect(0, height - stripe_height, width, stripe_height)
						elseif self.Hovered then
							self:SetTextColor(color_white)
							
							--gradient
							surface.SetDrawColor(255, 255, 255, 64)
							surface.SetMaterial(material_gradient_up)
							surface.DrawTexturedRect(0, 0, width, height)
						else self:SetTextColor(color_gray) end
					end
				end
				
				buttons[1]:DoClick()
			end
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
		
		function panel:PerformLayout()
			local version_label = self.VersionLabel
			
			version_label:SetWide(get_text_size(version_label))
		end
		
		do --label
			local label = vgui.Create("DLabel", panel)
			panel.VersionLabel = label
			
			label:Dock(RIGHT)
			label:DockMargin(0, 0, 1, 1)
			label:SetContentAlignment(2)
			label:SetNecrosisFont("MainMenuTab")
			label:SetText("Necrosis v" .. GAMEMODE.Version)
		end
	end
	
	self:FillScreen()
	self:PlayMusic("sound/necrosis/music/main_menu.mp3", "https://cdn.discordapp.com/attachments/652513124611522563/1085636070735102143/mainmenu.mp3")
	self:SetSkyBox("skybox/sky_day03_06b") --skybox/sky_wasteland02
	swapper:Swap("Play")
	
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
	local black_bar_height = math.ceil(height * 0.03)
	local swapper_horizontal_margin = width * 0.06
	local swapper_vertical_margin = height * 0.02
	
	self.FooterPanel:SetTall(black_bar_height * 2)
	self.HeaderPanel:SetTall(black_bar_height * 4)
	self.Model:SetSize(width, height)
	self.SwapperPanel:DockMargin(swapper_horizontal_margin, swapper_vertical_margin, swapper_horizontal_margin, swapper_vertical_margin)
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