SetGlobal2Bool("NecrosisGameTimerActive", false)
SetGlobal2Float("NecrosisGameTimer", 0)

--locals
local start_time = 0
local target_time = 0

--gamemode functions
function GM:GameTimerIncreaseTo(delay) return self:GameTimerSet(math.min(CurTime() + delay, target_time)) end
function GM:GameTimerIncrement(amount) return self:GameTimerSet(math.max(target_time - amount, start_time)) end
function GM:GameTimerReduceTo(delay) return self:GameTimerSet(math.min(CurTime() + delay, target_time)) end

function GM:GameTimerSet(target)
	target_time = target
	
	SetGlobal2Float("NecrosisGameTimer", target_time)

	return target_time
end

function GM:GameTimerStart(delay)
	if not self.NecrosisGameTimerElapsed then self.NecrosisGameTimerElapsed = self.GameTimerStop end

	start_time = CurTime()
	target_time = start_time + delay

	SetGlobal2Bool("NecrosisGameTimerActive", true)
	SetGlobal2Float("NecrosisGameTimer", target_time)
end

function GM:GameTimerStop()
	self.NecrosisGameTimerElapsed = nil

	SetGlobal2Bool("NecrosisGameTimerActive", false)
	SetGlobal2Float("NecrosisGameTimer", 0)
end

function GM:GameTimerThink() if CurTime() >= target_time then self:GameTimerElapsed() end end