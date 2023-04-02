--locals
local idle_teams = GM.PlayerTeamsIdle
local playing_teams = GM.PlayerTeamsPlaying

--gamemode functions
function GM:NecrosisPlayerTeamUpdated(ply, old_team, new_team)
	---Called when the player's team is updated.
	---This calls the NecrosisGameDropIn, NecrosisGameDropOut, and NecrosisGameSpectate hooks.
	local was_playing = playing_teams[old_team]

	if not was_playing and new_team == TEAM_WAITING then self:GameDropIn(ply)
	elseif was_playing then
		if idle_teams[new_team] then self:GameDropOut(ply)
		elseif new_team == TEAM_SPECTATOR then self:GameSpectate(ply) end
	end
end

function GM:PlayerTeamThink()
	for index, ply in ipairs(player.GetAll()) do
		local current_team = ply:Team()
		local last_team = ply.NecrosisLastTeam

		if current_team ~= last_team then
			ply.NecrosisLastTeam = current_team

			if last_team then self:PlayerTeamUpdated(ply, last_team, current_team) end
		end
	end
end

--post
GM.Think = GM.PlayerTeamThink --more? only PlayerTeamThink is called on think on client right now