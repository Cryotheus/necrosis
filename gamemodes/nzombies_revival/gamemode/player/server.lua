--gamemode functions
function GM:PlayerInitialSpawn(ply) self:PlayerSpawnAsSpectator(ply) end

function GM:PlayerSpawn(ply, _transition)
	player_manager.OnPlayerSpawn(ply, transiton)
	player_manager.RunClass(ply, "Spawn")
	
	if not transiton then hook.Run("PlayerLoadout", ply) end
	
	hook.Run("PlayerSetModel", ply)
	ply:SetMoveType(ply:Team() == TEAM_SURVIVOR and MOVETYPE_WALK or MOVETYPE_NOCLIP)
end

function GM:PlayerSpawnWave(ply)
	if ply:Team() == TEAM_SPECTATOR then self:PlayerSpawnAsSurvivor() end
end

function GM:ZombiGMPlayerSpawnAsSpectator(ply)
	player_manager.SetPlayerClass(ply, "player_spectator")
	ply:RemoveAllItems()
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spectate(OBS_MODE_ROAMING)
end

function GM:ZombiGMPlayerSpawnAsSurvivor(ply)
	player_manager.SetPlayerClass(ply, "player_survivor")
	ply:UnSpectate()
	ply:SetTeam(TEAM_SURVIVOR)
	ply:Spawn()
end

--commands
concommand.Add("zb_dropin", function(ply)
	if not ply:IsValid() then return end
	
	ZOMBIGM:PlayerSpawnAsSurvivor(ply)
end)