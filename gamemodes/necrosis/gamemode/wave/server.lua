--locals
local wave_intermission = 10

--gamemode functions
function GM:NecrosisWaveEnd(wave)
	NECROSIS.Wave = wave
	NECROSIS.WaveActive = false
	NECROSIS.WaveType = nil

	self:PlayerSpawnWaiting()
	self:WaveSync()

	self:GameTimerStart(wave_intermission)
end

function GM:NecrosisWaveStart(wave)
	NECROSIS.Wave = wave
	NECROSIS.WaveActive = true
	NECROSIS.WaveType = NECROSIS_WAVETYPE_NORMAL

	self:WaveSync()
end

function GM:WaveSync() PYRITION:NetStreamModelQueue("NecrosisWave", true) end