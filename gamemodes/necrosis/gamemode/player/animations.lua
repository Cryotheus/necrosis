--locals
local idle_activity = ACT_HL2MP_IDLE

--local tables
local idle_activity_translations = {
	[ACT_MP_STAND_IDLE]					= idle_activity,
	[ACT_MP_WALK]						= idle_activity + 1,
	[ACT_MP_RUN]						= idle_activity + 2,
	[ACT_MP_CROUCH_IDLE]				= idle_activity + 3,
	[ACT_MP_CROUCHWALK]					= idle_activity + 4,
	[ACT_MP_ATTACK_STAND_PRIMARYFIRE]	= idle_activity + 5,
	[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE]	= idle_activity + 5,
	[ACT_MP_RELOAD_STAND]				= idle_activity + 6,
	[ACT_MP_RELOAD_CROUCH]				= idle_activity + 6,
	[ACT_MP_JUMP]						= ACT_HL2MP_JUMP_SLAM,
	[ACT_MP_SWIM]						= idle_activity + 9,
	[ACT_LAND]							= ACT_LAND,
}

--gamemode functions
function GM:CalcMainActivity(ply, velocity)
	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1
	
	self:HandlePlayerLanding(ply, velocity, ply.m_bWasOnGround)
	
	if not self:HandlePlayerNoClipping(ply, velocity) or
		self:HandlePlayerDriving(ply) or
		self:HandlePlayerVaulting(ply, velocity) or
		self:HandlePlayerJumping(ply, velocity) or
		self:HandlePlayerSwimming(ply, velocity) or
		self:HandlePlayerDucking(ply, velocity) then
		
		local planar_speed = velocity:Length2DSqr()
			
		if planar_speed > 22500 then ply.CalcIdeal = ACT_MP_RUN elseif planar_speed > 0.25 then ply.CalcIdeal = ACT_MP_WALK end
	end
	
	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = ply:GetMoveType() == MOVETYPE_NOCLIP and not ply:InVehicle()
	
	return ply.CalcIdeal, ply.CalcSeqOverride
end

function GM:DoAnimationEvent(ply, event, _data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		if ply:IsFlagSet(FL_ANIMDUCKING) then ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true)
		else ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true) end

		return ACT_VM_PRIMARYATTACK
	elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then return ACT_VM_SECONDARYATTACK --there is no gesture, so just fire off the VM event
	elseif event == PLAYERANIMEVENT_RELOAD then
		if ply:IsFlagSet(FL_ANIMDUCKING) then ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true)
		else ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true) end
		
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_JUMP then
		ply.m_bFirstJumpFrame = true
		ply.m_bJumping = true
		ply.m_flJumpStartTime = CurTime()
		
		ply:AnimRestartMainSequence()
		
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
		ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
		
		return ACT_INVALID
	end
end

function GM:GrabEarAnimation(ply)
	ply.ChatGestureWeight = ply.ChatGestureWeight or 0
	
	if ply:IsPlayingTaunt() then return end
	if ply:IsTyping() then ply.ChatGestureWeight = math.Approach(ply.ChatGestureWeight, 1, FrameTime() * 5.0)
	else ply.ChatGestureWeight = math.Approach(ply.ChatGestureWeight, 0, FrameTime() * 5.0) end
	
	if ply.ChatGestureWeight > 0 then
		ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, ply.ChatGestureWeight)
	end
end

function GM:HandlePlayerDriving(ply)
	--the player must have a parent to be in a vehicle. If there's no parent, we are in the exit anim, so don't do sitting in 3rd person anymore
	if not ply:InVehicle() or not ply:GetParent():IsValid() then return false end
	
	local vehicle = ply:GetVehicle()
	
	if not vehicle.HandleAnimation and vehicle.GetVehicleClass then
		local class = vehicle:GetVehicleClass()
		local details = list.Get("Vehicles")[class]
		
		if details and details.Members and details.Members.HandleAnimation then vehicle.HandleAnimation = details.Members.HandleAnimation
		else vehicle.HandleAnimation = true end
	end
	
	if isfunction(vehicle.HandleAnimation) then
		local sequence = vehicle:HandleAnimation(ply)
		
		if sequence ~= nil then ply.CalcSeqOverride = sequence end
	end
	
	--vehicle.HandleAnimation did not give us an animation
	if ply.CalcSeqOverride == -1 then
		local class = vehicle:GetClass()
		
		if class == "prop_vehicle_jeep" then ply.CalcSeqOverride = ply:LookupSequence("drive_jeep")
		elseif class == "prop_vehicle_airboat" then ply.CalcSeqOverride = ply:LookupSequence("drive_airboat")
		elseif class == "prop_vehicle_prisoner_pod" and vehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" then
			--HACK: all seats are prop_vehicle_prisoner_pod, but only this one has the right model for this animation
			ply.CalcSeqOverride = ply:LookupSequence("drive_pd")
		else ply.CalcSeqOverride = ply:LookupSequence("sit_rollercoaster") end
	end
	
	if (ply.CalcSeqOverride == ply:LookupSequence("sit_rollercoaster") or ply.CalcSeqOverride == ply:LookupSequence("sit")) and ply:GetAllowWeaponsInVehicle() and ply:GetActiveWeapon():IsValid() then
		local hold_type = ply:GetActiveWeapon():GetHoldType()
		
		if hold_type == "smg" then hold_type = "smg1" end
		
		local sequence_id = ply:LookupSequence("sit_" .. hold_type)
		
		if sequence_id ~= -1 then ply.CalcSeqOverride = sequence_id end
	end
	
	return true
