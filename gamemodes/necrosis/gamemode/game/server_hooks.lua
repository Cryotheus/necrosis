--gamemode functions
function GM:NecrosisGameDroppedIn(_ply) end --For hooking, called after a player successfully drops in.
function GM:NecrosisGameDroppedOut(_ply) end --For hooking, called after a player successfully drops out.
function GM:NecrosisGameFinished() end --For hooking, called after the game has finished.
function GM:NecrosisGameLost() end --For hooking, called after the game has been lost.
function GM:NecrosisGameStarted() end --For hooking, called after the game has started.
function GM:NecrosisGameWon() end --For hooking, called after the game has been won.