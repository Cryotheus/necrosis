--gamemode functions
function GM:NecrosisGameDropIn(_ply) end
function GM:NecrosisGameDropOut(_ply) end

function GM:NecrosisGameFinish()
	NECROSIS.Difficulty = nil
	NECROSIS.GameActive = false
end

function GM:NecrosisGamePlaying(ply) if ply == LocalPlayer() then self:UIMainMenuClose() end end
function GM:NecrosisGameSpectate(_ply) end

function GM:NecrosisGameStart(difficulty_index)
	NECROSIS.Difficulty = difficulty_index
	NECROSIS.GameActive = true
end