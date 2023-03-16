--locals
local PANEL = {}

--panel functions
function PANEL:OnChange(code) GAMEMODE:PlayerBind(code, self.Command) end

function PANEL:SetCommand(command)
	local code = NECROSIS.Binds[command] or 0
	self.Command = command
	
	self:SetSelectedNumber(code)
end

function PANEL:UpdateText()
	local name = input.GetKeyName(self:GetSelectedNumber())
	local translated
	
	if name then translated = language.GetPhrase(name)
	else return self:SetText("NONE") end
	
	if translated ~= name then self:SetText(translated)
	else self:SetText(string.upper(name)) end
end

--post
derma.DefineControl("NecrosisBinder", "", PANEL, "DBinder")