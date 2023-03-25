--locals
local DIFFICULTY = {
	Icon = "skull-outline",
	Rating = 1000,
}

--difficulty functions

--hooks
hook.Add("NecrosisDifficultyRegistration", "NecrosisDifficultiesNightmare", function(registry) registry.nightmare = DIFFICULTY end)