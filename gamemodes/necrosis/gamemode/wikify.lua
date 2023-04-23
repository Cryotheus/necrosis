--locals
local collect_functions = PYRITION._WikifyCollectFunctions

--gamemode functions
function GM:Wikify()
	local default_pattern = "necrosis/.+%.lua"
	local default_source_url = "https://github.com/Cryotheus/necrosis/blob/master/"

	file.CreateDir("pyrition/wikify/pages")

	PYRITION:WikifyCollectHooks(self, "Necrosis", {
		Category = PYRITION_WIKIFY_HOOKS,
		Name = "necrosis_gamemode_hooks",
		Owner = "Necrosis",
		Parent = "GM (Necrosis)",
		SourcePattern = default_pattern,
		SourceURL = default_source_url,
	}, {
		Category = PYRITION_WIKIFY_GLOBALS,
		Name = "necrosis_gamemode",
		Owner = "Necrosis",
		Parent = "GM (Necrosis)",
		SourcePattern = default_pattern,
		SourceURL = default_source_url,
	})

	if CLIENT then
		PYRITION:WikifyCollectFunctions(collect_functions(FindMetaTable("Panel"), {
			Category = PYRITION_WIKIFY_CLASSES,
			Name = "necrosis_class_panel",
			Owner = "Necrosis",
			Parent = "Panel",
			SourcePattern = default_pattern,
			SourceURL = default_source_url,
		}))
	end

	PYRITION:WikifyCollectFunctions(collect_functions(FindMetaTable("Player"), {
		Category = PYRITION_WIKIFY_CLASSES,
		Name = "necrosis_class_player",
		Owner = "Necrosis",
		Parent = "Player",
		SourcePattern = default_pattern,
		SourceURL = default_source_url,
	}))

	PYRITION:WikifyCollectPanels{
		Category = PYRITION_WIKIFY_PANELS,
		Name = "panel_necrosis",
		Owner = "Necrosis",
		SourcePattern = default_pattern,
		SourceURL = default_source_url,
	}
end