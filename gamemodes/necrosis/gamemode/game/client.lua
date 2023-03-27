--locals
local last_active = false
local last_target = 0

--gamemode functions
function GM:Think()
	local active = GetGlobal2Bool("NecrosisGameTimerActive")
	local target = GetGlobal2Float("NecrosisGameTimer")

	if active ~= last_active then
		if active then self:GameTimerStart()
		else self:GameTimerStop() end
	end

	if target ~= last_target and target ~= 0 then self:GameTimerSetTarget(target) end
	if active then self:GameTimerThink() end --run the timer think only if we have one

	last_active = active
	last_target = target
end
