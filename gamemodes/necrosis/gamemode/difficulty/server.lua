SetGlobal2Int("NecrosisDifficulty", 0)
util.AddNetworkString("NecrosisDifficultyVote")

--globals
GM.DifficultyPlayerVotes = {}
GM.DifficultyVotes = {}

--gamemode functions
function GM:DifficultyEvaluateVotes()
	local record = "normal"
	local record_votes = 0
	local votes_table = self.DifficultyVotes

	for index, difficulty in ipairs(self.DifficultyList) do
		local class = difficulty.Class
		local votes = votes_table[class]
		votes_table[class] = nil

		if votes > record_votes then
			record = class
			record_votes = votes
		end
	end

	table.Empty(self.DifficultyPlayerVotes)
	self:DifficultySet(record)
end

function GM:DifficultyQueueUpdate()
	if self.DifficultyUpdateQueued then return end

	self.DifficultyUpdateQueued = true

	timer.Simple(0, function()
		self.DifficultyUpdateQueued = nil

		net.Start("NecrosisDifficultyVote")

		for index, difficulty in ipairs(self.DifficultyList) do
			local votes = self.DifficultyVotes[difficulty.Class]

			net.WriteUInt(votes and #votes or 0, PYRITION.NetMaxPlayerBits)
		end

		net.Broadcast()
	end)
end

function GM:DifficultyReset()
	self.DifficultyActive = nil

	SetGlobal2Int("NecrosisDifficulty", 0)
end

function GM:DifficultySet(class)
	local difficulty = GAMEMODE:DifficultyGet(class)
	self.DifficultyActive = class

	SetGlobal2Int("NecrosisDifficulty", difficulty.Index)
end

function GM:DifficultyVote(ply, class)
	--remove existing vote
	local player_vote = self.DifficultyPlayerVotes[ply]
	self.DifficultyPlayerVotes[ply] = class
	
	if player_vote then duplex.Remove(self.DifficultyVotes[player_vote], ply) end
	
	--register new vote
	if class then
		local current_votes = self.DifficultyVotes[class]

		if current_votes then duplex.Insert(current_votes, ply)
		else self.DifficultyVotes[class] = {ply, [ply] = 1} end
	end

	self:DifficultyQueueUpdate()
end

--commands
concommand.Add("~necrosis_vote_difficulty", function(ply, _command, arguments)
	if GAMEMODE.DifficultyActive then return end
	if not ply:IsValid() then return end

	local difficulty = GAMEMODE:DifficultyGet(tonumber(arguments[1]))

	GAMEMODE:DifficultyVote(ply, difficulty and difficulty.Class)
end, nil, language.GetPhrase("necrosis.internal_command"))

--hooks
hook.Add("PyritionNetPlayerInitialized", "NecrosisDifficulty", function(ply)
	net.Start("NecrosisDifficultyVote")

	for index, difficulty in ipairs(GAMEMODE.DifficultyList) do
		local votes = GAMEMODE.DifficultyVotes[difficulty.Class]

		net.WriteUInt(votes and #votes or 0, PYRITION.NetMaxPlayerBits)
	end

	net.Send(ply)
end)