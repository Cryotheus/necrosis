--locals
local area_list = PYRITION.NavigationAreaList
local area_paths = NECROSIS.NavigationAreaPaths
local paths = NECROSIS.NavigationPaths

--necrosis functions
function GM:NavigationPathCalculateDistance(source_index, target_index)
	---COST: 1
	local path = self:NavigationPathGet(source_index, target_index)
end

function GM:NavigationPathGet(source_index, target_index)
	---COST: 1
	local targets_pathable = area_paths[source_index]

	if targets_pathable then
		local path_index = targets_pathable[target_index]

		if path_index then return paths[path_index] end
	end
end

--hooks
hook.Add("PyritionPostNavigationSetup", "NecrosisNavigationPath", function() area_list = PYRITION.NavigationAreaList end)