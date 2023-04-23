--entity fields
ENT.Author = "Cryotheum"
ENT.Base = "base_entity"
ENT.Category = "Necrosis"
ENT.Contact = "discord.gg/PuxPSDun2k"
ENT.PrintName = "Necrosis Nextbot Base"
ENT.Purpose = "Acts as the base for all Necrosis Nextbots which need optimized navigation."
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spawnable = true
ENT.Type = "nextbot"

--entity functions
function ENT:SharedInitialize()
	--the wiki is incorrect, this does everything
	self:UseClientSideAnimation()
end