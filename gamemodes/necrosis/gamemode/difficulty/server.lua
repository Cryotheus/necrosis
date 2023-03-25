--gamemode functions
function GM:DifficultyVote(ply, index)
	print(ply, "voted for", index)
end

--commands
concommand.Add("necrosis_vote_difficulty", function(ply, _command, arguments)
	if not ply:IsValid() then return end

	local first = arguments[1]
	local difficulty = GAMEMODE:DifficultyGet(first)

	if not difficulty then difficulty = GAMEMODE:DifficultyGet(tonumber(first)) end
	if not difficulty then return end

	GAMEMODE:DifficultyVote(ply, difficulty.Class)
end)