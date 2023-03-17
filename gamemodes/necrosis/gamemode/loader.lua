--https://github.com/Cryotheus/cryotheums_loader
if not PYRITION then --Pyrition is required for this gamemode, so be as annoying as possible about it
	local message = SERVER and MsgC or chat.AddText
	
	local function give_me_pyrition()
		message(
			Color(181, 33, 33), "[Necrosis]",
			Color(255, 64, 64), "[ERROR] ",
			Color(240, 240, 240), "Pyrition is not installed! Please install it from here: https://github.com/Cryotheus/pyrition_2",
			SERVER and "\n" or ""
		)
	end
	
	give_me_pyrition()
	
	hook.Add("InitPostEntity", "Necrosis", function()
		give_me_pyrition()
		timer.Simple(5, give_me_pyrition)
	end)
	
	return
end

local config = {
	--to prevent merge conflicts, please use trailing commas and don't stack tables on the same line
	--but always stack the the value at the first index
	{
		cl_init = "download",
		
		global = {
			hook = "shared",
			shared = true,
		},
		
		loader = "download",
		shared = "download",
	},
	
	{
		panels = {
			binder = "client",
			binder_labeled = "client",
			
			main_menu = {"client",
				game = "client",
				model = "client",
				player = "client",
				player_list = "client",
				players = "client",
			},
			
			material_design_icon = "client",
			material_design_icon_button = "client",
			
			settings_menu = {"client",
				credits = "client",
				binds = "client",
				general = "client",
			},
			
			slider = "client",
			swap_panel = "client",
			tabs = "client",
		}
	},
	
	{
		bind = {
			client = true,
			server = true,
		},
		
		player = {
			server = true,
			shared = true,
		},
		
		player_class = {
			spectator = "shared",
			survivor = "shared",
		},
		
		team = "shared",
		
		ui = {
			font = "client",
			--icon = "client",
			main_menu = "client",
		},
	},
	
	--only exception to the rule above, as this should be the last script to load
	{global = {post = "shared"}}, 
}

local branding = "Necrosis"
local color = Color(255, 105, 12) --color representing your project
local color_generic = Color(240, 240, 240) --most frequently used color
local load_extensions = true
local silent = true --disable console messages

