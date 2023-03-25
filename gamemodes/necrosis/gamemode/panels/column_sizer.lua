--locals
local PANEL = {}

--accessor functions
AccessorFunc(PANEL, "Columns", "Columns", FORCE_NUMBER)

--panel functions
function PANEL:Init() self:SetColumns(3) end

function PANEL:PerformLayout(width)
	local columns = self.Columns

	local children = self:GetChildren()
	local children_count = #children
	local child_spacing = math.floor(width / columns)
	local margin = math.ceil(width * 0.01)

	local child_size = child_spacing - margin

	for index, child in ipairs(children) do
		local x = (index - 1) % columns
		local y = math.floor((index - 1) / columns)
		local row_width = math.min(children_count - y * columns, columns) * (child_size + margin)

		child:SetPos((x * child_spacing * 2 - row_width + width + margin) * 0.5, y * child_spacing)
		child:SetSize(child_size, child_size)
	end

	self:SizeToChildren(false, true)
end

--post
derma.DefineControl("NecrosisColumnSizer", "Organizes children panels into rows of centered panels.", PANEL, "DSizeToContents")