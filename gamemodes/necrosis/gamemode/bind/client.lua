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

--globals
NECROSIS.Binds = NECROSIS.Binds or {}

--gamemode functions
function GM:PlayerBind(code, command)
	if code <= 0 then return end
	
	local existing = NECROSIS.Binds[code]
	
	if existing then NECROSIS.Binds[existing] = nil end
	
	NECROSIS.Binds[code] = command
	NECROSIS.Binds[command] = code
end

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