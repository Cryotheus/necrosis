--locals
local area_list = PYRITION.NavigationAreaList
local area_paths = NECROSIS.NavigationAreaPaths or {}
local debug_command_flags = bit.bor(FCVAR_CHEAT, FCVAR_UNREGISTERED)
local paths = NECROSIS.NavigationPaths or {}
local version = 1

local debug_navarea_color = Color(255, 192, 0, 2)
local debug_path_color = Color(255, 32, 32)

--globals
NECROSIS.NavigationAreaPaths = area_paths
NECROSIS.NavigationPaths = paths

--local functions
local function debug_execution_blocked(ply)
	--we don't need to localize this command, it's just debug for us developers
	--make sure the player is authorized to run this command
	if not game.SinglePlayer() and ply:IsValid() and not ply:IsListenServerHost() then return true end

	--stop end users from running this command
	if not GetConVar("developer"):GetBool() then
		MsgC(Color(255, 64, 64), "DO NOT RUN THIS COMMAND!\n")

		return true
	end
end

--gamemode
function GM:NavigationGetChecksum()
	local read = file.Read("maps/" .. game.GetMap() .. ".nav", "GAME")

	if read then return tonumber(util.CRC(read)), #read end
end

function GM:NavigationLoad()
	local checksum, navmesh_size = self:NavigationGetChecksum()
	local handle = file.Open("necrosis/navigation/" .. game.GetMap() .. ".dat", "rb", "DATA")

	--make sure the file is readable and up to date
	if not handle then return false end
	if handle:ReadULong() ~= version or handle:ReadULong() ~= checksum or handle:ReadDouble() ~= navmesh_size then return false end

	table.Empty(area_paths)
	table.Empty(paths)

	--read the paths
	for index = 1, handle:ReadULong() do
		local path = {}
		paths[index] = path

		for index = 1, handle:ReadULong() do
			local area_index = handle:ReadULong()
			local area = area_list[area_index]
			--local area_center = area:GetCenter()
			local behavior = handle:ReadByte()

			--TODO: write portal data
			local portal_center = segment.m_portalCenter
			local portal_enumeration = area:ComputeDirection(portal_center)
			local portal_half_width = segment.m_portalHalfWidth
			--local portal_line = area_direction_rights[portal_enumeration] * portal_half_width

			path[index] = {
				area_index,
				behavior,

				--test
				portal_center,
				portal_half_width,
				portal_enumeration,
				--portal_center + portal_line,
				--portal_center - portal_line,
			}
		end
	end

	return true
end

