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

--globals
GM.PlayerTeamsIdle = idle_teams
GM.PlayerTeamsPlaying = playing_teams
GM.PlayerTeamsSpectating = spectating_teams

--gamemode functions
function GM:CreateTeams()
	--LOCALIZE: team names!
	team.SetUp(TEAM_SURVIVOR_EVENT, "Survivors (Event)", color_white, false)
	team.SetUp(TEAM_SURVIVOR, "Survivors", color_white, false)
	team.SetUp(TEAM_WAITING, "Survivors (Wait to spawn)", color_white, false)

	for team_index in pairs(playing_teams) do team.SetClass(team_index, "player_survivor") end
	for team_index in pairs(spectating_teams) do team.SetClass(team_index, "player_spectator") end
end