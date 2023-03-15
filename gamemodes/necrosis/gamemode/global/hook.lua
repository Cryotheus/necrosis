--gamemode functions
function GM:HookMethod(short_key)
	if self[short_key] then return end
	
	local key = "Necrosis" .. short_key
	
	local function hook_run(_self, ...) return hook.Run(key, ...) end
	
	self[short_key] = hook_run
end