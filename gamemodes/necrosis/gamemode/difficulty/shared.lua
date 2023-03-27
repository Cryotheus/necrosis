--globals
GM.DifficultyList = {}
GM.DifficultyRegistry = {}

--gamemode functions
function GM:DifficultyGet(class_or_index) return self.DifficultyList[class_or_index] end

function GM:NecrosisDifficultyRegistration(registering)
	---This hook is called by NecrosisDifficultyStartRegistration to register the difficulties.
	---Make sure you do not return anything that might stop the hook.
	local difficulty_list = self.DifficultyList

	table.Empty(difficulty_list)

	for class, difficulty_table in pairs(registering) do
		difficulty_table.Class = class

		table.insert(difficulty_list, difficulty_table)
	end

	table.sort(difficulty_list, function(alpha, bravo) return alpha.Rating < bravo.Rating end)

	for index, difficulty_table in ipairs(difficulty_list) do
		difficulty_list[difficulty_table.Class] = difficulty_table
		difficulty_table.Index = index
	end
end

function GM:NecrosisDifficultyStartRegistration()
	---This hook is called before the difficulties are registered.
	local registry = self.DifficultyRegistry

	table.Empty(registry)
	self:DifficultyRegistration(registry)
end

--post
GM:HookMethod("DifficultyRegistration")
GM:HookMethod("DifficultyStartRegistration")