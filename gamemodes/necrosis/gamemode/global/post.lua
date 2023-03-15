--post
for key, value in pairs(GM) do
	--call HookMethod for anything prexied by Necrosis
	if isstring(key) and string.StartWith(key, "Necrosis") then GM:HookMethod(string.sub(key, 9)) end
end