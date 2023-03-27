--gamemode functions
function GM:CreateTeams()
	--LOCALIZE: team names!
	team.SetUp(TEAM_SURVIVOR_EVENT, "Survivors (Event)", color_white, false)
	team.SetUp(TEAM_SURVIVOR, "Survivors", color_white, false)
	team.SetUp(TEAM_WAITING, "Survivors (Wait to spawn)", color_white, false)
	
	team.SetClass(TEAM_CONNECTING, "player_spectator")
	team.SetClass(TEAM_SPECTATOR, "player_spectator")
	team.SetClass(TEAM_SURVIVOR_EVENT, "player_survivor")
	team.SetClass(TEAM_SURVIVOR, "player_survivor")
	team.SetClass(TEAM_UNASSIGNED, "player_spectator")
	team.SetClass(TEAM_WAITING, "player_spectator")
end