AddCSLuaFile()

--locals
local default_color_vector = Vector(36, 34, 32)
local LocalToWorld = LocalToWorld
local math_cos = math.cos
local math_Rand = math.Rand
local math_sin = math.sin
local tau = math.pi * 2
local Vector = Vector

--effect functions
function EFFECT:Init(data)
	local color = data:GetStart() --we use this for color
	local normal = data:GetNormal()
	local origin = data:GetOrigin()
	local particle_emitter = ParticleEmitter(origin, false)
	local r, g, b = color[1]
	local trace_beginning = origin + normal * 4
	local trace_finish = origin - normal * 48
	local trace_result = util.TraceLine{start = trace_beginning, endpos = trace_finish}
	local trace_result_angles = trace_result.HitNormal:Angle()

	if r == -1.125 then --why -1.125? because that's how imprecise the networking is :p
		local surface_color = render.GetSurfaceColor(trace_beginning, trace_finish) * 400

		--use surface color, or the fallback color
		if surface_color:LengthSqr() ~= 0 then r, g, b = surface_color[1], surface_color[2], surface_color[3]
		else r, g, b = default_color_vector[1], default_color_vector[2], default_color_vector[3] end
	else g, b = color[2], color[3] end

	--for index = 1, math_Random(8, 12) do
	for index = 1, math.random(12, 18) do
		local particle = particle_emitter:Add("particle/particle_smokegrenade", origin)

		if particle then
			local angle = math_Rand(0, tau)
			local radius = math_Rand(48, 56)

			particle:SetAngles(Angle(0, math_Rand(0, 360), 0))
			particle:SetColor(r, g, b)
			particle:SetDieTime(0.5)
			particle:SetEndAlpha(0)
			particle:SetEndSize(math_Rand(16, 24))
			particle:SetLifeTime(0)
			particle:SetStartAlpha(255)
			particle:SetStartSize(math_Rand(6, 10))
			
			particle:SetVelocity(
				LocalToWorld(
					Vector(math_Rand(0.1, 1), math_cos(angle) * radius, math_sin(angle) * radius),
					angle_zero,
					vector_origin,
					trace_result_angles
				)
			)
		end
	end

	particle_emitter:Finish()
end

function EFFECT:Render() end
function EFFECT:Think() return false end