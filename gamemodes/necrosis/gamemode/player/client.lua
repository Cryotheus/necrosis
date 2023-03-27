--local functions
local function get_ragdoll_color(self)
	local owner = self:GetNWEntity("NecrosisOwner", NULL)

	return owner:IsValid() and owner:GetPlayerColor() or nil
end

--gamemode functions
function GM:NetworkEntityCreated(entity) if entity:GetClass() == "prop_ragdoll" then entity.GetPlayerColor = get_ragdoll_color end end