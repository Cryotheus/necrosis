--gamemode functions
function GM:NecrosisGameFinish()
	NECROSIS.Difficulty = nil
	NECROSIS.GameActive = false
end

function GM:NecrosisGameStart(difficulty_index)
	NECROSIS.Difficulty = difficulty_index
	NECROSIS.GameActive = true
end