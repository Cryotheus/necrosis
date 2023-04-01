--locals
local MODEL = {
	CopyOptimization = true,
	Priority = 50,
}

--stream functions
function MODEL:InitialSync() return NECROSIS.GameActive end

function MODEL:Read()
	local last_wave = NECROSIS.Wave
	local last_wave_type = NECROSIS.WaveType
	local was_active = NECROSIS.WaveActive
	NECROSIS.Wave = self:ReadULong(32)

	if self:ReadBool() then
		NECROSIS.WaveActive = true
		NECROSIS.WaveType = self:ReadByte()
	else
		NECROSIS.WaveActive = false
		NECROSIS.WaveType = nil
	end

	GAMEMODE:WaveSync(was_active, last_wave, last_wave_type)
end

function MODEL:Write()
	self:WriteULong(NECROSIS.Wave, 32)

	if NECROSIS.WaveActive then
		self:WriteBool(true)
		self:WriteByte(NECROSIS.WaveType)
	else self:WriteBool(false) end
end

--post
PYRITION:NetStreamModelRegister("NecrosisWave", CLIENT, MODEL)