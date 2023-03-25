--locals
local DIFFICULTY = {
	Icon = "emoticon-happy-outline",
	Rating = 180,
}

--difficulty functions

--hooks
hook.Add("NecrosisDifficultyRegistration", "NecrosisDifficultiesEasy", function(registry) registry.easy = DIFFICULTY end)