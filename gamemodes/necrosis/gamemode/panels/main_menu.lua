--locals
local PANEL = {}
local sky_distance = 200
local sky_quadrant_angles = {180, 180, 180, 180, 0, 0}
local necrosis_music_volume = CreateClientConVar("necrosis_music_volume", "1.2", true, false, "Music volume", 0, 5)

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
		
		do --play
			local panel = vgui.Create("EditablePanel", self)
			swapper.PlayPanel = panel
			
			swapper:Add("Play", panel)
			
			function panel:PerformLayout(width, height)
				self.GamePanel:SetWide(math.min(height * 0.4, width * 0.5))
				self.PlayerInfoPanel:SetWide(math.min(height * 0.3, width * 0.35))
			end
			
			do --player info
				local player_info = vgui.Create("NecrosisMainMenuPlayers", panel)
				panel.PlayerInfoPanel = player_info
				
				player_info:Dock(LEFT)
			end
			
			do --game panel
				local game_panel = vgui.Create("NecrosisMainMenuGame", panel)
				panel.GamePanel = game_panel
				
				game_panel:Dock(RIGHT)
			end
		end
		
		do --settings
			local settings = vgui.Create("NecrosisSettingsMenu", self)
			swapper.SettingsPanel = settings
			
			swapper:Add("Settings", settings)
		end
	end
	
	do --header
		local panel = vgui.Create("Panel", self)
		self.HeaderPanel = panel
		
		panel:Dock(TOP)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end
		
		function panel:PerformLayout(_width, height) self.BottomPanel:SetTall(height * 0.4) end
		
		do --top
			local top_panel = vgui.Create("Panel", panel)
			panel.TopPanel = top_panel
			
			top_panel:Dock(FILL)
			
			function top_panel:PerformLayout(width, height)
				local play_label = self.PlayLabel
				local play_width, play_height = play_label:GetTextSize()
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
				label:SetNecrosisFont("Huge")
				label:SetText(game.SinglePlayer() and "SINGLEPLAYER" or game.IsDedicated() and "MULTIPLAYER" or "HOSTED MULTIPLAYER")
				
				function label:Paint(width, height)
					local text_height = select(2, self:GetTextSize())
					local text_y = (height + text_height) * 0.5
					
					surface.SetDrawColor(192, 192, 192)
					surface.DrawLine(0,  text_y, width, text_y)
				end
			end
			
			do --profile panel
				local profile_panel = vgui.Create("Panel", top_panel)
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
					label:SetNecrosisFont("Big")
					label:SetText("24")
				end
				
				do --progress bar and name
					local fill_panel = vgui.Create("Panel", profile_panel)
					profile_panel.FillPanel = fill_panel
					
					fill_panel:Dock(FILL)
					
					function fill_panel:PerformLayout(_width, height) self.BarPanel:SetTall(height * 0.3) end
					
					do --name label
						local label = vgui.Create("DLabel", fill_panel)
						fill_panel.NameLabel = label
						
						label:Dock(FILL)
						label:SetNecrosisFont("Regular")
						
						--set the label to their name or wait until the player is valid to do so
						if local_player:IsValid() then label:SetText(local_player:Nick())
						else hook.Add("InitPostEntity", label, function(self)
							hook.Remove("InitPostEntity", self)
							self:SetText(LocalPlayer():Nick())
						end) end
					end
					
					do --level bar
						local bar = vgui.Create("Panel", fill_panel)
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
			
			do --money
				local money_sizer = vgui.Create("DSizeToContents", top_panel)
				top_panel.MoneyPanel = money_sizer
				
				money_sizer:Dock(RIGHT)
				
				function money_sizer:PerformLayout(_width, height)
					local money_label = self.Label
					local money_width = money_label:GetTextSize()
					
					money_label:DockMargin(0, 0, 0, 0)
					money_label:SetWide(money_width * 1.1)
					self:SizeToChildren(true)
					self.Icon:SetWide(height)
				end
				
				do --icon
					local icon = vgui.Create("NecrosisMaterialDesignIcon", money_sizer)
					money_sizer.Icon = icon
					
					icon:Dock(LEFT)
					icon:SetIcon("cash_multiple")
				end
				
				do --label
					local label = vgui.Create("DLabel", money_sizer)
					money_sizer.Label = label
					
					label:Dock(LEFT)
					label:NecrosisSetFont("Regular")
					label:SetContentAlignment(5)
					label:SetText("2800")
				end
			end
		end
		
		do --bottom
			local bottom_panel = vgui.Create("Panel", panel)
			panel.BottomPanel = bottom_panel
			
			bottom_panel:Dock(BOTTOM)
			
			function bottom_panel:PerformLayout(width)
				local tabs = self.TabsPanel
				
				tabs:DockMargin(width * 0.05, 0, 0, 0)
				tabs:SetWide(math.ceil(width * 0.4))
			end
			
			do --tabs
				local tabs = vgui.Create("NecrosisTabs", bottom_panel)
				bottom_panel.TabsPanel = tabs
				
				tabs:Add("Play")
				tabs:Add("Weapons")
				tabs:Add("Operators")
				tabs:Add("Settings")
				tabs:Add("Store")
				tabs:Dock(LEFT)
				
				function tabs:OnSelect(key) swapper:Swap(key) end
				
				tabs:Choose(1)
			end
		end
	end
	
	do --footer
		local panel = vgui.Create("Panel", self)
		self.FooterPanel = panel
		
		panel:Dock(BOTTOM)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(0, 0, 0, 192)
			surface.DrawRect(0, 0, width, height)
		end
		
		function panel:PerformLayout()
			local version_label = self.VersionLabel
			
			version_label:SetWide(version_label:GetTextSize() * 1.1)
		end
		
		do --label
			local label = vgui.Create("DLabel", panel)
			panel.VersionLabel = label
			
			label:Dock(RIGHT)
			label:DockMargin(0, 0, 1, 1)
			label:SetContentAlignment(2)
			label:SetNecrosisFont("Tiny")
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
			else stream:Stop() end
		end
	end
	
	if exists then sound.PlayFile(sound_path, "noblock", callback)
	else sound.PlayURL(fallback_url, "noblock", callback) end
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