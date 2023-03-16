--locals
local camera_position = Vector(200, 0, 55)
local PANEL = {}

--panel functions
function PANEL:DrawModels()
	local client_model_player = self.ClientModelPlayer
	local client_model_weapon = self.ClientModelWeapon
	
	local end_x, end_y = self:LocalToScreen(self:GetWide(), self:GetTall())
	local start_x, start_y = self:LocalToScreen(0, 0)
	
	render.SetScissorRect(start_x, start_y, end_x, end_y, true)
		client_model_player:DrawModel()
		client_model_weapon:DrawModel()
	render.SetScissorRect(0, 0, 0, 0, false)
end

function PANEL:Init()
	local cl_playermodel = player_manager.TranslatePlayerModel(GetConVar("cl_playermodel"):GetString())
	local client_model_player = ClientsideModel(cl_playermodel, RENDERGROUP_BOTH)
	local client_model_weapon = ClientsideModel("models/weapons/w_irifle.mdl", RENDERGROUP_OTHER)
	local player_color = HSVToColor(math.random(0, 360), 1, 1)
	player_color = Vector(player_color.r / 255, player_color.g / 255, player_color.b / 255)
	
	client_model_player:SetAngles(Angle(0, 0, 0))
	client_model_player:SetNoDraw(true)
	client_model_player:SetPos(Vector(0, 0, 0))
	client_model_player:SetSequence(client_model_player:LookupSequence("idle_passive"))
	
	client_model_weapon:AddEffects(EF_BONEMERGE)
	client_model_weapon:SetNoDraw(true)
	client_model_weapon:SetParent(client_model_player)
	
	function client_model_player:GetPlayerColor() return player_color end
	
	self.ClientModelPlayer = client_model_player
	self.ClientModelWeapon = client_model_weapon
	self.LastPaint = 0
	self.LastPitch = 0
	self.LastYaw = 0
end

function PANEL:OnRemove()
	local client_model_player = self.ClientModelPlayer
	local client_model_weapon = self.ClientModelWeapon
	
	if client_model_player then client_model_player:Remove() end
	if client_model_weapon then client_model_weapon:Remove() end
end

function PANEL:Paint(width, height)
	local client_model_player = self.ClientModelPlayer
	
	if not IsValid(client_model_player) then return end
	
	local blink = math.min(math.sin(RealTime() * 0.5) ^ 4000 * 10, 1)
	local blink_flex = client_model_player:GetFlexIDByName("blink")
	local left_lid_flex = client_model_player:GetFlexIDByName("left_lid_raiser")
	local right_lid_flex = client_model_player:GetFlexIDByName("right_lid_raiser")
	local head_pitch_minimum, head_pitch_maximum = client_model_player:GetPoseParameterRange(client_model_player:LookupPoseParameter("head_pitch"))
	local head_yaw_minimum, head_yaw_maximum = client_model_player:GetPoseParameterRange(client_model_player:LookupPoseParameter("head_yaw"))
	local lids = math.Remap(blink, 0, 1, 0.8, 0)
	local mouse_x, mouse_y
	local smile_flex = client_model_player:GetFlexIDByName("smile")
	local x, y = self:LocalToScreen(0, 0)
	
	if system.HasFocus() then
		mouse_x = gui.MouseX()
		mouse_y = gui.MouseY()
	else
		mouse_x = ScrW() * 0.5
		mouse_y = ScrH() * 0.5
	end
	
	local pitch = Lerp(0.2, self.LastPitch, math.Remap(mouse_y, 0, ScrH(), head_pitch_minimum, head_pitch_maximum * 0.7))
	local yaw = Lerp(0.2, self.LastYaw, math.Remap(mouse_x, 0, ScrW(), head_yaw_minimum * 0.65, head_yaw_maximum * 0.65))
	
	self.LastPaint = RealTime()
	self.LastPitch = pitch
	self.LastYaw = yaw
	
	if blink_flex then client_model_player:SetFlexWeight(blink_flex, blink) end
	if left_lid_flex then client_model_player:SetFlexWeight(left_lid_flex, lids) end
	if right_lid_flex then client_model_player:SetFlexWeight(right_lid_flex, lids) end
	if smile_flex then client_model_player:SetFlexWeight(smile_flex, 0.25) end
	
	cam.Start3D(camera_position, Angle(0, 180, 0), 45, x, y, width, height, 5, 1024)
		render.SuppressEngineLighting(true)
			render.SetLightingOrigin(vector_origin)
			render.ResetModelLighting(0.2, 0.2, 0.2)
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
			
			--221 112 13 300
			--0.86, 0.44, 0.05
			render.SetModelLighting(BOX_FRONT, 0.56, 0.44, 0.35)
			render.SetModelLighting(BOX_TOP, 0.56, 0.44, 0.35)
			--render.SetModelLighting(BOX_FRONT, 1, 1, 1)
			--render.SetModelLighting(BOX_TOP, 1, 1, 1)
			
			client_model_player:FrameAdvance((RealTime() - self.LastPaint) * 0.15)
			client_model_player:SetEyeTarget(Vector(50, math.Remap(mouse_x, 0, ScrW(), -100, 100), math.Remap(mouse_y, 0, ScrH(), 100, -25)))
			client_model_player:SetPoseParameter("head_pitch", pitch)
			client_model_player:SetPoseParameter("head_yaw", yaw)
			self:DrawModels()
		render.SuppressEngineLighting(false)
	cam.End3D()
end

--post
derma.DefineControl("NecrosisMainMenuModel", "Graphic of the client's player model.", PANEL, "Panel")