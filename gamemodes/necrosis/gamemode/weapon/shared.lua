--gamemode functions
function GM:PreRegisterSWEP(swep, _class)
	--slots should be as follows
	--0: typical weapons
	--1: grenade
	--2: special grenade
	--3: animation (like perk bottle and revive morphine)
	--4: objective (like crafting parts)
	if swep.NecrosisIgnore then return end

	swep.Slot = 0
	swep.SlotPos = 10
end