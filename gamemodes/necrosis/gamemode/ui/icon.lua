--locals
local html_panel
local render_delay = 2
local render_queue_index = 0
local render_target_size = 512

--globals
NECROSIS.UIIconRenderQueue = NECROSIS.UIIconRenderQueue or {}
NECROSIS.UIIconRenderTargetRepository = NECROSIS.UIIconRenderTargetRepository or {}
NECROSIS.UIIconRenderTargets = NECROSIS.UIIconRenderTargets or {}

--[[
NECROSIS.UIIconRenderTargetRepository = {
	[size] = {
		[render_target_index] = {
			Contains = {
				[name] = true,
				[name] = true,
				[name] = true,
				[name] = true,
			},
			
			PositionIndex = number,
			Material = IMaterial,
			Texture = ITexture,
		}
	}
}	

NECROSIS.UIIconRenderTargets = {
	[name] = {
		[size] = {render_target_index, x, y},
		[size] = {render_target_index, x, y},
		[size] = {render_target_index, x, y},
		[size] = {render_target_index, x, y}
	}
}
]]

--local functions
local function get_html(size, code)
	return [[<p style="color:white;font-size:]]
		.. size
		.. [[px;font-family:'Material Design Icons';src:url('https://wiki.facepunch.com/fonts/materialdesignicons-webfont.woff2?v=5.9.55');">&#x]]
		.. string.format("%x", code)
		.. [[</p>]]
end

--gamemode functions
function GM:UIIconCreate(icon_name, size)
	local first
	local material
	local maximum_icon_length = math.floor(render_target_size / size)
	local maximum_icon_count = maximum_icon_length * maximum_icon_length
	local position_index = 0
	local render_target
	local render_target_index = 1
	local render_targets = NECROSIS.UIIconRenderTargetRepository[size]
	
	if not render_targets then
		render_targets = {}
		NECROSIS.UIIconRenderTargetRepository[size] = render_targets
	end
	
	local render_targets_count = #render_targets
	local render_target_details = render_targets[render_targets_count]
	
	if render_target_details and render_target_details.PositionIndex <= maximum_icon_count then
		--fetch some data
		material = render_target_details.Material
		position_index = render_target_details.PositionIndex
		render_target = render_target_details.Texture
		render_target_index = render_targets_count
		
		--increment the position index
		render_target_details.Contains[icon_name] = true
		render_target_details.PositionIndex = position_index + 1
	else
		material = CreateMaterial("necrosis_icon_materials/" .. size .. "/" .. render_targets_count, "UnlitGeneric", {
			--["$alphatest"] = 1,
			--["$alphatestreference"] = 0.5,
			--["$ignorez"] = 1,
			--["$nolod"] = 1,
			["$basetexture"] = "gui/corner512",
			["$translucent"] = 1,
			["$vertexalpha"] = 1,
			["$vertexcolor"] = 1,
		})
		
		render_target = GetRenderTargetEx(
			"necrosis_icon_textures/" .. size .. "/" .. render_targets_count,
			render_target_size, render_target_size,
			RT_SIZE_OFFSCREEN,
			MATERIAL_RT_DEPTH_NONE,
			256, --no mips
			0,
			IMAGE_FORMAT_RGBA8888
		)
		
		render_target_details = {
			Contains = {[icon_name] = true},
			Material = material,
			PositionIndex = 1,
			Texture = render_target,
		}
		
		first = true --to clear the target
		render_targets[render_targets_count + 1] = render_target_details
		
		--only need to do this once
		material:SetTexture("$basetexture", render_target)
	end
	
	local x = position_index % maximum_icon_length * size
	local y = math.floor(position_index / maximum_icon_length) * size
	local icon_sizes = NECROSIS.UIIconRenderTargets[icon_name]
	
	if not icon_sizes then
		icon_sizes = {[size] = {render_target_index, x, y}}
		NECROSIS.UIIconRenderTargets[icon_name] = icon_sizes
	else NECROSIS.UIIconRenderTargets[icon_name][size] = {render_target_index, x, y} end
	
	table.insert(NECROSIS.UIIconRenderQueue, {
		Code = PYRITION:GFXMaterialDesignIconCode(icon_name),
		First = first,
		RenderTarget = render_target,
		Size = size,
		X = x,
		Y = y,
	})
	
	if hook.GetTable().Think and hook.GetTable().Think.NecrosisUIIconRender then return material, x, y end
	
	html_panel = vgui.Create("HTML")
	render_queue_index = 1
	local html_set = false
	local wait
	
	html_panel:SetPos(0, 0)
	html_panel:SetSize(render_target_size, render_target_size)
	
	function html_panel:OnRemove() html_panel = nil end
	
	hook.Add("HUDPaint", "NecrosisUIIconRender", function()
		local real_time = RealTime()
		
		if wait and wait < real_time then return
		else wait = nil end
		
		local queue_info = NECROSIS.UIIconRenderQueue[render_queue_index]
		
		if queue_info then
			if html_set then
				if html_panel:IsLoading() then return end
				
				html_panel:UpdateHTMLTexture()
				
				local html_material = html_panel:GetHTMLMaterial()
				
				if not html_material then return end
				
				if need_load_wait then
					need_load_wait = false
					wait = real_time + render_delay
					
					return
				end
				
				--render it
				render.PushRenderTarget(queue_info.RenderTarget)
					if queue_info.First then
						--render.Clear(255, 255, 255, 0, true, true)
						render.Clear(255, 255, 255, 0)
					end
					
					cam.Start2D()
						render.PushFilterMag(TEXFILTER.POINT)
						render.PushFilterMin(TEXFILTER.POINT)
							surface.SetDrawColor(255, 255, 255)
							surface.SetMaterial(html_material)
							surface.DrawTexturedRect(queue_info.X - 8, queue_info.Y - 8, html_material:Width(), html_material:Height())
						render.PopFilterMag()
						render.PopFilterMin()
					cam.End2D()
				render.PopRenderTarget()
				
				html_set = false
				render_queue_index = render_queue_index + 1
			else
				html_set = true
				need_load_wait = true
				
				html_panel:SetHTML(get_html(queue_info.Size, queue_info.Code))
			end
		else
			local queue = NECROSIS.UIIconRenderQueue
			
			for index = 1, render_queue_index - 1 do queue[index] = nil end
			
			hook.Remove("HUDPaint", "NecrosisUIIconRender")
			html_panel:Remove()
		end
	end)
	
	return material, x, y
end

function GM:UIIconGet(icon_name, size)
	local icon_sizes = NECROSIS.UIIconRenderTargets[icon_name]
	
	if icon_sizes then
		local icon_details = icon_sizes[size]
		
		if icon_details then return NECROSIS.UIIconRenderTargetRepository[size][icon_details[1]].Material, icon_details[2], icon_details[3] end
	end
	
	return self:UIIconCreate(icon_name, size)
end