--globals
GM.DifficultyVoteCount = {}

--gamemode functions
function GM:DifficultyVote(class_or_index)
	---Runs the internal server command to cast a difficulty vote, and caches the client's choice.
	local difficulty = self:DifficultyGet(class_or_index)

	if difficulty then
		local class = difficulty.Class
		self.DifficultyVoted = class

		RunConsoleCommand("~necrosis_vote_difficulty", difficulty.Index)
	else RunConsoleCommand("~necrosis_vote_difficulty") end
end

function GM:NecrosisDifficultyVoteCountChanged(_vote_counts) print("hook done") end

--commands
concommand.Add("necrosis_cast_difficulty_vote", function(_, _, _, argument_string)
	GAMEMODE:DifficultyVote(tonumber(argument_string) or argument_string)
end, function(_command, arguments_string)
	local argument = string.sub(arguments_string, 2)
	local completions = {}

	for index, difficulty in ipairs(GAMEMODE.DifficultyList) do
		local class = difficulty.Class

		if string.StartWith(class, argument) then table.insert(completions, class) end
	end

	return completions
end, language.GetPhrase("necrosis.commands.necrosis_cast_difficulty_vote"))

--net
net.Receive("NecrosisDifficultyVote", function()
	local gm = GAMEMODE
	local votes = gm.DifficultyVoteCount

	print("vote net")
	--in case difficulties changed
	table.Empty(votes)

	--update the vote counts on client
	for index = 1, #gm.DifficultyList do votes[gm.DifficultyList[index].Class] = net.ReadUInt(PYRITION.NetMaxPlayerBits) end

	--calls the hook
	gm:DifficultyVoteCountChanged(votes)
end)