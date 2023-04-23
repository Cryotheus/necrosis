--locals
local area_list = PYRITION.NavigationAreaList
local area_path_ranges = NECROSIS.NavigationAreaPathRanges
local area_paths = NECROSIS.NavigationAreaPaths
local bot_count
local bot_count_divisor = 128
local bots_progress = NECROSIS.NavigationGeneratorProgress or {}
local generators = NECROSIS.NavigationGenerators or {}
local last_tick
local maximum_bot_think_time
local maximum_think_time = 0.01
local paths = NECROSIS.NavigationPaths
local progress_percentage_interval = 0.1
local progress_time_interval = 5
local valid_area_indices = PYRITION.NavigationAreaIndices

--localized functions
local coroutine_resume = coroutine.resume
local coroutine_status = coroutine.status
local coroutine_yield = coroutine.yield
local SysTime = SysTime

--local tables
local area_direction_rights = {
	[PYRITION_NAV_DIR_EAST] = Vector(-1, 0, 0),
	[PYRITION_NAV_DIR_NORTH] = Vector(0, -1, 0),
	[PYRITION_NAV_DIR_SOUTH] = Vector(1, 0, 0),
	[PYRITION_NAV_DIR_WEST] = Vector(0, 1, 0),
}

local bot_names = {
	--52 names that start with j so we can name the bots (absolutely necessary, remove this and you die)
	"Jack", "Jackson", "Jaclyn", "Jacob",
	"Jacopo", "Jacqueline", "Jaden", "Jadine",
	"Jadyn", "Jae", "Jaeson", "Jagger",
	"James", "Jamiah", "Jamshid", "Janaka",
	"Jaquile", "Jarvis", "Jason", "Jasper",
	"Jaxon", "Jay", "Jayden", "Jean",
	"Jeane", "Jeff", "Jefferson", "Jenson",
	"Jeremie", "Jermaine", "Jeronimo", "Jerrel",
	"Jerry", "Jil", "Jim", "Jimmy",
	"Jody", "Joe", "John", "John",
	"Jojo", "Jon", "Jona", "Jonah",
	"Joseph", "Josh", "Josiah", "Jostein",
	"Juanne", "Jude", "Julian", "Julie"
}

--local functions
local function contains_path(full_path, sub_path, start_index, end_index, sub_offset)
	sub_offset = sub_offset or 0

	--[[print("contains_path", full_path, sub_path, start_index, end_index, sub_offset)

	print("full_path")
	PrintTable(full_path)

	print("sub_path")
	PrintTable(sub_path)]]

	--returns true if full_path contains sub_path from start_index to end_index
	for index = start_index, end_index do
		if full_path[index][1] ~= sub_path[index - start_index + 1 + sub_offset][1] then return false end

		coroutine_yield()
	end

	return true
end

local function get_sub_path(big_path, small_path)
	local big_path_length = #big_path
	local end_index
	local small_path_length = #small_path
	local start_index

	local small_end_area = small_path[small_path_length][1]
	local small_start_area = small_path[1][1]

	--find possible start and end indices for a sub path
	for index = 1, big_path_length do
		local big_area = big_path[index][1]

		if big_area == small_end_area then end_index = index
		elseif big_area == small_start_area then start_index = index end

		coroutine_yield()
	end

	if start_index and end_index then
		--if the start and end index match the small path length and the smaller path is contained by the bigger path
		if end_index - start_index == small_path_length - 1 and contains_path(big_path, small_path, start_index, end_index) then
			--the big path contains the small path!
			return big_path, start_index, end_index
		end

		--we don't contain the path if the size is incorrect or the small path is not an exact match
		--also, just because the start_index area and end_index areas as well as the length match
		--does not necessarily mean the path is the same, as this could be a path that avoids a disabled area
	elseif start_index then
		if contains_path(big_path, small_path, start_index, big_path_length) then
			--extend the big path with the missing parts of the small path
			local overlap = big_path_length - start_index + 1

			for index = overlap, small_path_length do
				table.insert(big_path, small_path[index])
				coroutine_yield()
			end

			return big_path, start_index, #big_path
		end
	elseif end_index then
		--[[big
			1 = 3
			2 = 19
			3 = 634
			4 = 45
			5 = 100
			6 = 642
			7 = 34
			8 = 4
			9 = 103
			10 = 191
			11 = 12
			12 = 7625
			13 = 7619
			14 = 7620
			15 = 22
			16 = 105
			17 = 1580
			18 = 1572
			19 = 1574
			20 = 3819
			21 = 1226
			22 = 6284
			23 = 16
			24 = 7607
			25 = 7605
			26 = 7604
			27 = 369
			28 = 721
			29 = 90
			30 = 543
			31 = 89
			32 = 89
		]]

		--[[small
			1 = 681
			2 = 21
			3 = 7632
			4 = 7631
			5 = 7627
			6 = 66
			7 = 104
			8 = 22
			9 = 105
			10 = 1580
			11 = 1572
			12 = 1574
			13 = 3819
			14 = 1226
			15 = 6284
			16 = 16
			17 = 7607
			18 = 7605
			19 = 7604
			20 = 369
			21 = 721
		]]

		--[[
		local start_check = math.max(end_index - small_path_length + 1, 1)

		if contains_path(
			big_path,
			small_path,
			start_check,
			end_index,
			small_path_length - end_index
		) then end --]]

		local is_sub_path = false

		--[[
			1 2 3 4 5 6 7 8 9 A B
			N N N N Y Y Y Y Y N N

			end_index = 9
			local small_path_start_guess = math.max(end_index - small_path_length + 1, 1) --5

			contains_path(big_path, small_path, math.max(end_index - small_path_length + 1, 1), end_index, end_index - small_path_length)
		]]

		--[[
			1 2 3 4 5 6 7 8 9
			Y Y Y N N N N N N

			end_index = 3
			small_path_length = 5
		]]

		local is_sub_path = true
		local small_path_start_guess = end_index - small_path_length + 1 --= -1
		local offset = small_path_length - end_index --= 2

		--contains_path(big_path, small_path, math.max(small_path_start_guess, 1), end_index, offset)
		for index = math.max(small_path_start_guess, 1), end_index do
			local is = small_path[index + offset]
			local should_be = big_path[index]

			if is[1] ~= should_be[1] then
				is_sub_path = false

				break
			end

			coroutine_yield()
		end

		if is_sub_path then
			--extend the small path with the every thing after the end index we found on the big path
			for index = small_path_length + 1, big_path_length - end_index do
				small_path[index] = big_path[index - small_path_length + end_index]

				coroutine_yield()
			end

			return small_path, 1, small_path_length
		end
	end

	return false
