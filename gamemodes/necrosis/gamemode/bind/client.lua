--locals

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

--gamemode functions
function GM:PlayerBindPress(_ply, bind, pressed, _code)
	local method = bind_hooks[bind]
	
	if not pressed and block_binds[bind] then return true end
	if method then hook.Run(method) end
	
	return block_binds[bind] or false
end

function GM:ShowHelp() self:UIMainMenuOpen() end
function GM:ShowTeam() end