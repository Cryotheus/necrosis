--locals
local area_list = PYRITION.NavigationAreaList

--gamemode
function GM:NavigationGetChecksum()
	local read = file.Read("maps/" .. game.GetMap() .. ".nav", "GAME")

	if read then return tonumber(util.CRC(read)), #read end
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

	local checksum, navmesh_size = self:NavigationGetChecksum()

	--print("checksum", checksum, navmesh_size)

	--TODO: load navigation file
	if false then self:Log("navigation", "Navigation file is up to date.")
	else
		self:Log("navigation", "Navigation file is out of date, generating a new one...")

		local generator = ents.Create("necrosis_nb_generator")
		local random_area = navmesh.GetAllNavAreas()[1]

		generator:SetPos(random_area:GetCenter())
		generator:Spawn()
		generator:Activate()

		--print("generator", generator)
	end
end

function GM:NecrosisNavigationInitialized() print("navigation done bro") end ---Called immediately after NecrosisNavigationInitialize has been called. 

--hooks
hook.Add("PyritionPostNavigationSetup", "NecrosisNavigation", function()
	area_list = PYRITION.NavigationAreaList

	GAMEMODE:NavigationInitialize()
end)