--locals
local recharge_delay = 1

--gamemode functions
function GM:PlayerSprint(ply, sprinting, _command)
	local maximum_stamina = ply.NecrosisMaximumStamina
	local timer_name = "NecrosisPlayerSprintRecharge" .. ply:EntIndex()

	if not ply.NecrosisStamina then
		local player_class = baseclass.Get(player_manager.GetPlayerClass(ply))
		maximum_stamina = player_class.NecrosisMaximumStamina or 4

		ply.NecrosisMaximumStamina = maximum_stamina
		ply.NecrosisStamina = maximum_stamina
	end

	if sprinting then
		if ply.NecrosisStaminaStartRecharge then --ply.NecrosisBlockSprinting
			local new_stamina = math.min(ply.NecrosisStamina + (CurTime() - ply.NecrosisStaminaStartRecharge), maximum_stamina)

			ply.NecrosisStamina = new_stamina
			ply.NecrosisStaminaStartRecharge = nil
		end

		ply.StartedSprinting = CurTime()

		timer.Remove(timer_name)
	else
		if ply.NecrosisStamina > 0 then
			--more?
			ply.NecrosisStamina = ply.NecrosisStamina - (CurTime() - ply.StartedSprinting)
		end

		ply.StartedSprinting = nil

		timer.Create(timer_name, recharge_delay, 1, function() if ply:IsValid() then self:PlayerSprintStartRecharge(ply) end end)
	end
end

function GM:PlayerSprinting(ply, _command)
	local start_time = ply.StartedSprinting

	if not start_time then return true end
	if not ply.NecrosisStamina then ply.NecrosisStamina = ply.NecrosisMaximumStamina end

	local time = CurTime() - start_time
	local stamina_remaining = ply.NecrosisStamina - time

	if stamina_remaining <= 0 then
		ply.NecrosisStamina = 0
		ply.NecrosisBlockSprinting = true

		return false
	end

	return true
end

function GM:PlayerSprintStartRecharge(ply)
	local timer_name = "NecrosisPlayerSprintRecharge" .. ply:EntIndex()

	ply.NecrosisStaminaStartRecharge = CurTime()

	timer.Create(timer_name, ply.NecrosisMaximumStamina - ply.NecrosisStamina, 1, function()
		if ply:IsValid() then
			ply.NecrosisStaminaStartRecharge = nil
			ply.NecrosisStamina = ply.NecrosisMaximumStamina
			ply.NecrosisBlockSprinting = false
		end
	end)
end

--[[
hook.Add("HUDPaint", "a", function()
	local ply = LocalPlayer()

	draw.SimpleText(
		"Stamina: " .. tostring(ply.NecrosisStamina),
		"DermaLarge",
		ScrW() * 0.5, ScrH() * 0.4,
		color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
	)

	if ply.NecrosisBlockSprinting then
		draw.SimpleTextOutlined(
			"Exhausted!",
			"DermaLarge",
			ScrW() * 0.5, ScrH() * 0.4 + 48,
			Color(255, 64, 64),
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
			2, color_black
		)
	end

	if not ply:KeyDown(IN_SPEED) then return end

	local w, h = ScrW() * 0.05, ScrH() * 0.05
	local x, y = 4, ScrH() - h - 4

	surface.SetDrawColor(255, 255, 255, 64)
	surface.DrawRect(x, y, w, h)

	draw.SimpleTextOutlined(
		"SHIFT",
		"DermaLarge",
		x + w * 0.5, y + h * 0.5,
		color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
		2, color_black
	)
end)]]