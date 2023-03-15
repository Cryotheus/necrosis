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

function GM:PlayerUse(ply, _entity) return ply:Team() == TEAM_SURVIVOR end

function GM:ZombiGMPlayerSpawnAsSpectator(ply, respawn)
	player_manager.SetPlayerClass(ply, "player_spectator")
	ply:RemoveAllItems()
	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spectate(OBS_MODE_ROAMING)
	
	if respawn then ply:Spawn() end
end

function GM:ZombiGMPlayerSpawnAsSurvivor(ply, respawn)
	player_manager.SetPlayerClass(ply, "player_survivor")
	ply:UnSpectate()
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	ply:SetTeam(TEAM_SURVIVOR)
	
	if respawn then ply:Spawn() end
end

--commands
concommand.Add("zb_dropin", function(ply)
	if not ply:IsValid() then return end
	
	ZOMBIGM:PlayerSpawnAsSurvivor(ply, true)
end)

concommand.Add("zb_spectate", function(ply)
	if not ply:IsValid() then return end
	
	ZOMBIGM:PlayerSpawnAsSpectator(ply, true)
end)