--locals
local color_gray = Color(180, 180, 180)
local color_pale_blue = Color(182, 202, 214)
local material_gradient_up = Material("gui/gradient_up")
local PANEL = {}

--panel functions
function PANEL:Add(key, label)
	local button = vgui.Create("DButton", self)
	local buttons = self.Buttons
	local indexing_parent = self
	buttons[key] = table.insert(self.Buttons, button)
	
	button:Dock(LEFT)
	button:SetContentAlignment(5)
	button:SetIsToggle(true)
	button:SetNecrosisFont("Medium")
	button:SetText(label or string.upper(key))
	
	function button:DoClick()
		if button:GetToggle() then return end
		
		button:SetToggle(true)
		indexing_parent:OnSelect(key, button)
		
		--disable all other buttons
		for index, sub_button in ipairs(buttons) do if sub_button ~= button then sub_button:SetToggle(false) end end
	end
	
	function button:Paint(width, height)
		if button:GetToggle() then
			local stripe_height = math.ceil(height * 0.1)
			
			self:SetTextColor(color_pale_blue)
			
			--gradient
			surface.SetDrawColor(color_pale_blue.r, color_pale_blue.g, color_pale_blue.b, 32)
			surface.SetMaterial(material_gradient_up)
			surface.DrawTexturedRect(0, 0, width, height)
			
			--stripe
			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(0, height - stripe_height, width, stripe_height)
		elseif self.Hovered then
			local gradient_height = math.ceil(height * 0.9)
			
			self:SetTextColor(color_white)
			
			--gradient
			surface.SetDrawColor(255, 255, 255, 16)
			surface.SetMaterial(material_gradient_up)
			surface.DrawTexturedRect(0, height - gradient_height, width, gradient_height)
		else self:SetTextColor(color_gray) end
	end
end

function PANEL:Choose(key)
	local buttons = self.Buttons
	
	if isstring(key) then return self:Choose(buttons[key]) end
	
	local button = buttons[key]
	
	button:DoClick()
end

function PANEL:Init() self.Buttons = {} end
function PANEL:OnSelect(_key, _button) end

function PANEL:PerformLayout(width)
	--we do it like this to prevent gaps and overlaps
	local buttons = self.Buttons
	local button_count = #buttons
	local last_x = 0
	
	for index, button in ipairs(buttons) do
		local next_x = math.Round(index / button_count * width)
		
		button:SetWide(next_x - last_x)
		
		last_x = next_x
	end
end

--post
derma.DefineControl("NecrosisTabs", "Selectable buttons that span horizontally", PANEL, "Panel")