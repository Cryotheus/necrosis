--globals
NECROSIS = NECROSIS or {
	DifficultyVoteCount = {}
}

NECROSIS_WAVETYPE_NORMAL = 0 --typical zombie round
NECROSIS_WAVETYPE_HOUND = 1 --hounds only
NECROSIS_WAVETYPE_BOSS = 2 --boss round, target boss must be killed before the wave can end
NECROSIS_WAVETYPE_SURVIVE = 3 --survive a set amount of time, then kill all the remaining zombies

TEAM_SURVIVOR = 1
TEAM_SURVIVOR_EVENT = 2 --used for changing player collisions quickly
TEAM_WAITING = 3 --dropping in

--post
setmetatable(NECROSIS, {__index = GM})