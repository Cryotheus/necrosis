--locals
local PANEL = {}

--panel functions
function PANEL:DoClick()
	self.Think = self.ThinkBind
	self.Trapping = true

	--TODO: play sound here (start binding)
	input.StartKeyTrapping()
	self:SetText("PRESS A KEY")
end

function PANEL:DoRightClick()
	--TODO: play sound here (unbinding key)
	GAMEMODE:BindRestore(self.Command)
	self:SetSelectedNumber(0)
end

function PANEL:Init()
	self.Think = nil

	self:SetTextColor(Color(210, 210, 210, 255))
end

function PANEL:OnChange(code) if code ~= 0 then GAMEMODE:BindOverride(code, self.Command) end end

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

function PANEL:ThinkBind()
	if input.IsKeyTrapping() and self.Trapping then
		local code = input.CheckKeyTrapping()

		if code then
			self.Trapping = false

			if code == KEY_ESCAPE then
				--TODO: play sound here (key binding cancelled)
				self:SetValue(self:GetSelectedNumber())
			else
				--TODO: play sound here (key bound)
				self:SetValue(code)
			end
		end
	end
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