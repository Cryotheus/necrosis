--locals
local MODEL = {
	CopyOptimization = true,
	Priority = 100,
}

--stream functions
function MODEL:InitialSync() return next(NECROSIS.DifficultyVotes) and true end

function MODEL:Read()
	if self:ReadBool() then GAMEMODE:NecrosisGameStart(self:ReadULong())
	else GAMEMODE:NecrosisGameFinish() end
end

function MODEL:Write()
	if NECROSIS.GameActive then
		self:WriteBool(true)
		self:WriteULong(NECROSIS.Difficulty, 32)
	else self:WriteBool(false) end
end

--post
PYRITION:NetStreamModelRegister("NecrosisGame", CLIENT, MODEL)