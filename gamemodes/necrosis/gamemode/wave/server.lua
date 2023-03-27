util.AddNetworkString("NecrosisWave")

--gamemode functions
function GM:NecrosisWaveStart(wave)
	self.Wave = wave
	self.WaveActive = true

	net.Start("NecrosisWave")
	net.WriteBool(true)
	net.WriteUInt(0, 8) --wave type
	net.WriteUInt(wave, 32) --you know some nerd is going to try reaching wave 2147483647
	net.Broadcast()
end

function GM:NecrosisWaveEnd(wave)
	self.Wave = wave
	self.WaveActive = false

	self:PlayerSpawnWaiting()

	net.Start("NecrosisWave")
	net.WriteBool(false)
	net.WriteUInt(wave, 32)
	net.Broadcast()
end

--hooks
hook.Add("NetPlayerInitialized", "NecrosisWave", function(ply)
	if GetGlobal2Bool("NecrosisGameActive") then
		net.Start("NecrosisWave")
		
		if GAMEMODE.WaveActive then
			net.WriteBool(true)
			net.WriteUInt(0, 8) --wave type
		else net.WriteBool(false) end
		
		net.WriteUInt(wave, 32)
		net.Send(ply)
	end
end)