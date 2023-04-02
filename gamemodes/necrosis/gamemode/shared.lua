--gamemode functions
function GM:EntityEmitSound(_data)
	if NECROSIS.GameActive then return end

	return false
end

function GM:SharedInitialize() self:DifficultyStartRegistration() end