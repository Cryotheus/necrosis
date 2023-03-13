--local tables
local PLAYER = {
	AvoidPlayers = true, --automatically swerves around other players
	CanUseFlashlight = true, --can we use the flashlight
	CrouchedWalkSpeed = 0.4, --multiply move speed by this when crouching
	DisplayName = "Survivor",
	DropWeaponOnDie = false, --do we drop our weapon when we die
	DuckSpeed = 0.3, --how fast to go from not ducking, to ducking
	JumpPower = 200, --how powerful our jump should be
	MaxArmor = 0, --max armor we can have
	MaxHealth = 100, --max health we can have
	RunSpeed = 320, --how fast to move when running
	SlowWalkSpeed = 100, --how fast to move when slow-walking (+walk)
	StartArmor = 0, --how much armour we start with
	StartHealth = 100, --how much health we start with
	TeammateNoCollide = false, --do we collide with teammates or run straight through them
	UnDuckSpeed = 0.3, --how fast to go from ducking, to not ducking
	UseVMHands = true, --uses viewmodel hands
	WalkSpeed = 200, --how fast to move when not running
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

function PLAYER:SetupDataTables() end
function PLAYER:ShouldDrawLocal() end
function PLAYER:Spawn() end
function PLAYER:StartMove(_command, _move) end
function PLAYER:ViewModelChanged(_view_model, _old, _new) end

--post
player_manager.RegisterClass("player_survivor", PLAYER, nil)