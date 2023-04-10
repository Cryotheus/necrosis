AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--locals
local area_paths = NECROSIS.NavigationAreaPaths or {}
local maximum_think = 0.04
local paths = NECROSIS.NavigationPaths or {}
local progress_time_interval = 5
local progress_percentage_interval = 0.1

--local tables
local area_direction_rights = {
	[PYRITION_NAV_DIR_EAST] = Vector(-1, 0, 0),
	[PYRITION_NAV_DIR_NORTH] = Vector(0, -1, 0),
	[PYRITION_NAV_DIR_SOUTH] = Vector(1, 0, 0),
	[PYRITION_NAV_DIR_WEST] = Vector(0, 1, 0),
}

--globals
NECROSIS.NavigationAreaPaths = area_paths
NECROSIS.NavigationPaths = paths

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

function ENT:BodyUpdate() end
function ENT:HandleStuck() end

function ENT:Initialize()
	--self:AddEFlags(EFL_SERVER_ONLY)
	--self:AddEFlags(EFL_BOT_FROZEN)
	--self:AddEFlags(EFL_NO_DAMAGE_FORCES)
	--self:AddEFlags(EFL_NO_DISSOLVE)
	--self:AddEFlags(EFL_NO_GAME_PHYSICS_SIMULATION)
	--self:AddFlags(FL_DONTTOUCH)
	--self:AddFlags(FL_FROZEN)
	self:ResetHealth()
	self:SetMaterial("phoenix_storms/stripes")
	self:SetModel("models/player/zombie_fast.mdl")
	--self:SetMoveType(MOVETYPE_NOCLIP)
	self:SharedInitialize()
end

function ENT:HandleAnimEvent(_event, _event_time, _cycle, _class, _options) end
function ENT:OnContact(_entity) end
function ENT:OnEntitySight(_subject) end
function ENT:OnEntitySightLost(_subject) end
function ENT:OnIgnite() end
function ENT:OnInjured(_damage_info) self:ResetHealth() end
function ENT:OnKilled(_damage_info) self:ResetHealth() end
function ENT:OnLandOnGround(_entity) end
function ENT:OnLeaveGround(_entity) end
function ENT:OnNavAreaChanged(_old, _new) end
function ENT:OnOtherKilled(_victim, _info) end
function ENT:OnStuck() end
function ENT:OnTakeDamage(_damage_info) end
function ENT:OnTraceAttack(_damage_info, _direction, _trace) end
function ENT:OnUnStuck() end
function ENT:ResetHealth() self:SetHealth(2147483647) end