function GM:NavigationSave()
	file.CreateDir("necrosis/navigation")

	local checksum, navmesh_size = self:NavigationGetChecksum()
	local handle = file.Open("necrosis/navigation/" .. game.GetMap() .. ".dat", "wb", "DATA")

	handle:WriteULong(version)
	handle:WriteULong(checksum)
	handle:WriteDouble(navmesh_size)

	--write the paths
	handle:WriteULong(#paths)

	for _, path in ipairs(paths) do
		handle:WriteULong(#path)

		for _, sanitized_segment in ipairs(path) do
			handle:WriteULong(sanitized_segment[1])
			handle:WriteByte(sanitized_segment[2])
		end
	end

	--write areas' path indices
	handle:WriteULong(table.Count(area_paths))

	for area_index, path_index in pairs(area_paths) do
		handle:WriteULong(area_index)
		handle:WriteULong(path_index)
	end
end

function GM:NavigationThink()
	for index, ply in ipairs(self:PlayersPlayingList()) do
		local new_area = navmesh.GetNearestNavArea(ply:GetPos())

		if new_area then
			local last_area_index = ply.NecrosisCurrentNavArea
			local new_area_index = area_list[new_area]

			if last_area_index ~= new_area_index then
				ply.NecrosisCurrentNavArea = new_area
				ply.NecrosisCurrentNavAreaIndex = new_area_index

				if last_area_index then self:NavigationPlayerMoved(ply, last_area_index, new_area_index) end
			end
		end
	end
end

function GM:NecrosisNavigationPlayerMoved(_ply, _last_area, _new_area) end ---For hooking.

function GM:NecrosisNavigationInitialize()
	--LOCALIZE: GM:Log calls
	if not navmesh.IsLoaded() then
		--TODO: generate navmesh
		--we don't attempt to load the navmesh as the PyritionPostNavigationSetup hook is only called after the navmesh has been loaded
		self:Log("navigation", "Failed to load the navmesh.")

		return
	end

	PYRITION:HibernateWake("NecrosisNavigation")
	--print("checksum", checksum, navmesh_size)

	--TODO: load navigation file
	if false then self:Log("navigation", "Navigation file is up to date.")
	else
		self:Log("navigation", "Navigation file is out of date, generating a new one...")

		local generator = ents.Create("necrosis_nb_generator")
		local random_area = navmesh.GetAllNavAreas()[1]
		self.NavigationGenerator = generator

		generator:CallOnRemove("NecrosisNavigation", function() self.NavigationGenerator = nil end)
		generator:SetPos(random_area:GetCenter())
		generator:Spawn()

		--do we actually need this?
		--generator:Activate()
	end
end

function GM:NecrosisNavigationInitialized()
	---Called when the navigation is done being generated.
	PYRITION:Hibernate("NecrosisNavigation")
end

--commands
concommand.Add("necrosis_navigation_reinit", function(ply)
	if debug_execution_blocked(ply) then
	elseif area_list then
		MsgC(color_white, "Re-initializing...\n")
		GAMEMODE:NavigationInitialize()
	else MsgC(color_white, "The navmesh was not loaded in time, thus Pyrition did not generate the area list.\n") end
end, nil, "Re-initializes the vitals components to Necrosis' Nextbot navigation.", debug_command_flags)

concommand.Add("necrosis_navigation_debug_path", function(ply, _command, arguments)
	if debug_execution_blocked(ply) then
	elseif area_list then
		local source_index = ply.NecrosisCurrentNavAreaIndex
		local target_index = tonumber(arguments[1])

		if not target_index then return MsgC(color_white, "Invalid area index.\n")
		elseif target_index == 0 then
			hook.Remove("Think", "NecrosisNavigationDebugPath")

			return MsgC(color_white, "Disabled debug path.\n")
		elseif not area_paths[target_index] then return MsgC(color_white, "Invalid target area index.\n")
		elseif not area_paths[source_index] then return MsgC(color_white, "Could not find your area index\n")
		elseif source_index == target_index then return MsgC(color_white, "You are already at the target area.\n") end

		local start_time = SysTime()

		local source_paths = area_paths[source_index]
		local target_area = area_list[target_index]
		local path = paths[source_paths[target_index]]

		local finish_time = SysTime() - start_time

		if not path then
			if area_list[source_index]:IsConnected(target_area) then MsgC(color_white, "The path is too small to display, as the source index is a neighbor of the target index.\n")
			else MsgC(color_white, "No path from " .. source_index .. " to " .. target_index .. ".\n") end
		else
			MsgC(color_white, "Pathfinding took " .. finish_time .. " seconds.\n")

			local debug_areas = {}
			local debug_path = {[0] = ply:GetPos()}
			local display_time = 1
			local next_display_time = RealTime()
			local actual_display_time = display_time + engine.TickInterval() * 30

			RunConsoleCommand("clear_debug_overlays")

			for index, sanitized_segment in ipairs(path) do
				local area_index = sanitized_segment[1]
				local area = area_list[area_index]
				local corners = {}

				for corner = 0, 3 do table.insert(corners, area:GetCorner(corner)) end

				local bound_minimum, bound_maximum = table.remove(corners):MultiBounds(unpack(corners))
				local bound_size = bound_maximum - bound_minimum

				table.insert(
					debug_path,

					sanitized_segment[3] and Lerp(0.5, sanitized_segment[3], sanitized_segment[4])
					or area:GetClosestPointOnArea(ply:GetPos())
				)

				table.insert(debug_areas, {
					Lerp(0.5, bound_minimum, bound_maximum),
					bound_size * -0.5,
					bound_size * 0.5
				})
			end

			table.insert(debug_path, target_area:GetCenter())

			hook.Add("Think", "NecrosisNavigationDebugPath", function()
				if RealTime() < next_display_time then return end

				next_display_time = RealTime() + display_time

				for index, debug_area in ipairs(debug_areas) do debugoverlay.Box(debug_area[1], debug_area[2], debug_area[3], actual_display_time, debug_navarea_color) end
				for index, position in ipairs(debug_path) do debugoverlay.Line(debug_path[index - 1], position, actual_display_time, debug_path_color, true) end
			end)
		end
	else MsgC(color_white, "The navmesh was not loaded in time, thus Pyrition did not generate the area list.\n") end
end, nil, "Shows the path from the area this command is called from to the specified area. Use 0 as the argument to disable.", debug_command_flags)

--hooks
hook.Add("PyritionPostNavigationSetup", "NecrosisNavigation", function()
	area_list = PYRITION.NavigationAreaList

	GAMEMODE:NavigationInitialize()
end)