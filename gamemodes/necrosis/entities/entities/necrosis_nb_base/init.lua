AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--locals
--local chase_gap = 36
local fail_repath_delay = 2
local repath_delay = 2

--enumerations
local PATHING_FAILED = 1
local PATHING_OK = 2
local PATHING_STUCK = 3

--debug for now
local path_meta = FindMetaTable("PathFollower")

function path_meta:SmartChase(_bot, _target) end

--entity functions
function ENT:BehaveStart() self.BehaveThread = coroutine.create(function() self:RunBehaviour() end) end

function ENT:BehaveUpdate(_interval)
	local thread = self.BehaveThread

	if thread then
		if coroutine.status(thread) == "dead" then Msg(tostring(self) .. " coroutine finished")
		else
			local ok, message = coroutine.resume(thread)

			if ok then return end

			ErrorNoHalt(tostring(self), " coroutine erred: ", message, "\n")
		end

		self.BehaveThread = nil
	end
end

function ENT:BodyUpdate()
	local act = self:GetActivity()

	if act == ACT_RUN or act == ACT_WALK then return self:BodyMoveXY() end

	self:FrameAdvance()
end

function ENT:Chase(entity)
	--local chase_segment
	--local chase_start
	local chaser = Path("Chase")
	local do_chase = false
	local follower = Path("Follow")
	local follower_segment_count
	local follower_segments
	local next_repath = 0

	self.Chasing = true

	chaser:Invalidate()
	follower:SetGoalTolerance(20)
	follower:SetMinLookAheadDistance(300)

	local function repath()
		follower:Compute(self, entity:GetPos())

		if not follower:IsValid() then return false end

		follower_segments = follower:GetAllSegments()
		follower_segment_count = #follower_segments

		print(follower_segment_count)

		return true
	end

	local function wait_repath() while not repath() do coroutine.wait(fail_repath_delay) end end

	if not repath() then return end

	while true do
		local entity_area = entity.NecrosisCurrentNavArea

		if do_chase then
			--Compute should be cheap when the bot is in the same area as the target
			chaser:Compute(self, entity:GetPos())

			if chaser:IsValid() and chaser:FirstSegment().area == entity_area then
				--fixes pathing to area's portal instead of target
				chaser:MoveCursorToEnd()

				--Chase is the equivalent of the Update function
				chaser:Chase(self, entity)
				chaser:Draw()

				coroutine.yield()
			else wait_repath() end
		else
			print("follow")

			local goal = follower:GetCurrentGoal()

			if goal and goal.length == 0 and goal.area == entity_area then
				do_chase = true

				follower:Invalidate()
			else
				local cur_time = CurTime()

				if cur_time > next_repath then
					next_repath = cur_time + repath_delay

					wait_repath()
				end

				follower:Update(self)
				follower:Draw()
			end

			coroutine.yield()
		end
	end
end

function ENT:HandleStuck() self.loco:ClearStuck() end

function ENT:Initialize()
	self:SetHealth(60)
	self:SetModel("models/player/zombie_fast.mdl")
	self:SharedInitialize()
end

function ENT:MoveToPosition(position)
	local path = Path("Follow")

	path:SetGoalTolerance(20)
	path:SetMinLookAheadDistance(300)
	path:Compute(self, position)

	if path:IsValid() then
		while path:IsValid() do
			path:Update(self)
			path:Draw()

			if self.loco:IsStuck() then
				self:HandleStuck()

				return PATHING_STUCK
			end

			coroutine.yield()
		end
	else return PATHING_FAILED end

	return PATHING_OK
end

function ENT:HandleAnimEvent(_event, _event_time, _cycle, _class, _options) end
function ENT:OnContact(_entity) end
function ENT:OnEntitySight(_subject) end
function ENT:OnEntitySightLost(_subject) end
function ENT:OnIgnite() end
function ENT:OnInjured(_damage_info) end
function ENT:OnKilled(damage_info) self:BecomeRagdoll(damage_info) end
function ENT:OnLandOnGround(_entity) end
function ENT:OnLeaveGround(_entity) end
function ENT:OnNavAreaChanged(_old, _new) end --THIS IS SO USEFUL!!! THANK YOU VALVE!!!
function ENT:OnOtherKilled(_victim, _info) end
function ENT:OnStuck() end
function ENT:OnTakeDamage(_damage_info) end
function ENT:OnTraceAttack(_damage_info, _direction, _trace) end
function ENT:OnUnStuck() end

function ENT:RunBehaviour()
	self.loco:SetDesiredSpeed(200)
	self:StartActivity(ACT_RUN_PISTOL)

	while true do
		print("create path")

		local path = Path("Chase")
		local target = player.GetAll()[1]

		if target then
			print("compute path")
			path:SetGoalTolerance(20)
			path:SetMinLookAheadDistance(300)
			--path:Compute(self, Entity(1):GetPos())

			while target:IsValid() do
				path:Chase(self, target)
				path:Draw()

				coroutine.yield()
			end
		end

		coroutine.yield()
	end
end

function ENT:Think() end
function ENT:Use(_activator, _caller, _type, _value) end