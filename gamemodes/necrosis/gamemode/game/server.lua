util.AddNetworkString("NecrosisGame")

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
function GM:GameCheckLoss()
	---INTERNAL
	---Initiate a game over if there are no survivors left.
	for index, ply in ipairs(player.GetAll()) do
		--we'll likely do more checks here in the future
		if ply:NecrosisPlaying() then return end
	end

	self:GameLose()
end

function GM:GameSync() PYRITION:NetStreamModelQueue("NecrosisGame", true) end

function GM:NecrosisGameDropIn(ply)
	---Called when a player attempts to drop in.
	if ply:NecrosisPlaying() then return end
	if NECROSIS.WaveActive or not NECROSIS.GameActive then ply:SetTeam(TEAM_WAITING)
	else self:PlayerSpawnAsSurvivor(ply, true, self.GameEvent and TEAM_SURVIVOR_EVENT) end

	self:GameDroppedIn(ply)

	if NECROSIS.WaveActive then return end

	local count, total = count_ready()

	if count == 1 then
		start_progression = 0

		self:GameTimerStart(total == 1 and start_minimum_delay or start_delay)

		function NECROSIS.GameTimerElapsed() GAMEMODE:GameStart() end
	else
		start_progression = math.max(start_progression or 0, count / total)

		self:GameTimerReduceTo(math.max((1 - start_progression) * start_delay, start_minimum_delay))
	end
end

function GM:NecrosisGameDropOut(ply)
	---Called when a player attempts to drop out.
	if ply:Team() == TEAM_SPECTATOR then return end
	if ply:NecrosisPlaying() then self:PlayerSpawnAsSpectator(ply, true)
	else ply:SetTeam(TEAM_SPECTATOR) end

	self:GameDroppedOut(ply)

	if NECROSIS.WaveActive then self:GameCheckLoss()
	elseif count_ready() == 0 then
		start_progression = nil

		self:GameTimerStop(start_delay)
	end
end

function GM:NecrosisGameFinish()
	---Called when the game is finished.
	NECROSIS.GameActive = false

	self:GameFinished()
	self:GameSync()
end

function GM:NecrosisGameLose()
	---Called when we are about to start the losing sequence.
	self:GameLost()
	self:GameFinish()
end

function GM:NecrosisGameStart()
	---Called to start the game.
	NECROSIS.GameActive = true

	self:DifficultyEvaluateVotes()
	self:GameStarted()
	self:GameSync()
	self:GameTimerStart(first_wave_delay)
	self:PlayerSpawnWaiting()
end

function GM:NecrosisGameWin()
	---Called when we are about to start the winning sequence.
	self:GameWon()
	self:GameFinish()
end

function GM:Think()
	--run the timer think only if we have one
	if NECROSIS.GameTimer then self:GameTimerThink() end
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