AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--locals
local area_paths = NECROSIS.NavigationAreaPaths or {}
local maximum_think = 0.02
local paths = NECROSIS.NavigationPaths or {}

--local tables
local area_direction_rights = {
	[PYRITION_NAV_DIR_EAST] = Vector(0, -1, 0),
	[PYRITION_NAV_DIR_NORTH] = Vector(-1, 0, 0),
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
	self:SetHealth(2147483647)
	self:SetMaterial("phoenix_storms/stripes")
	self:SetModel("models/player/zombie_fast.mdl")
	self:SharedInitialize()
end

function ENT:HandleAnimEvent(_event, _event_time, _cycle, _class, _options) end
function ENT:OnContact(_entity) end
function ENT:OnEntitySight(_subject) end
function ENT:OnEntitySightLost(_subject) end
function ENT:OnIgnite() end
function ENT:OnInjured(_damage_info) self:SetHealth(2147483647) end
function ENT:OnKilled(damage_info) self:BecomeRagdoll(damage_info) end
function ENT:OnLandOnGround(_entity) end
function ENT:OnLeaveGround(_entity) end
function ENT:OnNavAreaChanged(_old, _new) end
function ENT:OnOtherKilled(_victim, _info) end
function ENT:OnStuck() end
function ENT:OnTakeDamage(_damage_info) end
function ENT:OnTraceAttack(_damage_info, _direction, _trace) end
function ENT:OnUnStuck() end

function ENT:RunBehaviour()
	local thread = coroutine.create(function()
		--TODO: compute additional paths for when areas are disabled
		local area_list = PYRITION.NavigationAreaList
		local existing_paths = {} --keeps track of which paths we have already created
		local path = Path("Follow")
		local valid_area_indices = PYRITION.NavigationAreaIndices

		table.Empty(area_paths)

		--[[local sanitized_path = {
			{
				number area_index, --this is the only value that we will save to disk
				number behavior,
				Vector portal_start,
				Vector portal_end,
			},

			...
		}]]

		local function create_sanitized_path(source_area)
			local duplicates = false
			local last_area_index
			local sanitized_path = {}
			local segments = path:GetAllSegments()

			--if the first area is the area we are starting from, remove it
			if segments[1].area == source_area then table.remove(segments, 1) end

			local segment_count = #segments

			--if we have a duplicate area at the end of our path, remove it
			--these last segments usually have butchered portals and are not very useful anyways
			if segment_count > 1 and segments[segment_count].area == segments[segment_count - 1].area then table.remove(segments) end

			for index, segment in ipairs(segments) do
				local area = segment.area
				local area_index = area_list[area]
				local portal_center = segment.m_portalCenter
				local portal_enumeration = area:ComputeDirection(portal_center)
				local portal_half_width = segment.m_portalHalfWidth
				local portal_line = area_direction_rights[portal_enumeration] * portal_half_width

				if area_index == last_area_index then duplicates = true end --TODO: remove debug

				sanitized_path[index] = {
					area_index,
					segment.type,
					portal_center + portal_line,
					portal_center - portal_line,
				}

				last_area_index = area_index --TODO: remove debug
			end

			if not duplicates then print("no duplicates :D") end --TODO: remove debug

			return sanitized_path
		end

		local function get_path_areas()
			local area_indices = {}

			for index, segment in ipairs(path:GetAllSegments()) do area_indices[index] = area_list[area_list[segment.area]] end

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
			end

			local path_index = tree.Index

			if path_index then return path_index end

			path_index = table.insert(paths, create_sanitized_path(source_area))
			tree.Index = path_index

			return path_index
		end

		for _, source_index in ipairs(valid_area_indices) do
			local source_area = area_list[source_index]
			local source_paths = {}
			area_paths[source_index] = source_paths

			self:SetLockPosition(source_area:GetCenter())

			for _, target_index in ipairs(valid_area_indices) do
				--no need to make a path to yourself
				if source_index ~= target_index then
					local target_area = area_list[target_index]

					--don't create a path if the area is a neighbor of ours
					if not source_area:IsConnected(target_area) then
						path:Compute(self, target_area:GetCenter())

						if path:IsValid() then
							source_paths[target_index] = get_path_index(source_area, get_path_areas(path))
						end
					end
				end

				coroutine.yield()
			end

			coroutine.yield()
		end
	end)

	local stop_time = SysTime() + maximum_think

	repeat
		local ok, message = coroutine.resume(thread)

		if not ok then ErrorNoHalt(tostring(self), " coroutine erred: ", message, "\n") end

		--if we're destroying the host's CPU - yield
		if SysTime() > stop_time then
			coroutine.yield()

			stop_time = SysTime() + maximum_think
		end
	until coroutine.status(thread) == "dead"

	GAMEMODE:NavigationInitialized()
	
	self.Done = true

	while true do coroutine.yield() end
end

function ENT:SetLockPosition(position)
	self.LockPosition = position

	if position then self:SetPos(position) end
end

function ENT:Think()
	if self.Done then
		self.Think = nil

		self:Remove()

		return false
	end

	if self.LockPosition then self:SetPos(self.LockPosition) end

	self:NextThink(CurTime())

	return true
end

function ENT:Use(_activator, _caller, _type, _value) end