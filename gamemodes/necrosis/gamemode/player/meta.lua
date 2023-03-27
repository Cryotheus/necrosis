--locals
local player_meta = FindMetaTable("Player")

--local tables
local idle_teams = {
	[TEAM_CONNECTING] = true,
	[TEAM_UNASSIGNED] = true,
}

local playing_teams = {
	[TEAM_SURVIVOR] = true,
	[TEAM_SURVIVOR_EVENT] = true,
}

local spectating_teams = {
	[TEAM_CONNECTING] = true,
	[TEAM_SPECTATOR] = true,
	[TEAM_UNASSIGNED] = true,
	[TEAM_WAITING] = true,
}

--player methods
function player_meta:NecrosisDroppingIn() return self:Team() == TEAM_WAITING end ---Spectating, and still waiting to drop in.
function player_meta:NecrosisIdle() return idle_teams[self:Team()] or false end ---Not playing or dropping in.
function player_meta:NecrosisIsSpectator() return self:Team() == TEAM_SPECTATOR end ---Spectating, and not waiting to drop in.
function player_meta:NecrosisPlaying() return playing_teams[self:Team()] end ---Playing, as a survivor.
function player_meta:NecrosisSpectating() return spectating_teams[self:Team()] or false end