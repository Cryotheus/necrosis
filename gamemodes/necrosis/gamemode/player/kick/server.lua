--locals
local blood_color_vector = Vector(114, 0, 0)
local default_color_vector = Vector(-1.125, -1.125, -1.125) --tells the effect to automatically determine the color
local kick_damage_type = bit.bor(DMG_CLUB, DMG_NEVERGIB)

--local functions
local function create_effect(position, normal, color)
	--RELEASE: make this properly predicted
	local effect = EffectData()

	effect:SetAngles(normal:Angle())
	effect:SetNormal(normal)
	effect:SetOrigin(position)
	effect:SetStart(color)

	util.Effect("necrosis_kick_impact", effect, true, true)
end

--gamemode functions
function GM:PlayerKickImpactEntity(ply, entity, position)
	local aim_vector = ply:GetAimVector()
	local damage = ply.NecrosisKickDamage
	local damage_info = DamageInfo()

	create_effect(position, -aim_vector, entity:IsNextBot() and blood_color_vector or default_color_vector)
	damage_info:SetAttacker(ply)
	damage_info:SetBaseDamage(damage)
	damage_info:SetDamage(damage)
	damage_info:SetDamageForce(aim_vector * damage * 40)
	damage_info:SetDamagePosition(position)
	damage_info:SetDamageType(kick_damage_type)
	damage_info:SetInflictor(ply)
	damage_info:SetMaxDamage(math.max(entity:GetMaxHealth(), damage) * 3)
	damage_info:SetReportedPosition(ply:WorldSpaceCenter())
	entity:TakeDamageInfo(damage_info)
	ply:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 0, 100, CHAN_BODY)
end

function GM:PlayerKickImpactMissed(ply) ply:EmitSound("Weapon_Crowbar.Single", 0, 85, CHAN_BODY) end

function GM:PlayerKickImpactWorld(ply, position)
	create_effect(position, -ply:GetAimVector(), default_color_vector)
	ply:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 0, 90, CHAN_BODY)
end