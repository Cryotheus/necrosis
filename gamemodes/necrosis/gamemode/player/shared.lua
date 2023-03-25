--gamemode functions
function GM:PlayerNoClip(ply, desire)
	if ply:NecrosisPlaying() then
		--return false --block noclip for survivors
		return true
	else return desire end --force into noclip
end