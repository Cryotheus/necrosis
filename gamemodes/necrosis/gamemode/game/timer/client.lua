--gamemode functions
function GM:GameTimerActive() return GetGlobal2Float("NecrosisGameTimer") ~= 0 end ---Returns true if the game timer is active.
function GM:GameTimerThink() end ---Does nothing.

function GM:NecrosisGameTimerStart() end ---For hooking.
function GM:NecrosisGameTimerStop() end ---For hooking.
function GM:NecrosisGameTimerUpdated(_target_time) end ---Hook for panels to update their timer.