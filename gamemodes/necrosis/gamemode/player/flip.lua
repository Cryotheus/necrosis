--locals
local accumulator
local local_player = LocalPlayer():IsValid() and LocalPlayer() or nil
local lock_angle
local start_angle
local transition_angle
local transition_duration = 0.15

--local functions
local function calculate_override_angles(ply, angles)
	local override
	
	if lock_angle then override = accumulator
	elseif transition_time then
		local difference = RealTime() - transition_time

		if difference > transition_duration then transition_time = nil
		else
			transition_angle = LerpAngle(difference / transition_duration, accumulator, angles)
			override = transition_angle
		end
	end

	if override then
		local trace = util.GetPlayerTrace(ply, override:Forward())
		trace.mask = MASK_SHOT

		return override, util.TraceLine(trace).HitPos
	end

	return override
end

--gamemode functions
function GM:CalcView(ply, origin, angles, fov, znear, zfar)
	local override = calculate_override_angles(ply, angles)

	return override and {
		angles = override,
		fov = fov,
		origin = origin,
		zfar = zfar,
		znear = znear,
	} or self.BaseClass:CalcView(ply, origin, angles, fov, znear, zfar)
end

function GM:InitPostEntity() local_player = LocalPlayer() end

function GM:InputMouseApply(command, _x, _y, angles)
	if local_player and local_player:NecrosisPlaying() and not local_player:OnGround() and local_player:GetMoveType() == MOVETYPE_WALK then
		if start_angle then
			local local_angle = select(2, WorldToLocal(vector_origin, angles, vector_origin, lock_angle))

			accumulator = select(2, LocalToWorld(vector_origin, local_angle, vector_origin, accumulator))

			--if override then lock_angle = override end
			lock_angle = (select(2, calculate_override_angles(local_player, angles)) - local_player:GetShootPos()):Angle()

			lock_angle:Normalize()
			lock_angle[1] = math.Clamp(lock_angle[1], -85, 85)
			lock_angle[3] = 0 --no roll for eye angles please
		else
			accumulator = transition_time and transition_angle or angles
			lock_angle = angles
			start_angle = angles

			local override = calculate_override_angles(local_player, angles)

			if override then lock_angle = override end
		end

		accumulator:Normalize()
		command:SetViewAngles(lock_angle)

		return false
	end

	if start_angle then
		local accumulator = Angle(accumulator[1], accumulator[2], 0)

		command:SetViewAngles(accumulator)

		lock_angle = nil
		start_angle = nil
		transition_time = RealTime()
	end

	return false
end