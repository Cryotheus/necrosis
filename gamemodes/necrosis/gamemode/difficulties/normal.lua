--locals
local DIFFICULTY = {
	Icon = "emoticon-neutral-outline",
	Rating = 500,
}

--difficulty functions

--hooks
hook.Add("NecrosisDifficultyRegistration", "NecrosisDifficultiesNormal", function(registry) registry.normal = DIFFICULTY end)