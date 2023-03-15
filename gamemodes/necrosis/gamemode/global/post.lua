--post
for key, value in pairs(GM) do
	--call HookMethod for anything prexied by ZombiGM
	if isstring(key) and string.StartWith(key, "ZombiGM") then GM:HookMethod(string.sub(key, 8)) end
end