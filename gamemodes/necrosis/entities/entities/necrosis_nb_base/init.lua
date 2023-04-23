AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--accessor functions
AccessorFunc(ENT, "Target", "Target")

--locals
local area_list = PYRITION.NavigationAreaList
local area_paths = NECROSIS.NavigationAreaPaths
local paths = NECROSIS.NavigationPaths

--local functions
local function get_path(start_index, target_index)
	local targets_pathable = area_paths[start_index]

	if targets_pathable then
		local path_index = targets_pathable[target_index]

		if path_index then return paths[path_index] end
	end
end

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

function ENT:FindTarget()
	if self.Target then return self.Target end

	local allow_different_areas = true
	local current_area = self.CurrentNavArea
	local current_area_index = self.CurrentNavAreaIndex
	local distance_targets = {}
	local record
	local record_distance = math.huge

	for index, ply in ipairs(NECROSIS.PlayerListTargettable) do
		local target_area_index = ply.NecrosisCurrentNavAreaIndex

		if current_area_index == target_area_index then
			allow_different_areas = false

			table.insert(distance_targets, ply)
		elseif allow_different_areas then
			local path = get_path(current_area_index, target_area_index)

			if path then
				local current_area_center = current_area:GetCenter()
				local path_distance = path.Distance + area_list[path[#path]]:Distance(current_area_center)
			end
		end
	end
end

function ENT:HandleStuck() self.loco:ClearStuck() end

function ENT:Initialize()
	self:SetHealth(60)
	self:SetModel("models/player/zombie_fast.mdl")
	self:SharedInitialize()
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

function ENT:OnNavAreaChanged(_old, new)
	self.CurrentNavArea = new
	self.CurrentNavAreaIndex = area_list[new]
end

function ENT:OnOtherKilled(_victim, _info) end
function ENT:OnStuck() end
function ENT:OnTakeDamage(_damage_info) end
function ENT:OnTraceAttack(_damage_info, _direction, _trace) end
function ENT:OnUnStuck() end

function ENT:AdvancePath()

end

function ENT:RunBehaviour()
	self.loco:SetDesiredSpeed(200)
	self:StartActivity(ACT_RUN_PISTOL)

	while true do
		if not self.CurrentNavArea then print("no nav area yet...")
		else
			local approach_position
			local source_area = self.CurrentNavArea
			local source_area_index = area_list[source_area]
			local target = self:FindTarget()
			local target_area = target.NecrosisCurrentNavArea
			local target_area_index = target.NecrosisCurrentNavAreaIndex

			if source_area_index == target_area_index then approach_position = target:GetPos()
			else

			end

			if approach_position then self.loco:Approach(approach_position, 1) end
		end

		coroutine.yield()
	end
end

function ENT:Think() end
function ENT:Use(_activator, _caller, _type, _value) end

--hooks
hook.Add("PyritionPostNavigationSetup", "NecrosisEntityNBBase", function() area_list = PYRITION.NavigationAreaList end)

hook.Add("NecrosisNavigationInitialize", "NecrosisEntityNBBase", function()
	area_paths = NECROSIS.NavigationAreaPaths
	paths = NECROSIS.NavigationPaths
end)