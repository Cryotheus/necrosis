SWEP.Author = "Cryotheum"
SWEP.Purpose = "Allow spectators to control their spectate mode."

function SWEP:Initialize() self.TargetIndex = 1 end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	local spectatable_players = {}

	for index, ply in pairs(player.GetAll()) do if ply:NecrosisPlaying() then table.insert(spectatable_players) end end

	local index = self.TargetIndex % #spectatable_players + 1
	self.TargetIndex = index

	owner:SpectateEntity(spectatable_players[index])
end