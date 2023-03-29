--locals
local kick_damage_type = bit.bor(DMG_CLUB, DMG_NEVERGIB)

--gamemode functions
function GM:PlayerKickImpactEntity(ply, entity, position)
	local damage = ply.NecrosisKickDamage
	local damage_info = DamageInfo()

	damage_info:SetAttacker(ply)
	damage_info:SetBaseDamage(damage)
	damage_info:SetDamage(damage)
	damage_info:SetDamageForce(ply:GetAimVector() * damage * 10)
	damage_info:SetDamagePosition(position)
	damage_info:SetDamageType(kick_damage_type)
	damage_info:SetInflictor(ply)
	damage_info:SetMaxDamage(math.max(entity:GetMaxHealth(), damage) * 3)
	damage_info:SetReportedPosition(ply:WorldSpaceCenter())
	entity:TakeDamageInfo(damage_info)
	ply:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 0, 100, CHAN_BODY)
end

function GM:PlayerKickImpactMissed(ply) ply:EmitSound("Weapon_Crowbar.Single", 0, 85, CHAN_BODY) end
function GM:PlayerKickImpactWorld(ply, _position) ply:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 0, 90, CHAN_BODY) end