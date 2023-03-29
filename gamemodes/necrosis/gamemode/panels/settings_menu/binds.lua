--locals
local PANEL = {}
local valid_branch = BRANCH == "x86-64" or BRANCH == "chromium"

--panel functions
function PANEL:Init()
	local preview_scroller
	self.Binders = {}

	do --scroller
		local scroller = vgui.Create("DScrollPanel", self)
		scroller.Paint = nil
		self.ScrollPanel = scroller

		scroller:Dock(FILL)

		do --contents
			local left_panel
			local right_panel
			local sizer = vgui.Create("DSizeToContents", scroller)
			scroller.SizerPanel = sizer

			scroller:AddItem(sizer)
			sizer:Dock(TOP)

			function sizer:PerformLayout(width)
				local divide = math.ceil(ScrH() * 0.02)
				local margin = math.ceil(ScrH() * 0.005)
				local right_width = math.ceil(width * 0.5)

				left_panel:SetWide(width - right_width - divide)
				right_panel:SetX(left_panel:GetWide() + divide * 2)
				right_panel:SetWide(right_width - divide)

				self.KickBinderPanel:DockMargin(0, 0, 0, margin)
				self.MeleeBinderPanel:DockMargin(0, 0, 0, margin)
				self.GrenadeBinderPanel:DockMargin(0, 0, 0, margin)
				self.SpecialGrenadeBinderPanel:DockMargin(0, 0, 0, margin)

				self:SizeToChildren(false, true)
			end

			do --left panel
				left_panel = vgui.Create("DSizeToContents", sizer)
				sizer.LeftPanel = left_panel

				function left_panel:PerformLayout() self:SizeToChildren(false, true) end
			end

			do --right panel
				right_panel = vgui.Create("DSizeToContents", sizer)
				sizer.RightPanel = right_panel

				function right_panel:PerformLayout() self:SizeToChildren(false, true) end
			end

			do --kick binder
				local binder = vgui.Create("NecrosisBinderLabeled", left_panel)
				sizer.KickBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("necrosis_kick")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.kick")
				self:RegisterBinder("kick", binder)
			end

			do --melee binder
				local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
				sizer.MeleeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_melee")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.melee")
				self:RegisterBinder("melee", binder)
			end

			do --grenade binder
				local binder = vgui.Create("NecrosisBinderLabeled", left_panel)
				sizer.GrenadeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_grenade")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.grenade")
				self:RegisterBinder("grenade", binder)
			end

			do --special grenade binder
				local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
				sizer.SpecialGrenadeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_special_grenade")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.sepcial_grenade")
				self:RegisterBinder("sepcial_grenade", binder)
			end
		end
	end

	do --preview
		preview_scroller = vgui.Create("DScrollPanel", self)
		preview_scroller.Paint = nil
		self.PreviewScrollPanel = preview_scroller

		preview_scroller:Dock(RIGHT)

		function preview_scroller:PerformLayout(width)
			local info_padding = math.ceil(width * 0.025)
			local image = self.PreviewImage

			image:SetTall(width / image.ActualWidth * image.ActualHeight)
			self.HeaderLabel:DockMargin(0, 0, 0, math.ceil(ScrH() * 0.005))
			self.InfoLabel:DockMargin(info_padding, 0, info_padding, info_padding)
			self.PreviewWEBM:SetTall(width * 9 / 16)
		end

		do --header label
			local label = vgui.Create("DLabel", preview_scroller)
			preview_scroller.HeaderLabel = label

			label:Dock(TOP)
			label:SetAutoStretchVertical(true)
			label:SetContentAlignment(5)
			label:SetText("#necrosis.panels.settings_menu_binds.preview.header")
			label:SetNecrosisFont("Medium")
			preview_scroller:AddItem(label)
		end

		do --image
			local image = vgui.Create("DImage", preview_scroller)
			preview_scroller.PreviewImage = image

			image:Dock(TOP)
			image:SetImage("matsys_regressiontest/background")
			image:SetVisible(false)
		end

		do --video
			local webm = vgui.Create("NecrosisWEBM", preview_scroller)
			preview_scroller.PreviewWEBM = webm

			webm:Dock(TOP)
			webm:SetVisible(false)
		end

		do --info label
			local label = vgui.Create("DLabel", preview_scroller)
			preview_scroller.InfoLabel = label

			label:Dock(TOP)
			label:SetAutoStretchVertical(true)
			label:SetContentAlignment(4)
			label:SetNecrosisFont("Small")
			label:SetText("#necrosis.panels.settings_menu_binds.preview.description")
			label:SetWrap(true)
			preview_scroller:AddItem(label)
		end
	end
end

function PANEL:PerformLayout(width)
	local divide = math.ceil(ScrH() * 0.02)

	self.PreviewScrollPanel:SetWide(math.ceil(width * 0.5) - divide)
	self.ScrollPanel:DockMargin(0, 0, divide, 0)
end

function PANEL:RegisterBinder(key, binder)
	binder.NecrosisBindPreviewKey = key
	self.Binders[key] = binder
end

function PANEL:SetBindPreview(key)
	local image_path = "materials/necrosis/binding_previews/" .. key .. ".png"
	local scroller = self.PreviewScrollPanel
	local video_path = "necrosis/webm/binding_previews/" .. key .. ".dat"

	scroller.HeaderLabel:SetText(self.Binders[key]:GetText())
	scroller.InfoLabel:SetText("#necrosis.panels.settings_menu_binds.binder." .. key .. ".description")

	if valid_branch and file.Exists(video_path, "DATA") then
		local webm = scroller.PreviewWEBM

		webm:SetURL("asset://garrysmod/data/" .. video_path)
		webm:SetVisible(true)
		scroller.PreviewImage:SetVisible(false)
	elseif file.Exists(image_path, "GAME") then
		local image = scroller.PreviewImage

		image:SetImage(image_path)
		image:SetVisible(true)
		scroller.PreviewWEBM:SetVisible(false)
	else
		scroller.PreviewImage:SetVisible(false)
		scroller.PreviewWEBM:SetVisible(false)
	end
end

function PANEL:Think()
	local panel = vgui.GetHoveredPanel()
	local key
	local world = vgui.GetWorldPanel()

	repeat
		key = panel.NecrosisBindPreviewKey

		if key then break end

		panel = panel:GetParent()
	until not IsValid(panel) or panel == world

	if key and key ~= self.CurrentPreview then
		self.CurrentPreview = key

		if key then self:SetBindPreview(key) end
	end
end

--post
derma.DefineControl("NecrosisSettingsMenuBinds", "", PANEL, "EditablePanel")