SWEP.Author = "Cryotheum"
SWEP.Instructions = "Primary: Next player\nSecondary: Previous player"
SWEP.Purpose = "Allow spectators to control their spectate mode."
SWEP.ViewModel = "models/error.mdl"
SWEP.WorldModel = "models/error.mdl"

SWEP.Primary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1,
}

SWEP.Secondary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1,
}

--tells the gamemode that this weapon should not be given
SWEP.NecrosisIgnore = true

--swep functions
function SWEP:DrawWorldModel() end
function SWEP:DrawWorldModelTranslucent() end

function SWEP:Equip()
	local owner = self:GetOwner()

	--we really don't want normal players to have this
	if owner:IsValid() and owner:NecrosisSpectating() then return end

	self:Remove()
end

function SWEP:Initialize() self.TargetIndex = 0 end
function SWEP:PrimaryAttack() self:Spectate(1) end

function SWEP:Release()
	local owner = self:GetOwner()

	owner:SetObserverMode(OBS_MODE_ROAMING)
end

function SWEP:SecondaryAttack() self:Spectate(-1) end
function SWEP:ShouldDrawViewModel() return false end

function SWEP:Spectate(offset)
	local owner = self:GetOwner()
	local spectatable_players = {}

	for index, ply in pairs(player.GetAll()) do if ply:NecrosisPlaying() then table.insert(spectatable_players) end end

	local index = (self.TargetIndex + offset) % #spectatable_players
	self.TargetIndex = index

	owner:SetObserverMode(OBS_MODE_CHASE)
	owner:SpectateEntity(spectatable_players[index + 1])

	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:SetNextSecondaryFire(CurTime() + 0.1)
end

function SWEP:Think()
	local owner = self:GetOwner()
	local target = self:GetObserverTarget()

	if target:IsValid() then
		if target:NecrosisPlaying() then return end

		self:Release()
	end
end