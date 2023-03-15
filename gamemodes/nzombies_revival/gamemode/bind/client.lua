--locals

--local tables
local bind_hooks = { --why did garry make these server side, and not in Lua? now I have to do this BS
	gm_showhelp = "ShowHelp",
	gm_showspare1 = "ShowSpare1",
	gm_showspare2 = "ShowSpare2",
	gm_showteam = "ShowTeam",
}

--gamemode functions
function GM:PlayerBindPress(_ply, bind, _pressed, _code)
	local method = bind_hooks[bind]
	
	if method then hook.Run(method) end
	
	return false
end

function GM:ShowTeam() self:UIMainMenuOpen() end