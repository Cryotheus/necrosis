SetGlobalBool("NecrosisGameActive", false)

--locals
local first_wave_delay = 10
local start_delay = 45
local start_minimum_delay = 5
local start_progression

--local functions
local function count_ready()
	local count = 0
	local total = 0

	for index, ply in pairs(player.GetAll()) do
		total = total + 1

		if ply:NecrosisDroppingIn() then count = count + 1 end
	end

	return count, total
end

--gamemode functions
function GM:NecrosisGameDropIn(ply)
	---Called when a player attempts to drop in.
	if ply:NecrosisPlaying() then return end
	if GetGlobal2Bool("NecrosisWaveActive") then ply:SetTeam(TEAM_WAITING)
	else self:PlayerSpawnAsSurvivor(ply, true, self.GameEvent and TEAM_SURVIVOR_EVENT) end
	
	self:GameDroppedIn(ply)

	local count, total = count_ready()

	if count == 1 then
		start_progression = 0

		self:GameTimerStart(total == 1 and start_minimum_delay or start_delay)
		
		function self:NecrosisGameTimerElapsed() self:GameStart() end
	else
		start_progression = math.max(start_progression, count / total)

		self:GameTimerReduceTo(math.max((1 - start_progression) * start_delay, start_minimum_delay))
	end
end

function GM:NecrosisGameDropOut(ply)
	---Called when a player attempts to drop out.
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:NecrosisPlaying() then self:PlayerSpawnAsSpectator(ply, true)
	else ply:SetTeam(TEAM_SPECTATOR) end

	self:GameDroppedOut(ply)

	if count_ready() == 0 then
		start_progression = nil

		self:GameTimerStop(start_delay)
	end
end

function GM:NecrosisGameFinish()
	---Called when the game is finished.
	SetGlobalBool("NecrosisGameActive", false)

	self:GameFinished()
end

function GM:NecrosisGameLose()
	---Called when we are about to start the losing sequence.
	self:GameLost()
	self:GameFinish()
end

function GM:NecrosisGameStart()
	---Called to start the game.
	SetGlobalBool("NecrosisGameActive", true)

	function self:NecrosisGameTimerElapsed() self:WaveStart(1) end
	
	self:GameTimerStart(first_wave_delay)
	self:PlayerSpawnWaiting()
	self:GameStarted()
end

function GM:NecrosisGameWin()
	---Called when we are about to start the winning sequence.
	self:GameWon()
	self:GameFinish()
end

function GM:Think()
	--run the timer think only if we have one
	if GetGlobal2Bool("NecrosisGameTimerActive") then self:GameTimerThink() end
end

--commands
concommand.Add("necrosis_dropin", function(ply)
	if not ply:IsValid() then return end

	GAMEMODE:GameDropIn(ply)
end)

concommand.Add("necrosis_dropout", function(ply)
	if not ply:IsValid() then return end

	GAMEMODE:GameDropOut(ply)
end)