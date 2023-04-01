--locals
local maximum_player_bits = PYRITION.NetMaxPlayerBits
local MODEL = {CopyOptimization = true, Priority = 50}

--stream functions
function MODEL:InitialSync() return NECROSIS.GameActive end

function MODEL:Read()
	local difficulty_list = GAMEMODE.DifficultyList
	local votes = NECROSIS.DifficultyVoteCount

	--in case difficulties changed
	table.Empty(votes)

	--update the vote counts on client
	for index = 1, #difficulty_list do votes[difficulty_list[index].Class] = self:ReadUInt(maximum_player_bits) end

	--calls the hook
	GAMEMODE:DifficultyVoteCountChanged(votes)
end

function MODEL:Write()
	local difficulty_votes = NECROSIS.DifficultyVotes

	for index, difficulty in ipairs(GAMEMODE.DifficultyList) do
		local votes = difficulty_votes[difficulty.Class]

		self:WriteUInt(votes and #votes or 0, maximum_player_bits)
	end
end

--post
PYRITION:NetStreamModelRegister("NecrosisDifficultyVote", CLIENT, MODEL)