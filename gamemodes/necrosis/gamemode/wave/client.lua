--gamemode functions
function GM:NecrosisWaveEnd(_wave)
	---Called when the wave ends.
	--RELEASE: play wave end sound!
end

function GM:NecrosisWaveStart(_wave, _wave_type)
	---Called when the wave starts.
	--RELEASE: play wave start sound!
end

function GM:WaveSync(was_active, _last_wave, _last_wave_type)
	---Calls the NecrosisWaveEnd or NecrosisWaveStart hook.
	local active = NECROSIS.WaveActive
	local wave = NECROSIS.Wave
	local wave_type = NECROSIS.WaveType

	if was_active ~= active then
		if was_active == nil then return end

		if active then self:WaveStart(wave, wave_type)
		else self:WaveEnd(wave, wave_type) end
	end
end