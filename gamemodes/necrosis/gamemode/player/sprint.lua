--gamemode functions
function GM:StartCommand(ply, command)
	if ply:NecrosisSpectating() then return end

	local player_class = baseclass.Get(player_manager.GetPlayerClass(ply))
	
	self:PlayerKickStartCommand(ply, player_class, command)

	--if they don't have maximum stamina in their player table, they're not playing
	if not player_class.NecrosisMaximumStamina then return end

	--these could be determined by the player class and stuff
	local maximum_stamina = ply.NecrosisMaximumStamina or player_class.NecrosisMaximumStamina
	local sprint_recharge_delay = 1 --seconds until recharge starts
	local stamina_recharge_rate = 1 --how much stamina is recharged per second (after the delay)
end