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
function PLAYER:Init() end

function PLAYER:Loadout()
	local ply = self.Player

	ply:Give("weapon_pistol")
	ply:GiveAmmo(255, "Pistol", true)
end

function PLAYER:Move(_move) end
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

	--ply:NetworkVar("Bool", 0, "NecrosisSprinting")
	--ply:NetworkVar("Bool", 1, "NecrosisSprintDisabled")
end

function PLAYER:ShouldDrawLocal() end

function PLAYER:Spawn()
	local maximum_stamina = self.NecrosisMaximumStamina
	local ply = self.Player
	ply.NecrosisMaximumStamina = maximum_stamina

	ply:SetupHands()
	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 28))

	--network vars defaults
	--ply:SetNecrosisSprintStamina(maximum_stamina)
	--ply:SetNecrosisSprintStart(0)
	--ply:SetNecrosisSprintRecover(0)
	--ply:SetNecrosisSprinting(false)
	--ply:SetNecrosisSprintDisabled(false)
end

function PLAYER:StartMove(_command, _move) end
function PLAYER:ViewModelChanged(_view_model, _old, _new) end

--post
player_manager.RegisterClass("player_survivor", PLAYER, nil)