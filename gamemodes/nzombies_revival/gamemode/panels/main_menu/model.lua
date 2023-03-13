--locals
local camera_position = Vector(50, 0, 45)
local PANEL = {}

--panel functions
function PANEL:DoClick() error("let the player select a model") end

function PANEL:DrawModel(client_model)
	local end_x, end_y = self:LocalToScreen(self:GetWide(), self:GetTall())
	local start_x, start_y = self:LocalToScreen(0, 0)
	
	render.SetScissorRect(start_x, start_y, end_x, end_y, true)
		client_model:SetNoDraw(false)
		client_model:DrawModel()
	render.SetScissorRect(0, 0, 0, 0, false)
end

function PANEL:Init()
	local client_model_player = ClientsideModel("models/player.mdl", RENDERGROUP_BOTH)
	--local client_model_weapon = ClientsideModel("", RENDERGROUP_OTHER)
	
	self.ClientModelPlayer = client_model_player
	self.ClientModelWeapon = client_model_weapon
	self.LastPaint = 0
	
	self:SetText("")
end

function PANEL:OnRemove()
	local client_model_player = self.ClientModelPlayer
	local client_model_weapon = self.ClientModelWeapon
	
	if client_model_player then client_model_player:Remove() end
	if client_model_weapon then client_model_weapon:Remove() end
end

function PANEL:Paint(width, height)
	local client_model_player = self.ClientModelPlayer
	local ply = LocalPlayer()
	--local points = {}
	self.LastPaint = RealTime()
	
	--surface.SetDrawColor(0, 0, 0, 64)
	--surface.DrawRect(0, 0, width, height)
	
	if not ply:IsValid() then return end
	if not IsValid(client_model_player) then return end
	
	local x, y = self:LocalToScreen(0, 0)
	
	--cam.Start3D(camera_position, Angle(0, 180, 0), 60, x, y, width, height, 5, 1024)
	--cam.End3D()
	
	cam.Start3D(camera_position, Angle(0, 180, 0), 60, x, y, width, height, 5, 1024)
		render.SuppressEngineLighting(true)
			render.SetLightingOrigin(vector_origin)
			render.ResetModelLighting(0.2, 0.2, 0.2)
			render.SetColorModulation(1, 1, 1)
			render.SetBlend(1)
			
			render.SetModelLighting(BOX_FRONT, 1, 1, 1)
			render.SetModelLighting(BOX_TOP, 1, 1, 1)
			
			client_model_player:FrameAdvance((RealTime() - self.LastPaint) * 0.25)
			--client_model_player:SetupBones()
			self:DrawModel(client_model_player)
			
			--[[
			for index = 1, client_model_player:GetBoneCount() do
				local bone_index = index - 1
				local position = client_model_player:GetBonePosition(bone_index)
				
				if position and (position.x ~= 0 or position.y ~= 0 or position.z ~= 0) then
					render.DrawSphere(position, 2, 4, 4, Color(255, 0, 0, 128))
					
					position:Mul(0.6)
					
					table.insert(points, position:ToScreen())
				end
			end --]]
		render.SuppressEngineLighting(false)
	cam.End3D()
	
	--cam.Start3D()
	--cam.End3D()
	
	--[[
	for index, point in ipairs(points) do
		local x, y = self:ScreenToLocal(point.x, point.y)
		
		surface.SetDrawColor(255, 0, 0, 128)
		surface.DrawRect(x - 2, y - 2, 4, 4)
	end --]]
end

--post
derma.DefineControl("ZombinoMainMenuModel", "Graphic of the client's player model.", PANEL, "DButton")