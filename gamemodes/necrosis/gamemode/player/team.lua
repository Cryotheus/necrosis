--gamemode functions
function GM:CreateTeams()
	--only really need this one team
	team.SetUp(TEAM_SURVIVOR, "Survivors", color_white, false)

	team.SetClass(TEAM_CONNECTING, "player_connecting")
	team.SetClass(TEAM_SPECTATOR, "player_connecting")
	team.SetClass(TEAM_SURVIVOR, "player_survivor")
	team.SetClass(TEAM_UNASSIGNED, "player_connecting")
end