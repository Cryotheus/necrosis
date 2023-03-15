--globals
TEAM_SURVIVOR = 1

--don't maintain values, but maintain reference!
if NECROSIS then table.Empty(NECROSIS)
else NECROSIS = {} end