end

local function insert_path(sanitized_path)
	--TODO: test to make sure this actually works
	--attempts to insert a path into the NECROSIS.NavigationPaths table, returning the index of the path
	--if the path already exists, it returns the index of the existing path
	--if we find a path that contains us, we return that path instead
	--if we contain a path, we replace that path with us
	--if the path ends with the start of another path, we merge the two paths

	--returns
	--1: path_index
	--2: start_index of sub path
	--3: end_index of sub path

	local sanitized_length = #sanitized_path

	for path_index, existing_path in ipairs(paths) do
		local existing_length = #existing_path

		if sanitized_length == existing_length then --same length? check if they're the same path
			local is_same = true

			for index, sanitized_segment in ipairs(sanitized_path) do
				if sanitized_segment[1] ~= existing_path[index][1] then
					is_same = false

					break
				end

				coroutine_yield()
			end

			if is_same then return path_index end
		else
			local big_path, small_path = sanitized_path, existing_path

			--swap to make sure big_path contains the bigger path
			if existing_length > sanitized_length then big_path, small_path = small_path, big_path end

			local insertion_path, start_index, end_index = get_sub_path(big_path, small_path)

			if insertion_path then
				paths[path_index] = insertion_path

				return path_index, start_index, end_index
			end
		end

		coroutine_yield()
	end

	--we couldn't find anything given the criteria above, so we're a new path
	return table.insert(paths, sanitized_path)
end

local function sanitize_path(path)
	local distance = 0
	local last_area

	local sanitized_path = {
		Distance = 0, --create table with room for 1 hashmap entry
	}

	for index, segment in ipairs(path:GetDeduplicatedSegments()) do
		local area = segment.area

		table.insert(sanitized_path, {
			area_list[area] --1: area_index
			--the following information should be method of travel and portals
		})

		if last_area then distance = distance + area:GetCenter():Distance(last_area:GetCenter()) end

		coroutine_yield()

		last_area = area
	end

	sanitized_path.Distance = distance

	return sanitized_path
end

--globals
NECROSIS.NavigationGeneratorProgress = bots_progress
NECROSIS.NavigationGenerators = generators

--gamemods functions
function GM:NavigationGeneratorBotFinished(nextbot)
	local generator_count = #generators

	if generator_count == 1 then
		--TODO: gc generator resources here
		if #valid_area_indices <= bot_count_divisor then self:Log("navigation", "Worker " .. nextbot.Name .. " has finished their task.")
		else self:Log("navigation", "Worker " .. nextbot.Name .. " has finished their task last, and will be punished accordingly.") end

		self:NavigationGeneratorFinish()
	else self:Log("navigation", "Worker " .. nextbot.Name .. " has finished their task. (" .. generator_count .. " left)") end
end

