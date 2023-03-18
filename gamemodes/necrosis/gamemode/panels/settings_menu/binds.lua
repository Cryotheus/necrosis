--locals
local PANEL = {}

--panel functions
function PANEL:SetBindPreview(details)
	local description = details.Description
	local image_path = details.ImagePath
	local preview_scroller = self.PreviewScrollPanel

	preview_scroller.HeaderLabel:SetText(details.Binder:GetText())

	if description then
		local label = preview_scroller.InfoLabel

		label:SetText(description)
		label:SetVisible(true)
	else preview_scroller.InfoLabel:SetVisible(false) end

	if image_path then
		local image = preview_scroller.PreviewImage

		image:SetImage(image_path)
		image:SetVisible(true)
	else preview_scroller.PreviewImage:SetVisible(false) end
end

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
				binder.BindPreviewDetails = {
					Description = "Reliable melee attack that can be used even if your hands are busy. Might not be the strongest, but it can buy you the time you need to reload.",
					ImagePath = nil, --TODO: make an image for the Melee Kick binder
				}

				sizer.KickBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("necrosis_kick")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("Melee Kick")
			end

			do --melee binder
				local binder = vgui.Create("NecrosisBinderLabeled", right_panel)
				binder.BindPreviewDetails = {
					Description = "Save your ammunition by using your melee weapon to attack. This will interrupt your weapon's reload, but deal more damage than a kick and your melee weapon can even be upgraded. Melee kills reward more points at the expense of your own safety.",
					ImagePath = nil, --TODO: make an image for the Melee Attack binder
				}

				sizer.MeleeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_melee")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("Melee Attack")
			end

			do --grenade binder
				local binder = vgui.Create("NecrosisBinderLabeled", left_panel)

				binder.BindPreviewDetails = {
					Description = "Sometimes bullets won't cut it, but grenades most certainly will. Grenades can take out multiple enemies at once, but supplies are scarce so use them wisely.",
					ImagePath = nil, --TODO: make an image for the Throw Grenade binder
				}

				sizer.GrenadeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_grenade")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("Throw Grenade")
			end

			do --special grenade binder
				local binder = vgui.Create("NecrosisBinderLabeled", right_panel)

				binder.BindPreviewDetails = {
					Description = "Sometimes killing is not enough to survive. Special grenades are a class of grenades that can do more than just kill, they can stall enemies, heal allies, or even give you a safe place to rest for a moment.",
					ImagePath = nil, --TODO: make an image for the Throw Special Grenade binder
				}

				sizer.SpecialGrenadeBinderPanel = binder

				binder:Dock(TOP)
				binder:SetCommand("+necrosis_special_grenade")
				binder:SetHeight(120)
				binder:SetNecrosisFont("Small")
				binder:SetText("Throw Special Grenade")
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
			label:SetText("Binding Details")
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
			label:SetText("Hover over a binder to view more information.")
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

function PANEL:Think()
	local panel = vgui.GetHoveredPanel()
	local world = vgui.GetWorldPanel()

	repeat
		local details = panel.BindPreviewDetails

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