--gamemode functions
function GM:PreRegisterSWEP(swep, _class)
	--TODO: we need to put weapons into different lists
	--1. wonders
	--2. box drops
	--3. melees
	--4. grenades
	--5. special grenades
	--6. animated
	--7. collectables
	if swep.NecrosisIgnore then return end
end