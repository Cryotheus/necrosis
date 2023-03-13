--post
if ZOMBIGM then table.Empty(ZOMBIGM)
else ZOMBIGM = {} end

for key, value in pairs(GM) do
	if isstring(key) and string.StartsWith(key, "ZombiGM") then
		--create the hook.Run macro
		local short_key = string.sub(key, 8)
		
		local function hook_run(_self, ...) return hook.Run(key, ...) end
		
		GM[short_key] = hook_run
		ZOMBIGM[short_key] = hook_run
	end
end