AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--entity functions
--function ENT:BehaveStart() self.BehaveThread = coroutine.create(function() self:RunBehaviour() end) end
function ENT:BehaveStart() end

function ENT:BehaveUpdate(_interval)
	--[[local thread = self.BehaveThread

	if thread then
		if coroutine.status(thread) == "dead" then Msg(tostring(self) .. " coroutine finished")
		else
			local ok, message = coroutine.resume(thread)

			if ok then return end

			ErrorNoHalt(tostring(self), " coroutine erred: ", message, "\n")
		end

		self.BehaveThread = nil
	end]]
end

function ENT:BodyUpdate() end
function ENT:HandleAnimEvent(_event, _event_time, _cycle, _class, _options) end
function ENT:HandleStuck() end

function ENT:Initialize()
	self.Progress = 0

	--DONT CHANGE NEXTBOT MOVETYPE! ITS A PHYSICS DEATH SENTENCE!
	self:AddEFlags(EFL_NO_DAMAGE_FORCES) --EFL_SERVER_ONLY too?
	self:ResetHealth()
	self:SetMaterial("phoenix_storms/stripes")
	self:SetModel("models/player/zombie_fast.mdl")

	--the wiki is incorrect, this does everything
	self:UseClientSideAnimation()

	--flags to test
	--self:AddEFlags(EFL_SERVER_ONLY)
	--self:AddEFlags(EFL_BOT_FROZEN)
	--self:AddEFlags(EFL_NO_DISSOLVE)
	--self:AddEFlags(EFL_NO_GAME_PHYSICS_SIMULATION)
	--self:AddFlags(FL_DONTTOUCH)
	--self:AddFlags(FL_FROZEN)

	duplex.Insert(NECROSIS.NavigationGenerators, self)
end

function ENT:OnContact(_entity) end
function ENT:OnEntitySight(_subject) end
function ENT:OnEntitySightLost(_subject) end
function ENT:OnIgnite() end
function ENT:OnInjured(_damage_info) self:ResetHealth() end
function ENT:OnKilled(_damage_info) self:ResetHealth() end
function ENT:OnLandOnGround(_entity) end
function ENT:OnLeaveGround(_entity) end
function ENT:OnNavAreaChanged(_old, _new) end
function ENT:OnOtherKilled(_victim, _info) end

function ENT:OnRemove()
	local generators = NECROSIS.NavigationGenerators

	if generators[self] then duplex.Remove(generators, self) end
end

function ENT:OnStuck() end
function ENT:OnTakeDamage(_damage_info) end
function ENT:OnTraceAttack(_damage_info, _direction, _trace) end
function ENT:OnUnStuck() end
function ENT:ResetHealth() self:SetHealth(2147483647) end
function ENT:RunBehaviour() end

function ENT:SetLockPosition(position)
	self.LockPosition = position

	self:SetPos(position)
end

function ENT:Think()
	if self.Done then
		self.Think = nil

		self:Remove()

		return false
	end

	self.NeedsNextTick = false

	self:NextThink(CurTime())
	self:SetPos(self.LockPosition)
	self.loco:SetVelocity(vector_origin)

	GAMEMODE:NavigationGeneratorThink(self)

	return true
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end --TODO: use TRANSMIT_NEVER instead
function ENT:Use(_activator, _caller, _type, _value) end