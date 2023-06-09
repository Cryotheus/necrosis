--globals
NECROSIS.DifficultyPlayerVotes = NECROSIS.DifficultyPlayerVotes or {}
NECROSIS.DifficultyVotes = NECROSIS.DifficultyVotes or {}

--gamemode functions
function GM:DifficultyEvaluateVotes()
	local difficulty_votes = NECROSIS.DifficultyVotes
	local record = "normal" --default difficulty
	local record_votes = 0

	for index, difficulty in ipairs(GAMEMODE.DifficultyList) do
		local class = difficulty.Class
		local votes = difficulty_votes[class]

		if votes then
			difficulty_votes[class] = nil
			votes = #votes
			
			if votes > record_votes then
				record = difficulty.Class
				record_votes = votes
			end
		end
	end

	NECROSIS.Difficulty = self.DifficultyList[record].Index

	--in case players voted for difficulties that no longer exist (e.g. reloaded gamemode with different difficulties)
	table.Empty(NECROSIS.DifficultyPlayerVotes)
	table.Empty(difficulty_votes)
end

function GM:DifficultyReset()
	NECROSIS.Difficulty = nil

	self:DifficultySync()
end

function GM:DifficultySyncVotes() PYRITION:NetStreamModelQueue("NecrosisDifficultyVote", true) end ---Writes and syncs the votes on the next tick.

function GM:DifficultyVote(ply, class)
	--remove existing vote
	local player_vote = NECROSIS.DifficultyPlayerVotes[ply]
	NECROSIS.DifficultyPlayerVotes[ply] = class

	if player_vote then duplex.Remove(NECROSIS.DifficultyVotes[player_vote], ply) end

	--register new vote
	if class then
		local current_votes = NECROSIS.DifficultyVotes[class]

		if current_votes then duplex.Insert(current_votes, ply)
		else NECROSIS.DifficultyVotes[class] = {ply, [ply] = 1} end
	end

	self:DifficultySyncVotes()
end

--commands
concommand.Add("~necrosis_vote_difficulty", function(ply, _command, arguments)
	if NECROSIS.Difficulty then return end
	if not ply:IsValid() then return end

	local difficulty = GAMEMODE:DifficultyGet(tonumber(arguments[1]))

	GAMEMODE:DifficultyVote(ply, difficulty and difficulty.Class)
end, nil, language.GetPhrase("necrosis.internal_command"), FCVAR_UNREGISTERED)