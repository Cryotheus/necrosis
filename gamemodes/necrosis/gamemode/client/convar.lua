--locals
local flags = FCVAR_ARCHIVE + FCVAR_UNREGISTERED

--globals
NECROSIS.ConVarMirrors = NECROSIS.ConVarMirrors or {}

--gamemode functions
function GM:ConVarMirror(convar)
	if isstring(convar) then convar = GetConVar(convar) end
	if not convar then return end

	local name = convar:GetName()

	if NECROSIS.ConVarMirrors[name] then return end
	if string.find(name, "[`~]") then return end --don't allow internal convars to be mirrored

	--FCVAR_UNREGISTERED
	local mirror_name = "~necrosis_mirror~" .. name
	local mirror_convar = CreateConVar(mirror_name, convar:GetDefault(), flags, language.GetPhrase("necrosis.internal_command"))
	NECROSIS.ConVarMirrors[name] = mirror_convar

	cvars.AddChangeCallback(name, function() mirror_convar:SetString(convar:GetString()) end, "NecrosisConVarMirror")
end

function GM:ShutDown()
	--restore all overridden convars
	for convar_name, mirror in pairs(NECROSIS.ConVarMirrors) do RunConsoleCommand(convar_name, mirror:GetString()) end
end