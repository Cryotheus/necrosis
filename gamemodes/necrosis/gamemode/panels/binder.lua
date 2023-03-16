--locals
local PANEL = {}

--panel functions
function PANEL:Init() self:SetTextColor(Color(210, 210, 210, 255)) end
function PANEL:OnChange(code) GAMEMODE:PlayerBind(code, self.Command) end

function PANEL:Paint(width, height)
	surface.SetDrawColor(0, 0, 0, 128)
	surface.DrawRect(0, 0, width, height)
	
	if self.Trapping then
		surface.SetDrawColor(180, 180, 180, 255)
		surface.DrawOutlinedRect(0, 0, width, height, 1)
	end
end

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