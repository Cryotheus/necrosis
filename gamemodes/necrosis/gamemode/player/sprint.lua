--gamemode functions
function GM:StartCommand(ply, command)
	local player_class = player_manager.GetPlayerClass(ply)
	local player_class_table = baseclass.Get(player_class)

	--if they don't have maximum stamina in their player table, they're not playing
	if not player_class_table.NecrosisMaximumStamina then return end

	--these could be determined by the player class and stuff
	local maximum_stamina = ply.NecrosisMaximumStamina or player_class_table.NecrosisMaximumStamina
	local sprint_recharge_delay = 1 --seconds until recharge starts
	local stamina_recharge_rate = 1 --how much stamina is recharged per second (after the delay)
end