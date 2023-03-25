--locals
local player_meta = FindMetaTable("Player")

--player methods
function player_meta:NecrosisPlaying()
	local ply_team = self:Team()

	return ply_team < 100 and ply_team > 0
end

function player_meta:NecrosisDroppingIn() return self:Team() == TEAM_SPECTATOR end