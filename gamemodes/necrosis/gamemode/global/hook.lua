--gamemode functions
function GM:HookMethod(short_key)
	if self[short_key] then return end

	local key = "Necrosis" .. short_key
	self[short_key] = function(_self, ...) return hook.Run(key, ...) end
end