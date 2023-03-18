--locals

--globals
NECROSIS.ConVarMirrors = NECROSIS.ConVarMirrors or {}

--gamemode functions
function GAMEMODE:ConVarMirror(convar)
	if isstring(convar) then convar = GetConVar(convar) end
	if not convar then return end

	local name = convar:GetName()

	if NECROSIS.ConVarMirrors[name] then return end
	if string.find(name, "[`~]") then return end --don't all internal convats to be mirrored

	local mirror_name = "~necrosis_mirror~" .. name
	local mirror_convar = CreateClientConVar(mirror_name, convar:GetDefault(), true, false, "Do not touch!")
	NECROSIS.ConVarMirrors[name] = mirror_convar

	cvars.AddChangeCallback(name, function() mirror_convar:SetString(convar:GetString()) end, "NecrosisConVarMirror")
end

function GAMEMODE:ShutDown()
	--restore all overridden convars
	for convar_name, mirror in pairs(NECROSIS.ConVarMirrors) do RunConsoleCommand(convar_name, mirror:GetString()) end
end

--post