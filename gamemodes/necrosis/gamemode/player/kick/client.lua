--locals
local kick_entity = NECROSIS.PlayerKickEntity

--local functions
local function create_kick_entity(ply)
	if IsValid(kick_entity) then kick_entity:Remove() end

	kick_entity = ents.CreateClientside("necrosis_leg")
	NECROSIS.PlayerKickEntity = kick_entity

	kick_entity:SetPlayer(ply)
	kick_entity:Spawn()

	return kick_entity
end

--globals
NECROSIS.PlayerKickEntity = kick_entity

--gamemode functions
function GM:PlayerKickImpactEntity(_ply, _entity, _position) end ---PREDICTED
function GM:PlayerKickImpactMissed(_ply) end ---PREDICTED
function GM:PlayerKickImpactWorld(_ply, _position) end ---PREDICTED

function GM:PlayerKickNotfiy(ply, kick_time)
	if LocalPlayer() ~= ply then return end
	if not kick_entity or kick_entity.Player ~= ply then create_kick_entity(ply) end

	kick_entity:SetKickTime(kick_time)
end

function GM:PlayerKickPressed() self.PlayerKicking = true end
function GM:PlayerKickReleased() self.PlayerKicking = false end

--commands
concommand.Add("+necrosis_kick", function() GAMEMODE:PlayerKickPressed() end)
concommand.Add("-necrosis_kick", function() GAMEMODE:PlayerKickReleased() end)