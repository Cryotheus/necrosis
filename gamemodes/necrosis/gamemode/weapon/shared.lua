--gamemode functions
function GM:PreRegisterSWEP(swep, _class)
	--TODO: we need to put weapons into different lists
	--1. wonders
	--2. box drops
	--3. melees
	--4. grenades
	--5. special grenades
	--6. animation (like perk bottle and revive morphine)

	--slots should be as follows
	--0: typical weapons
	--1: melee
	--2: grenade
	--3: special grenade
	--4: animation (like perk bottle and revive morphine)
	--5: objective (like crafting parts)
	if swep.NecrosisIgnore then return end
end