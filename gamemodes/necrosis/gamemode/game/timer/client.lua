--gamemode functions
function GM:GameTimerThink() end ---Does nothing.

function GM:NecrosisGameTimerStart() end ---For hooking.
function GM:NecrosisGameTimerStop() end ---For hooking.

function GM:NecrosisGameTimerUpdated(target_time)
	---Updates any panels that display this timer.
	print("new timer target", target_time)
end