--gamemode functions
function GM:PlayerNoClip(ply, desire)
	if ply:Team() == TEAM_SURVIVOR then
		--return false --block noclip for survivors
		return true
	else return desire end --force into noclip
end

function GM:StartCommand(ply, command)
	if ply:Team() ~= TEAM_SURVIVOR then
		ply.NecrosisSprinting = false

		return
	end

	local sprinting = command:KeyDown(IN_SPEED) and (command:GetForwardMove() ~= 0 or command:GetSideMove() ~= 0)

	if ply.NecrosisBlockSprinting then
		--command:RemoveKey(IN_SPEED)

		return
	end

	if sprinting ~= ply.NecrosisSprinting then
		ply.NecrosisSprinting = sprinting

		self:PlayerSprint(ply, sprinting, command)
	end

	if sprinting then
		local new_speed
		local player_class = baseclass.Get(player_manager.GetPlayerClass(ply))

		if self:PlayerSprinting(ply, command) then new_speed = player_class.RunSpeed
		else
			ply.NecrosisSprinting = false
			new_speed = player_class.WalkSpeed

			--command:RemoveKey(IN_SPEED)
			self:PlayerSprint(ply, false, command)
		end

		if new_speed ~= ply:GetRunSpeed() then ply:SetRunSpeed(new_speed) end
	end
end