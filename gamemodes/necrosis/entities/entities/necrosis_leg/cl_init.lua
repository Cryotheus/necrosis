include("shared.lua")

--entity functions
function ENT:CreateCostume(model)
	if IsValid(self.Costume) then self.Costume:Remove() end

	local costume = ClientsideModel(model, RENDERGROUP_TRANSLUCENT)
	self.Costume = costume

	--costume:Activate()
	costume:AddEffects(EF_BONEMERGE)
	costume:DrawShadow(false)
	costume:SetLocalAngles(angle_zero)
	costume:SetLocalPos(vector_origin)
	costume:SetNoDraw(true)
	costume:SetParent(self)
	costume:Spawn()

	return costume
end

function ENT:DrawTranslucent(flags)
	local costume = self.Costume
	local ply = self.Player

	if not ply:IsValid() or not costume:IsValid() then return end

	if not ply:ShouldDrawLocalPlayer() then
		self:Reposition()
	
		cam.IgnoreZ(true)
			costume:DrawModel(flags)
		cam.IgnoreZ(false)
	end
end

function ENT:Initialize()
	self.LastThink = CurTime()

	self:DrawShadow(false)
	self:SetModel("models/necrosis/kick/leg.mdl")
end

function ENT:OnRemove() if IsValid(self.Costume) then self.Costume:Remove() end end

function ENT:Reposition()
	local ply = self.Player
	local eye_angles = ply:EyeAngles()
	local pitch = math.Clamp(eye_angles[1] * -0.2, -10, 8) - 10
	local position, angles = LocalToWorld(Vector(0, -3.5, -2.5), Angle(pitch, 0, 0), ply:GetShootPos(), eye_angles)

	self:SetAngles(angles)
	self:SetPos(position)
end

function ENT:SetKickTime(kick_time)
	local ply = self.Player
	self.KickEnd = kick_time + ply:GetPlayerClassNWField("NecrosisKickReset", "2Float")
	self.KickStart = CurTime()
	self.KickTime = kick_time

	self:SetSequence(2)
end

function ENT:SetPlayer(ply)
	--when players are loading in, other players may not be valid
	if not ply:IsValid() then return end

	self.Player = ply

	self:Reposition()
	self:SetParent(ply)
	self:SetPlaybackRate(1)
	self:SetSequence(1)

	--create the clientside model that is bone-merged to the leg
	self:CreateCostume(ply:GetModel())
end

function ENT:Think()
	local kick_time = self.KickTime

	if not kick_time then return end

	local cycle
	local kick_end = self.KickEnd
	local kick_start = self.KickStart
	local time = CurTime()

	--first cycle 0 - 0.3
	--second cycle 0.3 - 1
	if time < kick_time then cycle = math.Remap(time, kick_start, kick_time, 0, 0.3)
	elseif time < kick_end then cycle = math.Remap(time, kick_time, kick_end, 0.3, 1)
	else
		self.KickEnd = nil
		self.KickStart = nil
		self.KickTime = nil

		return
	end

	self:SetCycle(math.Clamp(cycle, 0, 1))
end