end

function GM:HandlePlayerDucking(ply, velocity)
	if not ply:IsFlagSet(FL_ANIMDUCKING) then return false end
	if velocity:Length2DSqr() > 0.25 then ply.CalcIdeal = ACT_MP_CROUCHWALK
	else ply.CalcIdeal = ACT_MP_CROUCH_IDLE end
	
	return true
end

function GM:HandlePlayerJumping(ply, velocity)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		ply.m_bJumping = false
		
		return
	end
	
	--airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	--underwater we're alright we airwalking
	if not ply.m_bJumping and not ply:OnGround() and ply:WaterLevel() <= 0 then
		if not ply.m_fGroundTime then ply.m_fGroundTime = CurTime()
		elseif CurTime() - ply.m_fGroundTime > 0 and velocity:Length2DSqr() < 0.25 then
			ply.m_bFirstJumpFrame = false
			ply.m_bJumping = true
			ply.m_flJumpStartTime = 0
		end
	end
	
	if ply.m_bJumping then
		if ply.m_bFirstJumpFrame then
			ply.m_bFirstJumpFrame = false
			
			ply:AnimRestartMainSequence()
		end
		
		if ply:WaterLevel() >= 2 or CurTime() - ply.m_flJumpStartTime > 0.2 and ply:OnGround() then
			ply.m_bJumping = false
			ply.m_fGroundTime = nil
			
			ply:AnimRestartMainSequence()
		end
		
		if ply.m_bJumping then
			ply.CalcIdeal = ACT_MP_JUMP
			
			return true
		end
	end
	
	return false
end

function GM:HandlePlayerLanding(ply, _velocity, was_on_ground)
	if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
	if ply:IsOnGround() and not was_on_ground then ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true) end
end

function GM:HandlePlayerNoClipping(ply, _velocity)
	if ply:GetMoveType() ~= MOVETYPE_NOCLIP or ply:InVehicle() then
		if ply.m_bWasNoclipping then
			ply.m_bWasNoclipping = nil
			
			ply:AnimResetGestureSlot(GESTURE_SLOT_CUSTOM)
			
			if CLIENT then ply:SetIK(true) end
		end
		
		return false
	end
	
	if not ply.m_bWasNoclipping then
		ply:AnimRestartGesture(GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false)
		
		if CLIENT then ply:SetIK(false) end
	end
	
	return true
end

function GM:HandlePlayerSwimming(ply, _velocity)
	if ply:WaterLevel() < 2 or ply:IsOnGround() then
		ply.m_bInSwim = false
		
		return false
	end
	
	ply.CalcIdeal = ACT_MP_SWIM
	ply.m_bInSwim = true
	
	return true
end

function GM:HandlePlayerVaulting(ply, velocity)
	if velocity:LengthSqr() < 1000000 then return end
	if ply:IsOnGround() then return end
	
	ply.CalcIdeal = ACT_MP_SWIM
	
	return true
end

function GM:MouthMoveAnimation(ply)
	local flexes = {
		ply:GetFlexIDByName("jaw_drop"),
		ply:GetFlexIDByName("left_mouth_drop"),
		ply:GetFlexIDByName("left_part"),
		ply:GetFlexIDByName("right_mouth_drop"),
		ply:GetFlexIDByName("right_part"),
	}
	
	local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 2, 0, 2) or 0
	
	for _, flex_index in pairs(flexes) do ply:SetFlexWeight(flex_index, weight) end
end

function GM:TranslateActivity(ply, activity)
	local new_activity = ply:TranslateWeaponActivity(activity)
	
	--select idle animations if the weapon didn't decide
	if activity == new_activity then return idle_activity_translations[activity] end
	
	return new_activity
end

function GM:UpdateAnimation(ply, velocity, sequence_speed)
	local length = velocity:Length()
	local movement = 1.0
	
	if length > 0.2 then movement = (length / sequence_speed) end
	
	local rate = math.min(movement, 2)
	
	--if we're under water we want to constantly be swimming
	if ply:WaterLevel() >= 2 then rate = math.max(rate, 0.5)
	elseif not ply:IsOnGround() and length >= 1000 then rate = 0.1 end
	
	ply:SetPlaybackRate(rate)
	
	if CLIENT then
		if ply:InVehicle() then
			local vehicle = ply:GetVehicle()
			local forward = vehicle:GetUp()
			local steer = vehicle:GetPoseParameter("vehicle_steer") * 2 - 1
			
			ply:SetPoseParameter("vertical_velocity", math.max(forward:Dot(Vector(0, 0, 1)), 0) + forward:Dot(vehicle:GetVelocity()) * 0.005)
			
			if vehicle:GetClass() == "prop_vehicle_prisoner_pod" then steer = 0 ply:SetPoseParameter("aim_yaw", math.NormalizeAngle(ply:GetAimVector():Angle().y - vehicle:GetAngles().y - 90)) end
			
			ply:SetPoseParameter("vehicle_steer", steer)
		end
		
		self:GrabEarAnimation(ply)
		self:MouthMoveAnimation(ply)
	end
end