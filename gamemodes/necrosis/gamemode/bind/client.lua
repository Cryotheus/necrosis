--locals
local empty_function = function() end

--local tables
local bind_hooks = { --why did garry make these server side, and not in Lua? now I have to do this BS
	gm_showhelp = "ShowHelp",
	gm_showspare1 = "ShowSpare1",
	gm_showspare2 = "ShowSpare2",
	gm_showteam = "ShowTeam",
}

local block_binds = {
	gm_showspare1 = true,
	gm_showspare2 = true,
}

--local functions
local function read_file_string(file_object)
	local text = ""
	
	repeat
		local byte = file_object:ReadByte()
		
		if byte == 0 then break end
		
		text = text .. string.char(byte)
	until file_object:EndOfFile()
	
	return text
end

local function write_file_string(file_object, text)
	for index = 1, #text do file_object:WriteByte(string.byte(text, index)) end
	
	--null terminator
	file_object:WriteByte(0)
end

--globals
NECROSIS.Binds = NECROSIS.Binds or {}

--gamemode functions
function GM:BindLoad()
	local binds_file = file.Open("necrosis/binds.dat", "rb", "DATA")
	
	print("binds_file", binds_file)
	
	if not binds_file then return end
	
	local binds = NECROSIS.Binds
	
	print("emptying binds", binds)
	table.Empty(binds)
	
	repeat
		local code = binds_file:ReadByte()
		local command = read_file_string(binds_file)
		
		print("read", code, command)
		
		binds[code] = command
		binds[command] = code
	until binds_file:EndOfFile()
	
	print("done!")
	binds_file:Close()
end

function GM:BindOverride(code, command)
	if code <= 0 then return end
	
	local existing = NECROSIS.Binds[code]
	
	if existing then NECROSIS.Binds[existing] = nil end
	
	NECROSIS.Binds[code] = command
	NECROSIS.Binds[command] = code
	
	self:BindQueueSave()
end

function GM:BindQueueSave()
	local think_hooks = hook.GetTable().Think
	
	if think_hooks and think_hooks.NecrosisBind then return end
	
	hook.Add("Think", "NecrosisBind", function()
		hook.Remove("Think", "NecrosisBind")
		self:BindSave()
	end)
end

function GM:BindRestore(command)
	code = NECROSIS.Binds[command]
	
	--swap if we have the wrong order
	if isnumber(command) then command, code = code, command end
	
	NECROSIS.Binds[code] = nil
	NECROSIS.Binds[command] = nil
	
	self:BindQueueSave()
end

function GM:BindSave()
	file.CreateDir("necrosis")
	
	local binds_file = file.Open("necrosis/binds.dat", "wb", "DATA")
	
	if not binds_file then return end
	
	for code, command in pairs(NECROSIS.Binds) do
		if isnumber(code) then
			binds_file:WriteByte(code)
			write_file_string(binds_file, command)
		end
	end
	
	binds_file:Close()
end

function GM:Initialize() self:BindLoad() end

function GM:PlayerBindPress(_ply, bind, pressed, code)
	local method = bind_hooks[bind]
	local rebind = NECROSIS.Binds[code]
	
	if rebind then
		if not pressed and rebind[1] == "+" then RunConsoleCommand("-" .. string.sub(rebind, 2))
		else RunConsoleCommand(rebind) end
		
		return true
	end
	
	if not pressed and block_binds[bind] then return true end
	if method then hook.Run(method) end
	
	return block_binds[bind] or false
end

function GM:ShowHelp() self:UIMainMenuOpen() end
function GM:ShowTeam() end

--commands
concommand.Add("+necrosis_grenade", empty_function)
concommand.Add("-necrosis_grenade", empty_function)
concommand.Add("+necrosis_melee", empty_function)
concommand.Add("-necrosis_melee", empty_function)
concommand.Add("+necrosis_special_grenade", empty_function)
concommand.Add("-necrosis_special_grenade", empty_function)
concommand.Add("necrosis_kick", empty_function)
concommand.Add("+necrosis_throw", empty_function)
concommand.Add("-necrosis_throw", empty_function)