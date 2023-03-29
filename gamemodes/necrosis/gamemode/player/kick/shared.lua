--gamemode functions
function GM:PlayerKickStartCommand(ply, _player_class, command)
	if self.PlayerKicking then command:AddKey(IN_CANCEL) end --set by client using a command

	local kicking = command:KeyDown(IN_CANCEL)
	local was_kicking = ply:GetNecrosisKicking() or false
	
	if kicking ~= was_kicking then
		ply:SetNecrosisKicking(kicking)
		
		if kicking and not command:KeyDown(IN_SPEED) and not ply:GetNecrosisKickBlocked() then self:PlayerKick(ply) end
	end
	
	local kick_time = ply:GetNecrosisKickBlocked() and ply:GetNecrosisKick()

	if kick_time then
		if CurTime() > kick_time + ply:GetPlayerClassNWField("NecrosisKickReset", "2Float") then
			ply:SetNecrosisKickBlocked(false)
			ply:SetNecrosisKickAttacked(false)
		elseif kick_time > CurTime() and not ply:GetNecrosisKickAttacked(true) then
			--TODO: cause damage
			ply:SetNecrosisKickAttacked(true)
			self:PlayerKickImpact(ply)
		end
	end
end

function GM:PlayerKick(ply)
	ply:SetNecrosisKick(CurTime() + ply:GetPlayerClassNWField("NecrosisKickDelay", "2Float"))
	ply:SetNecrosisKickAttacked(false)
	ply:SetNecrosisKickBlocked(true)
end