function ENT:SolvePaths()
	--TODO: compute additional paths for when areas are disabled
	local area_list = PYRITION.NavigationAreaList
	local existing_paths = {} --keeps track of which paths we have already created
	local path = Path("Follow")
	local valid_area_indices = PYRITION.NavigationAreaIndices
	local valid_area_count = #valid_area_indices

	table.Empty(area_paths)
	table.Empty(paths)

	local function create_safe_segments(source_area)
		local segments = path:GetAllSegments()

		--if the first area is the area we are starting from, remove it
		if segments[1].area == source_area then table.remove(segments, 1) end

		local segment_count = #segments

		--if we have a duplicate area at the end of our path, remove it
		--these last segments usually have butchered portals and are not very useful anyways
		if segment_count > 1 and segments[segment_count].area == segments[segment_count - 1].area then table.remove(segments) end

		return segments
	end

	local function create_sanitized_path(source_area)
		local last_area_index
		local sanitized_path = {}
		local segments = create_safe_segments(source_area)

		--if the first area is the area we are starting from, remove it
		if segments[1].area == source_area then table.remove(segments, 1) end

		local segment_count = #segments

		--if we have a duplicate area at the end of our path, remove it
		--these last segments usually have butchered portals and are not very useful anyways
		if segment_count > 1 and segments[segment_count].area == segments[segment_count - 1].area then table.remove(segments) end

		for index, segment in ipairs(segments) do
			local area = segment.area
			local area_index = area_list[area]

			if area_index ~= last_area_index then
				local portal_center = segment.m_portalCenter
				local portal_enumeration = area:ComputeDirection(portal_center)
				local portal_half_width = segment.m_portalHalfWidth
				local portal_line = area_direction_rights[portal_enumeration] * portal_half_width

				if index ~= 1 then
					sanitized_path[index] = {
						area_index,
						segment.type,
						portal_center + portal_line,
						portal_center - portal_line,
					}
				else
					sanitized_path[index] = {
						area_index,
						segment.type,
					}
				end

			end
			
			last_area_index = area_index

			coroutine.yield()
		end

		return sanitized_path
	end

	local function get_path_area_indices(source_area)
		local area_indices = {}

		for index, segment in ipairs(create_safe_segments(source_area)) do
			area_indices[index] = area_list[segment.area]

			coroutine.yield()
		end

		return area_indices
	end

	local function get_path_index(source_area, area_indices)
		local tree = existing_paths

		for index, area_index in ipairs(area_indices) do
			local branch = tree[area_index]

			if branch then tree = branch
			else
				branch = {}
				tree[area_index] = branch
				tree = branch
			end

			coroutine.yield()
		end

		local path_index = tree[0]

		if path_index then return path_index end

		path_index = table.insert(paths, create_sanitized_path(source_area))
		tree[0] = path_index

		return path_index
	end

	for source_progress, source_index in ipairs(valid_area_indices) do
		local source_area = area_list[source_index]
		local source_paths = {}
		area_paths[source_index] = source_paths

		self:SetLockPosition(source_area:GetCenter())
		coroutine.yield() --wait until the position has been set via Think

		for target_progress, target_index in ipairs(valid_area_indices) do
			--no need to make a path to yourself
			if source_index ~= target_index then
				local target_area = area_list[target_index]

				--don't create a path if the area is a neighbor of ours
				if not source_area:IsConnected(target_area) then
					path:Invalidate()
					path:Compute(self, target_area:GetCenter())

					if path:IsValid() then source_paths[target_index] = get_path_index(source_area, get_path_area_indices(source_area)) end
				end
			end

			self.SolveProgress = Lerp(
				target_progress / valid_area_count, 
				math.max(source_progress - 1, 0) / valid_area_count,
				source_progress / valid_area_count
			)

			coroutine.yield()
		end

		coroutine.yield()
	end
end

function ENT:RunBehaviour()
	self.loco:SetGravity(0)

	local next_progress_percentage = 0
	local next_progress_time = 0
	local stop_time = SysTime() + maximum_think
	local thread = coroutine.create(function() self:SolvePaths() end)

	repeat
		if SysTime() > stop_time then
			coroutine.yield()

			stop_time = SysTime() + maximum_think
		end

		local ok, message = coroutine.resume(thread)

		if not ok then ErrorNoHalt("SolvePaths coroutine error: ", message, "\n") end
		if self.LockAwaitingThink then coroutine.yield() end --wait until the position has been set via Think

		local progress = self.SolveProgress or 0
		
		if progress > next_progress_percentage or RealTime() > next_progress_time then
			next_progress_time = RealTime() + progress_time_interval
			next_progress_percentage = progress + progress_percentage_interval

			--LOCALIZE: progress logging shenanigans
			GAMEMODE:Log("navigation", "Setting up navigation, " .. math.Round(progress * 100, 2) .. "% complete.")
		end
	until coroutine.status(thread) == "dead"

	GAMEMODE:NavigationInitialized()

	self.Done = true

	while true do coroutine.yield() end
end

function ENT:SetLockPosition(position)
	self.LockPosition = position

	if position then
		self.LockAwaitingThink = true

		self:SetAngles(angle_zero)
		self:SetPos(position)
		self.loco:SetVelocity(vector_origin)
	end
end

function ENT:Think()
	if self.Done then
		self.Think = nil

		self:Remove()

		return false
	end

	if self.LockPosition then
		self.LockAwaitingThink = false

		self:SetAngles(angle_zero)
		self:SetPos(self.LockPosition)
		self.loco:SetVelocity(vector_origin)
	end

	self:NextThink(CurTime())

	return true
end

function ENT:Use(_activator, _caller, _type, _value) end