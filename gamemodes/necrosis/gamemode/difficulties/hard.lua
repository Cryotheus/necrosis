--locals
local DIFFICULTY = {
	Icon = "emoticon-angry-outline",
	Rating = 800,
}

--difficulty functions

--hooks
hook.Add("NecrosisDifficultyRegistration", "NecrosisDifficultiesHard", function(registry) registry.hard = DIFFICULTY end)