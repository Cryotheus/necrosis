--locals
local angle_zero = angle_zero
local kick_result = {}
local mask_kick = bit.bor(MASK_SOLID, MASK_SHOT)
local mask_lenient_kick = bit.bor(MASK_SOLID, MASK_SHOT_HULL)
local view_punch_hit = Angle(-6, 0, 0)
local view_punch_missed = Angle(4, 0, 0)

--local tables
local kick_trace = {
	mask = mask_kick,
	output = kick_result
}

local kick_trace_hull = {
	mask = mask_lenient_kick, --looser calculation
	output = kick_result,
	ignoreworld = true,
}

--gamemode functions
function GM:PlayerKick(ply)
	---PREDICTED
	ply:SetNecrosisKick(CurTime() + ply:GetPlayerClassNWField("NecrosisKickDelay", "2Float"))
	ply:SetNecrosisKickAttacked(false)
	ply:SetNecrosisKickBlocked(true)
end

function GM:PlayerKickImpact(ply, entity, position)
	---PREDICTED
	---Calls the appropriate kick impact function based on the entity and position.
	---This can call PlayerKickImpactEntity, PlayerKickImpactMissed, or PlayerKickImpactWorld.
	if position then
		ply:ViewPunch(view_punch_hit)

		if entity then self:PlayerKickImpactEntity(ply, entity, position)
		else self:PlayerKickImpactWorld(ply, position) end

		return
	end

	ply:ViewPunch(view_punch_missed)
	self:PlayerKickImpactMissed(ply)
end

function GM:PlayerKickStartCommand(ply, _player_class, command)
	---PREDICTED
	if self.PlayerKicking then command:AddKey(IN_CANCEL) end --set by client using a command

	local kicking = command:KeyDown(IN_CANCEL)
	local was_kicking = ply:GetNecrosisKicking() or false

	if kicking ~= was_kicking then
		ply:SetNecrosisKicking(kicking)

		--make the player start a kick
		if kicking and not (command:KeyDown(IN_SPEED) and ply:OnGround() or ply:GetNecrosisKickBlocked()) then
			--checks: pressing the key, not sprinting on the ground, and kicking is not blocked
			self:PlayerKick(ply)
		end
	end

	local kick_time = ply:GetNecrosisKickBlocked() and ply:GetNecrosisKick()

	if kick_time then
		if CurTime() > kick_time + ply:GetPlayerClassNWField("NecrosisKickReset", "2Float") then
			--finish the kick
			ply:SetNecrosisKickBlocked(false)
			ply:SetNecrosisKickAttacked(false)
		elseif CurTime() > kick_time and not ply:GetNecrosisKickAttacked(true) then
			--do the kick damage and stuff
			ply:SetNecrosisKickAttacked(true)
			self:PlayerKickImpact(ply, self:PlayerKickTrace(ply))
		end
	end
end

function GM:PlayerKickTrace(ply)
	---PREDICTED
	--overview:
	--first we do a simple line trace to see if they are aiming at an entity
	--if that doesn't work, we do a hull trace
	--if there's a valid entity we make sure we're not gonna hit them through a wall or something (using another line trace)
	local aim_vector = ply:GetAimVector()
	local player_list = player.GetAll()
	local shoot_position = ply:GetShootPos()

	kick_trace.start = shoot_position
	kick_trace.endpos = shoot_position + aim_vector * ply:GetPlayerClassNWField("NecrosisKickRange", "2Float")
	kick_trace.filter = player_list

	util.TraceLine(kick_trace)

	local first_trace_hit = kick_result.Hit
	local entity = kick_result.Entity

	--line trace did just fine, use that
	if entity:IsValid() and not entity:IsWorld() then return entity, kick_result.HitPos end

	local kick_size = ply:GetPlayerClassNWField("NecrosisKickSize", "2Float")
	local kick_hull = Vector(kick_size, kick_size, kick_size)

	kick_trace_hull.endpos = kick_result.HitPos
	kick_trace_hull.filter = player_list
	kick_trace_hull.maxs = kick_hull
	kick_trace_hull.mins = -kick_hull
	kick_trace_hull.start = shoot_position

	util.TraceHull(kick_trace_hull)

	entity = kick_result.Entity
	local hit_position = kick_result.HitPos

	--we didn't hit anything, give up
	if not entity:IsValid() or entity:IsWorld() then return nil, (first_trace_hit or kick_result.Hit) and hit_position end

	local eye_angles = aim_vector:Angle()
	local local_position = WorldToLocal(entity:WorldSpaceCenter(), angle_zero, hit_position, eye_angles)
	local_position[1] = 0 --remove depth

	kick_trace.endpos = LocalToWorld(local_position, angle_zero, hit_position, eye_angles)
	kick_trace.mask = mask_lenient_kick --use the more lenient mask this time around
	kick_trace.start = hit_position

	util.TraceLine(kick_trace)

	--restore to the original mask
	kick_trace.mask = mask_kick

	--we hit the entity, so we're good
	if kick_result.Entity == entity then return entity, (first_trace_hit or kick_result.Hit) and hit_position end

	return nil, (first_trace_hit or kick_result.Hit) and hit_position
end