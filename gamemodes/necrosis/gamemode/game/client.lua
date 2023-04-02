--gamemode functions
function GM:NecrosisGameDropIn(ply) print(ply, "NecrosisGameDropIn") end
function GM:NecrosisGameDropOut(ply) print(ply, "NecrosisGameDropOut") end

function GM:NecrosisGameFinish()
	NECROSIS.Difficulty = nil
	NECROSIS.GameActive = false
end

function GM:NecrosisGameSpectate(ply) print(ply, "NecrosisGameSpectate") end

function GM:NecrosisGameStart(difficulty_index)
	NECROSIS.Difficulty = difficulty_index
	NECROSIS.GameActive = true
end