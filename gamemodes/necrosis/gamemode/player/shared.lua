--gamemode functions
function GM:PlayerNoClip(ply, desire)
	if ply:NecrosisPlaying() then
		--return false --block noclip for survivors
		return true
	else return desire end --force into noclip
end

function GM:StartCommand(ply, command)
	if ply:NecrosisSpectating() then return end
	
	local player_class = baseclass.Get(player_manager.GetPlayerClass(ply))
	
	self:PlayerKickStartCommand(ply, command, player_class)
	self:PlayerSprintStartCommand(ply, command, player_class)
end