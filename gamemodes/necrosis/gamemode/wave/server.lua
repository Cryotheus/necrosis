--locals
local wave_intermission = 10

--gamemode functions
function GM:NecrosisWaveEnd(wave)
	NECROSIS.Wave = wave
	NECROSIS.WaveActive = false
	NECROSIS.WaveType = nil

	self:GameTimerStart(wave_intermission)
	self:PlayerSpawnWaiting()
	self:WaveSync()

	function NECROSIS.GameTimerElapsed() self:WaveStart(wave + 1) end
end

function GM:NecrosisWaveStart(wave)
	NECROSIS.Wave = wave
	NECROSIS.WaveActive = true
	NECROSIS.WaveType = NECROSIS_WAVETYPE_NORMAL

	self:WaveSync()
end

function GM:WaveSync() PYRITION:NetStreamModelQueue("NecrosisWave", true) end