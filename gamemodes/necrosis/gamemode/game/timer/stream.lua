--locals
local MODEL = {
	CopyOptimization = true,
	Priority = 90,
}

--stream functions
function MODEL:InitialSync() return NECROSIS.GameTimer and true end

function MODEL:Read()
	local old = NECROSIS.GameTimer

	if self:ReadBool() then NECROSIS.GameTimer = self:ReadFloat()
	else NECROSIS.GameTimer = nil end

	GAMEMODE:GameTimerUpdated(old, NECROSIS.GameTimer)
end

function MODEL:Write()
	if NECROSIS.GameTimer then
		self:WriteBool(true)
		self:WriteFloat(NECROSIS.GameTimer)
	else self:WriteBool(false) end
end

--post
PYRITION:NetStreamModelRegister("NecrosisGameTimer", CLIENT, MODEL)