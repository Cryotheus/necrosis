--locals
local check_interval = 10
local last_check = 0
local panel_count = table.Count(NECROSIS.UIFontPanels or {})
local panel_meta = FindMetaTable("Panel")

--globals
NECROSIS.UIFonts = NECROSIS.UIFonts or {}
NECROSIS.UIFontPanels = NECROSIS.UIFontPanels or {}
NECROSIS.UIFontRegistry = NECROSIS.UIFontRegistry or {}

--local functions
local function create_font(font, size)
	local key = "Necrosis_" .. font .. "_" .. size

	if NECROSIS.UIFontRegistry[key] then return key end

	NECROSIS.UIFontRegistry[key] = true

	surface.CreateFont(key, {
		font = font,
		extended = true,
		size = size,
	})

	return key
end

--panel functions
function panel_meta:SetNecrosisFont(key)
	---Sets the scalable font of the panel and adds it to the panel tracker. This font will be updated when the screen size changes.
	self:SetFont(GAMEMODE:UIFontAddPanel(self, key))
end

--gamemode functions
function GM:OnScreenSizeChanged(_old_width, _old_height)
	local fonts = NECROSIS.UIFonts
	local multiplier = ScrH() / 1440
	local panels = NECROSIS.UIFontPanels

	--update the fonts, and then the panels
	for key, details in pairs(fonts) do details.Name = create_font(details.Font, math.max(math.Round(details.Size * multiplier), 6)) end

	for panel, key in pairs(panels) do
		--panels start acting weird when the become null
		if panel:IsValid() then panel:SetFont(fonts[key].Name)
		else panels[panel] = nil end
	end
end

function GM:UIFontAddPanel(panel, key)
	local font_panels = NECROSIS.UIFontPanels
	local count = panel_count + 1

	--remove all invalid panels every 10 panels added
	if count - last_check >= check_interval then
		for panel, key in pairs(font_panels) do
			if not IsValid(panel) then
				count = count - 1
				font_panels[panel] = nil
			end
		end

		last_check = count
	end

	panel_count = count
	font_panels[panel] = key

	return NECROSIS.UIFonts[key].Name
end

function GM:UIFontRegister(key, font, size)
	---Register a scalable font.
	---Use the font on the panel by calling `panel:SetNecrosisFont(key)`.
	NECROSIS.UIFonts[key] = {
		Font = font,
		Name = create_font(font, size),
		Size = size
	}
end

--post
GM:UIFontRegister("Big", "Google Sans", 48)
GM:UIFontRegister("Huge", "Google Sans", 64)
GM:UIFontRegister("Medium", "Google Sans", 32)
GM:UIFontRegister("Regular", "Google Sans", 28)
GM:UIFontRegister("Small", "Google Sans", 24)
GM:UIFontRegister("Tiny", "Google Sans", 20)