do --do not touch
	--locals
	local active_gamemode = engine.ActiveGamemode()
	local block_developer = not GetConVar("developer"):GetBool()
	local check_words, load_late, load_methods, word_methods
	local extension_list = {}
	local global = _G["CryotheumsLoader_" .. branding] or {}
	local hook_name = "CryotheumsLoader" .. branding
	local include_list = {}
	local workshop_ids = {}
	
	--local functions
	local function build_list(include_list, prefix, tree) --recursively explores to build load order
		for name, object in pairs(tree) do
			local trimmed_path = name == 1 and string.sub(prefix, 1, -2) or prefix .. name
			
			if istable(object) then build_list(include_list, trimmed_path .. "/", object)
			elseif object then
				local words = isstring(object) and string.Split(object, " ") or {name}
				local script = trimmed_path .. ".lua"
				local word = table.remove(words, 1)
				local load_method = load_methods[word]
				
				if load_method and (load_method == true or load_method(script)) and check_words(words, script) then table.insert(include_list, script) end
			end
		end
	end
	
	function check_words(words, script)
		for index, raw_word in ipairs(words) do
			local word_parts = string.Split(raw_word, ":")
			local word = table.remove(word_parts, 1)
			local word_method = word_methods[word] or nil
			
			if word_method and (word_method == true or word_method(words, script, unpack(word_parts))) then return false end
		end
		
		return true
	end
	
	local function create_hook(hook_event, script, repeated)
		global[hook_event] = {{script, repeated}, First = true}
		
		hook.Add(hook_event, hook_name, function() load_late(hook_event) end)
	end
	
	local function grab_extensions(directory)
		local files, folders = file.Find(directory .. "*", "LUA")
		
		--file.Exists is not reliable for directories on client
		if files then
			for index, folder_name in ipairs(folders) do
				local directory = directory .. folder_name .. "/"
				local files = file.Find(directory .. "*.lua", "LUA")
				
				if files then
					for index, file_name in ipairs(files) do
						if _G[string.upper(string.sub(file_name, 1, -5))] then
							--added the file if a global in all uppers of its name exists
							--client.lua will be loaded on the client because of the CLIENT variable
							--server.lua works just as you expect, and shared.lua works because we make the global
							table.insert(extension_list, directory .. file_name)
						end
					end
				end
			end
			
			for index, file_name in ipairs(files) do table.insert(extension_list, directory .. file_name) end
		end
	end
	
	function load_late(hook_event)
		local scripts = global[hook_event]
		
		--lazy load wizardry
		if scripts.First then
			local new_scripts = {}
			global[hook_event] = new_scripts
			
			for index, script_pair in ipairs(scripts) do
				local script = script_pair[1]
				
				include(script)
				
				if script_pair[2] then table.insert(new_scripts, script) end
			end
			
			--stop if we have scripts that load on repeated calls
			if new_scripts[1] then return end
			
			hook.Remove(hook_event, hook_name)
		else for index, script in ipairs(scripts) do include(script) end end
	end
	
	local function load_scripts(include_list)
		--to allow detours to have some hope of working properly, we only just now cache MsgC
		local MsgC = silent and function() end or MsgC
		
		if GM then MsgC(color, "\nLoading " .. branding .. " (Gamemode) scripts...\n")
		else MsgC(color, "\nLoading " .. branding .. " scripts...\n") end
		
		MsgC(color_generic, "This load is running in the " .. (SERVER and "SERVER" or "CLIENT") .. " realm.\n")
		
		for index, script in ipairs(include_list) do
			MsgC(color_generic, "\t" .. index .. ": " .. script .. "\n")
			include(script)
		end
		
		MsgC(color, GM and "Gamemode load concluded.\n\n" or "Load concluded.\n\n")
	end
	
	--local tables
	load_methods = SERVER and {
		client = AddCSLuaFile,
		download = AddCSLuaFile,
		server = true,
		
		shared = function(script)
			AddCSLuaFile(script)
			
			return true
		end
	} or {client = true, shared = true}
	
	word_methods = { --return true to block the script
		dedicated = not game.IsDedicated(),
		developer = block_developer,
		hosted = not game.IsDedicated() and game.SinglePlayer(),
		if_addon = function(_words, _script, workshop_id) return not workshop_ids[workshop_id] end,
		if_gamemode = function(_words, _script, name) return active_gamemode ~= name end,
		if_global = function(_words, _script, global_name) return _G[global_name] == nil end,
		listen = game.IsDedicated() or game.SinglePlayer(),
		no_addon = function(_words, _script, workshop_id) return workshop_ids[workshop_id] end,
		no_gamemode = function(_words, _script, name) return active_gamemode == name end,
		no_global = function(_words, _script, global_name) return _G[global_name] ~= nil end,
		simple = game.IsDedicated(),
		single = not game.SinglePlayer(),
		
		await = function(_words, script, hook_event)
			if _CryotheumsLoaderHookHistory[hook_event] then return true end
			
			local scripts = global[hook_event]
			
			if scripts then table.insert(scripts, {script, false})
			else create_hook(hook_event, script, false) end
			
			return false
		end,
		
		gamemode = function(_words, script)
			if _CryotheumsLoaderHookHistory.Initialize then return true end
			
			local scripts = global.Initialize
			
			if scripts then table.insert(scripts, {script, false})
			else create_hook("Initialize", script, false) end
			
			return false
		end,
		
		hook = function(_words, script, hook_event)
			local scripts = global[hook_event]
			
			if _CryotheumsLoaderHookHistory[hook_event] then
				if scripts then table.insert(scripts, script)
				else global[hook_event] = {script} end
			else
				if scripts then table.insert(scripts, {script, true})
				else create_hook(hook_event, script, true) end
			end
			
			--only ever run by the hook
			return true
		end,
		
		player = function(_words, script)
			if _CryotheumsLoaderHookHistory.PlayerInitialSpawn then return true end
			
			local scripts = global.PlayerInitialSpawn
			
			if scripts then table.insert(scripts, {script, false})
			else create_hook("PlayerInitialSpawn", script, false) end
			
			return false
		end,
		
		world = function(_words, script)
			if _CryotheumsLoaderHookHistory.InitPostEntity then return true end
			
			local scripts = global.InitPostEntity
			
			if scripts then table.insert(scripts, {script, false})
			else create_hook("InitPostEntity", script, false) end
			
			return false
		end,
	}
	
	--globals
	_CryotheumsLoaderHookHistory = _CryotheumsLoaderHookHistory or {}
	_G["CryotheumsLoader_" .. branding] = global
	
	--post
	if load_extensions then
		local loader = debug.getinfo(1, "S").short_src
		--local loader_substring
		local _start, finish
		
		if GM then
			_start, finish = string.find(loader, "/.-/gamemodes/")
			--loader_substring = string.sub(loader, finish + 1)
			--loader_substring = 
		else
			_start, finish = string.find(loader, "/?lua/", 1, true)
			--loader_substring = string.sub(loader, start + 4, finish)
		end
		
		local loader_path = string.sub(loader, finish + 1)
		local loader_extensions_directory = string.GetPathFromFilename(loader_path) .. "extensions/"
		local map = game.GetMap()
		SHARED = true --for shared.lua extension files
		
		grab_extensions(loader_extensions_directory)
		grab_extensions(loader_extensions_directory .. "gamemode/" .. active_gamemode .. "/")
		grab_extensions(loader_extensions_directory .. "map/" .. map .. "/")
		table.sort(extension_list)
	end
	
	--give access to the config to extensions
	CryotheumsLoaderActiveConfig = config
	
	for index, value in ipairs(extension_list) do include(value) end
	
	CryotheumsLoaderActiveConfig = nil
	
	for hook_event, hook_functions in pairs(hook.GetTable()) do if hook_functions[hook_name] then hook.Remove(hook_event, hook_name) end end --remove outdated hooks
	for index, addon in ipairs(engine.GetAddons()) do workshop_ids[addon.wsid] = true end --build the workshop id list
	for priority, tree in ipairs(config) do build_list(include_list, "", tree) end --build the load order
	
	load_scripts(include_list, false)
end