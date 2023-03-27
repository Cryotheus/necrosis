--locals
local PANEL = {}

--panel functions
function PANEL:Init()
	local preview_scroller

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
				binder.BindPreviewKey = "kick"
				sizer.KickBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("necrosis_kick")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.kick")
			end

			do --melee binder
				local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
				binder.BindPreviewKey = "melee"
				sizer.MeleeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_melee")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.melee")
			end

			do --grenade binder
				local binder = vgui.Create("NecrosisBinderLabeled", left_panel)
				binder.BindPreviewKey = "grenade"
				sizer.GrenadeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_grenade")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.grenade")
			end

			do --special grenade binder
				local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
				binder.BindPreviewKey = "sepcial_grenade"
				sizer.SpecialGrenadeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_special_grenade")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("#necrosis.panels.settings_menu_binds.binder.sepcial_grenade")
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

		do --image
			local image = vgui.Create("DImage", preview_scroller)
			preview_scroller.PreviewImage = image

			image:Dock(TOP)
			image:SetImage("matsys_regressiontest/background")
			image:SetVisible(false)
		end
	end
end

function PANEL:PerformLayout(width)
	local divide = math.ceil(ScrH() * 0.02)

	self.PreviewScrollPanel:SetWide(math.ceil(width * 0.5) - divide)
	self.ScrollPanel:DockMargin(0, 0, divide, 0)
end

function PANEL:SetBindPreview(key)
	local image_path = "materials/necrosis/binding_previews/" .. key .. ".png"
	local preview_scroller = self.PreviewScrollPanel

	preview_scroller.HeaderLabel:SetText(details.Binder:GetText())

	if description then
		local label = preview_scroller.InfoLabel

		label:SetText("#necrosis.panels.settings_menu_binds.binder." .. key .. ".description")
		label:SetVisible(true)
	else preview_scroller.InfoLabel:SetVisible(false) end

	if file.Exists(image_path, "GAME") then
		local image = preview_scroller.PreviewImage

		image:SetImage(image_path)
		image:SetVisible(true)
	else preview_scroller.PreviewImage:SetVisible(false) end
end

function PANEL:Think()
	local panel = vgui.GetHoveredPanel()
	local world = vgui.GetWorldPanel()

	repeat
		local details = panel.BindPreviewKey

		if details then
			details.Binder = panel

			self:SetBindPreview(details)

			break
		end

		panel = panel:GetParent()
	until not IsValid(panel) or panel == world
end

--post
derma.DefineControl("NecrosisSettingsMenuBinds", "", PANEL, "EditablePanel")