function GM:NavigationGeneratorCreateBot(start_index, finish_index)
	local nextbot = ents.Create("necrosis_nb_generator")
	local path = Path("Follow")
	local progress_divisor = finish_index - start_index + 1

	nextbot.FinishIndex = finish_index
	nextbot.StartIndex = start_index

	nextbot:SetAngles(angle_zero)
	nextbot:SetLockPosition(area_list[valid_area_indices[start_index]]:GetCenter())
	nextbot:Spawn()
	path:Invalidate() --path seems to generate empty segments on some linux distros if we don't do this first

	nextbot.GenerateThread = coroutine.create(function()
		for source_iteration_index = start_index, finish_index do
			local source_index = valid_area_indices[source_iteration_index]
			local source_area = area_list[source_index]
			local source_paths = {}
			area_paths = source_paths[source_index]
			nextbot.NeedsNextTick = true
			nextbot.Progress = (source_iteration_index - start_index) / progress_divisor

			nextbot:SetLockPosition(source_area:GetCenter())
			coroutine_yield()

			for target_iteration_index = start_index, finish_index do
				if source_iteration_index ~= target_iteration_index then
					local target_index = valid_area_indices[target_iteration_index]
					local target_area = area_list[target_index]

					if not source_area:IsConnected(target_area) then
						path:Compute(nextbot, target_area:GetCenter())

						if path:IsValid() then
							source_paths[target_index] = insert_path(sanitize_path(path))
						end

						path:Invalidate()
					end

					nextbot.Progress = (
							source_iteration_index
							- start_index
							+ (target_iteration_index - start_index)
							/ progress_divisor
						) / progress_divisor

					coroutine_yield()
				end
			end
		end

		nextbot.Progress = 1
	end)

	return nextbot
end

function GM:NavigationGeneratorFinish()
	--LOCALIZE: GM:Log calls
	self:Log("navigation", "Finished.")
end

function GM:NavigationGeneratorFinished()
	--LOCALIZE: GM:Log calls
	self:Log("navigation", "Finished generating navigation map.")
end

function GM:NavigationGeneratorFirstThink()
	local progress = 0

	for index, bot_progress in ipairs(bots_progress) do progress = bot_progress + progress end

	progress = progress / bot_count

	if progress > next_progress_percentage or RealTime() > next_progress_time then
		next_progress_time = RealTime() + progress_time_interval
		next_progress_percentage = progress + progress_percentage_interval

		--LOCALIZE: progress logging shenanigans
		GAMEMODE:Log("navigation", "Setting up navigation, " .. math.floor(progress * 10000) / 100 .. "% complete.")
	end

	last_tick = engine.TickCount()
	maximum_bot_think_time = maximum_think_time / #generators --give the remaining bots more time when some finished early
end

function GM:NavigationGeneratorStart()
	--these get updated right before this function is called
	area_list = PYRITION.NavigationAreaList
	valid_area_indices = PYRITION.NavigationAreaIndices

	local area_count = #valid_area_indices
	local last_index = 0
	local timer_index = 1
	bot_count = math.max(math.ceil(area_count / bot_count_divisor), 1)
	last_tick = -1
	next_progress_percentage = 0
	next_progress_time = 0

	table.Empty(bots_progress)

	--remove the old bots
	for index = 1, bot_count do bots_progress[index] = 0 end
	for index, nextbot in ipairs(generators) do nextbot.Done = true end

	self:Log("navigation", "Generating navigation map with " .. bot_count .. " workers.")
	table.Shuffle(bot_names)

	--bot_names
	timer.Create("NecrosisNavigationGenerator", 0, bot_count, function()
		local fraction = timer_index / bot_count
		local maximum_index = math.Round(area_count * fraction)
		local nextbot = self:NavigationGeneratorCreateBot(last_index + 1, maximum_index)

		nextbot.Name = bot_names[timer_index % #bot_names + 1]
		nextbot.SpawnIndex = timer_index

		last_index = maximum_index
		timer_index = timer_index + 1
	end)
end

function GM:NavigationGeneratorThink(nextbot)
	if last_tick ~= engine.TickCount() then self:NavigationGeneratorFirstThink() end

	local budget = SysTime() + maximum_bot_think_time
	local thread = nextbot.GenerateThread

	repeat
		local ok, message = coroutine_resume(thread, nextbot)
		bots_progress[nextbot.SpawnIndex] = nextbot.Progress

		if ok then
			if coroutine_status(thread) == "dead" then
				nextbot.Done = true

				self:NavigationGeneratorBotFinished(nextbot)

				break
			elseif nextbot.NeedsNextTick then break end
		else
			nextbot.Done = true

			ErrorNoHalt("GM:NavigationGeneratorThink thread erred: " .. message .. "\n")
			self:NavigationGeneratorBotFinished(nextbot)

			break
		end
	until SysTime() > budget
end