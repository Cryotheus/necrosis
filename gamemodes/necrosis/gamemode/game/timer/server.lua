--gamemode functions
function GM:GameTimerIncreaseTo(delay) return self:GameTimerSet(math.min(CurTime() + delay, NECROSIS.GameTimer)) end
function GM:GameTimerIncrement(amount) return self:GameTimerSet(math.max(NECROSIS.GameTimer - amount, NECROSIS.GameTimerStart)) end
function GM:GameTimerReduceTo(delay) return self:GameTimerSet(math.min(CurTime() + delay, NECROSIS.GameTimer)) end

function GM:GameTimerSet(target)
	NECROSIS.GameTimer = target

	return target
end

function GM:GameTimerStart(delay)
	if not NECROSIS.GameTimerElapsed then NECROSIS.GameTimerElapsed = NECROSIS.GameTimerStop end

	local cur_time = CurTime()
	NECROSIS.GameTimer = cur_time + delay
	NECROSIS.GameTimerStart = cur_time

	return NECROSIS.GameTimer
end

function GM:GameTimerStop()
	NECROSIS.GameTimer = 0
	NECROSIS.GameTimerElapsed = nil
end

function GM:GameTimerThink() if CurTime() >= NECROSIS.GameTimer then NECROSIS.GameTimerElapsed() end end