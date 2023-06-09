--locals
local downed_players = NECROSIS.PlayerListDowned or {}
local not_playing_players = NECROSIS.PlayerListNotPlaying or {}
local playing_players = NECROSIS.PlayerListPlaying or {}
local spectating_players = NECROSIS.PlayerListSpectating or {}
local targettable_players = NECROSIS.PlayerListTargettable or {}

--globals
NECROSIS.PlayerListDowned = downed_players
NECROSIS.PlayerListNotPlaying = not_playing_players
NECROSIS.PlayerListPlaying = playing_players
NECROSIS.PlayerListSpectating = spectating_players
NECROSIS.PlayerListTargettable = targettable_players
NECROSIS.PlayerRagdolls = NECROSIS.PlayerRagdolls or {}

--mirror
GM.PlayerListDowned = downed_players
GM.PlayerListNotPlaying = not_playing_players
GM.PlayerListPlaying = playing_players
GM.PlayerListSpectating = spectating_players
GM.PlayerListTargettable = targettable_players

--local functions
local function empty_list(victim) for index = 1, #victim do victim[index] = nil end end --it's like table.Empty but for sequential tables only

--gamemode functions
function GM:DoPlayerDeath(ply, _attacker, _damage_info)
	--ply:CreateRagdoll()
	ply:AddDeaths(1)

	local ragdoll = ents.Create("prop_ragdoll")

	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetSkin(ply:GetSkin())
	ragdoll:SetVelocity(ply:GetVelocity())
	ragdoll:Spawn()
	ragdoll:Activate()

	ragdoll:SetNWEntity("NecrosisOwner", ply)
end

function GM:NecrosisPlayerSpawnAsSpectator(ply, respawn, team_index)
	player_manager.SetPlayerClass(ply, "player_spectator")
	ply:RemoveAllItems()
	ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ply:SetTeam(team_index or TEAM_SPECTATOR)
	ply:Spectate(OBS_MODE_ROAMING)

	if respawn then ply:Spawn() end
end

function GM:NecrosisPlayerSpawnAsSurvivor(ply, respawn, team_index)
	player_manager.SetPlayerClass(ply, "player_survivor")
	ply:UnSpectate()
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	ply:SetTeam(team_index or TEAM_SURVIVOR)

	if respawn then ply:Spawn() end
end

function GM:NecrosisPlayerSpawnWaiting()
	---Spawns in all players who are dropping in.
	for index, ply in ipairs(player.GetAll()) do
		--spawn in only the players who want to
		if ply:NecrosisDroppingIn() then self:PlayerSpawnAsSurvivor(ply, true) end
	end
end

function GM:PlayerDeath(ply, inflictor, attacker)
	--this is the same as the base gamemode but without the unnecessary stuff
	if IsValid(attacker) and attacker:GetClass() == "trigger_hurt" then attacker = ply end
	if IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver()) then attacker = attacker:GetDriver() end
	if not IsValid(inflictor) and IsValid(attacker) then inflictor = attacker end

	--convert the inflictor to the weapon that they're holding if we can
	--this can be right or wrong with NPCs since combine can be holding a pistol but kill you by hitting you with their arm
	if IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
		inflictor = inflictor:GetActiveWeapon()

		if not IsValid(inflictor) then inflictor = attacker end
	end

	player_manager.RunClass(ply, "Death", inflictor, attacker)

	if attacker == ply then
		net.Start("PlayerKilledSelf")
		net.WriteEntity(ply)
		net.Broadcast() --MsgAll(attacker:Nick() .. " suicided!\n")

		return
	end

	if attacker:IsPlayer() then
		net.Start("PlayerKilledByPlayer")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetClass())
		net.WriteEntity(attacker)
		net.Broadcast() --MsgAll(attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n")

		return
	end

	net.Start("PlayerKilled")
	net.WriteEntity(ply)
	net.WriteString(inflictor:GetClass())
	net.WriteString(attacker:GetClass())
	net.Broadcast() --MsgAll(ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n")
end

function GM:PlayerDeathThink(ply)
	self:PlayerSpawnAsSpectator(ply, true, TEAM_WAITING)

	local ply_pos = ply:GetPos()
	local record
	local record_distance = math.huge

	for index, ply in ipairs(self.PlayerListPlaying) do
		local distance = ply:GetPos():Distance(ply_pos)

		if distance < record_distance then
			record = ply
			record_distance = distance
		end
	end

	if record then
		ply:SpectateEntity(record)
		ply:Spectate(OBS_MODE_CHASE)
	end
end

function GM:PlayerDisconnected(_ply) self:PlayerUpdateLists() end

function GM:PlayerInitialSpawn(ply)
	self:PlayerSpawnAsSpectator(ply, false, TEAM_UNASSIGNED)
	self:PlayerUpdateLists()
end

function GM:PlayerSpawn(ply, _transition)
	ply.NecrosisCurrentNavArea = nil
	ply.NecrosisCurrentNavAreaIndex = nil
	ply.NecrosisMaximumStamina = 4

	player_manager.OnPlayerSpawn(ply, transiton)
	player_manager.RunClass(ply, "Spawn")

	ply.NecrosisStamina = ply.NecrosisMaximumStamina

	if not transiton then hook.Run("PlayerLoadout", ply) end

	hook.Run("PlayerSetModel", ply)
	ply:SetMoveType(ply:NecrosisPlaying() and MOVETYPE_WALK or MOVETYPE_NOCLIP)
end

function GM:PlayerUpdateLists()
	empty_list(playing_players)

	for index, ply in pairs(player.GetAll()) do
		if ply:NecrosisPlaying() then
			table.insert(playing_players, ply)

			if ply:NecrosisDowned() then table.insert(downed_players, ply)
			else table.insert(targettable_players, ply) end
		else
			table.insert(not_playing_players, ply)
			
			if ply:NecrosisIsSpectator() then table.insert(spectating_players, ply) end
		end
	end
end

function GM:PlayerUse(ply, _entity) return ply:NecrosisPlaying() end