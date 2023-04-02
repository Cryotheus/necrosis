--locals
local idle_teams = GM.PlayerTeamsIdle
local player_meta = FindMetaTable("Player")
local playing_teams = GM.PlayerTeamsPlaying
local spectating_teams = GM.PlayerTeamsSpectating

--player methods
function player_meta:NecrosisDroppingIn() return self:Team() == TEAM_WAITING end ---Spectating, and still waiting to drop in.
function player_meta:NecrosisIsIdle() return idle_teams[self:Team()] or false end ---Not playing, dropping in, or a spectator.
function player_meta:NecrosisIsSpectator() return self:Team() == TEAM_SPECTATOR end ---Spectating, and not waiting to drop in.
function player_meta:NecrosisPlaying() return playing_teams[self:Team()] or false end ---Playing, as a survivor.
function player_meta:NecrosisSpectating() return spectating_teams[self:Team()] or false end ---Opposite of `Player:NecrosisPlaying`.

function player_meta:NecrosisSurviving()
	--TODO: implement Player:NecrosisSurviving
	--this should return false if the player is downed and has no hope of reviving themself
	return true
end