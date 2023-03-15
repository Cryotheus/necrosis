--gamemode functions
function GM:HookMethod(short_key)
	if self[short_key] then return end
	
	local key = "ZombiGM" .. short_key
	
	local function hook_run(_self, ...) return hook.Run(key, ...) end
	
	self[short_key] = hook_run
	ZOMBIGM[short_key] = hook_run
end