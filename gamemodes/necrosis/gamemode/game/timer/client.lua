--gamemode functions
function GM:NecrosisGameTimerStart(_target_time) end ---For hooking.
function GM:NecrosisGameTimerStop() end ---For hooking.

function GM:NecrosisGameTimerUpdated(old, new)
	---Hook for panels to update their timer.
	if old == new then return
	elseif old and not new then self:GameTimerStop()
	elseif not old and new then self:GameTimerStart(new) end
end