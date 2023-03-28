--gamemode functions
function GM:PreRegisterSWEP(swep, class)
	if swep.NecrosisIgnore then return end
	
	print("PreRegisterSWEP", swep, class)
end