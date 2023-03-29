--locals
local to_hook = {}

--post
for key, value in pairs(GM) do
	--queue up a HookMethod call for anything prexied by Necrosis
	--we have to queue, because modifying the table while iterating will skip indices with a big table
	if isstring(key) and string.StartWith(key, "Necrosis") then table.insert(to_hook, string.sub(key, 9)) end
end

for index, short_key in ipairs(to_hook) do GM:HookMethod(short_key) end