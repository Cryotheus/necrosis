--local tables
local PLAYER = {
	AvoidPlayers = true, --automatically swerves around other players
	CanUseFlashlight = true, --can we use the flashlight
	CrouchedWalkSpeed = 0.6, --multiply move speed by this when crouching
	DisplayName = "Survivor",
	DropWeaponOnDie = false, --do we drop our weapon when we die
	DuckSpeed = 0.1, --how fast to go from not ducking, to ducking
	JumpPower = 200, --how powerful our jump should be
	MaxArmor = 0, --max armor we can have
	MaxHealth = 100, --max health we can have
	NecrosisKickDamage = 20,
	NecrosisKickDelay = 0.5, --how long until the kick hits
	NecrosisKickRange = 80,
	NecrosisKickReset = 0.5, --how long until the kick resets (this is how long after the kick lands until we can kick again)
	NecrosisKickSize = 9, --how big the kick is
	NecrosisMaximumStamina = 4, --maximum stamina
	RunSpeed = 320, --how fast to move when running
	SlowWalkSpeed = 100, --how fast to move when slow-walking (+walk)
	StartArmor = 0, --how much armour we start with
	StartHealth = 100, --how much health we start with
	TeammateNoCollide = false, --do we collide with teammates or run straight through them
	UnDuckSpeed = 0.1, --how fast to go from ducking, to not ducking
	UseVMHands = true, --uses viewmodel hands
	WalkSpeed = 180, --how fast to move when not running
}

--player functions
function PLAYER:CalcView(_view) end
function PLAYER:CreateMove(_command) end
function PLAYER:Death(_inflictor, _attacker) end
function PLAYER:FinishMove(_move) end
function PLAYER:GetHandsModel() return player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(self.Player:GetModel())) end

function PLAYER:GetNetworkField(key, type_field)
	local ply = self.Player

	return ply[key] or ply["GetNW" .. type_field](ply, key, self[key])
end

function PLAYER:Init() end

function PLAYER:Loadout()
	local ply = self.Player

	ply:Give("weapon_pistol")
	ply:GiveAmmo(255, "Pistol", true)
end

function PLAYER:Move(_move) end

function PLAYER:SetNetworkField(key, field_type)
	local ply = self.Player
	local value = self[key]

	ply[key] = value
	ply["SetNW" .. field_type](ply, key, value)
end

function PLAYER:PostDrawViewModel(_view_model, _weapon) end
function PLAYER:PreDrawViewModel(_view_model, _weapon) end

function PLAYER:SetModel()
	local ply = self.Player
	local player_model = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))

	util.PrecacheModel(player_model)
	ply:SetModel(player_model)
end

function PLAYER:SetupDataTables()
	local ply = self.Player

	--ply:NetworkVar("Float", 0, "NecrosisSprintStamina")
	--ply:NetworkVar("Float", 1, "NecrosisSprintStart")
	--ply:NetworkVar("Float", 2, "NecrosisSprintRecover")
	ply:NetworkVar("Float", 3, "NecrosisKick")

	--ply:NetworkVar("Bool", 0, "NecrosisSprinting")
	--ply:NetworkVar("Bool", 1, "NecrosisSprintDisabled")
	ply:NetworkVar("Bool", 2, "NecrosisKicking")
	ply:NetworkVar("Bool", 3, "NecrosisKickBlocked")
	ply:NetworkVar("Bool", 4, "NecrosisKickAttacked")

	if SERVER then return end

	ply:NetworkVarNotify("NecrosisKick", function(entity, _name, _old, new) GAMEMODE:PlayerKickNotfiy(entity, new) end)
end

function PLAYER:ShouldDrawLocal() end

function PLAYER:Spawn()
	local ply = self.Player
	ply.NecrosisKickDamage = self.NecrosisKickDamage

	ply:SetupHands()
	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 28))
	self:SetNetworkField("NecrosisKickDelay", "2Float")
	self:SetNetworkField("NecrosisKickRange", "2Float")
	self:SetNetworkField("NecrosisKickReset", "2Float")
	self:SetNetworkField("NecrosisKickSize", "2Float")
	self:SetNetworkField("NecrosisMaximumStamina", "2Float")
	
	--network vars defaults
	--ply:SetNecrosisSprintStamina(self.NecrosisMaximumStamina)
	--ply:SetNecrosisSprintStart(0)
	--ply:SetNecrosisSprintRecover(0)
	--ply:SetNecrosisSprinting(false)
	--ply:SetNecrosisSprintDisabled(false)
end

function PLAYER:StartMove(_command, _move) end
function PLAYER:ViewModelChanged(_view_model, _old, _new) end

--post
player_manager.RegisterClass("player_survivor", PLAYER, nil)