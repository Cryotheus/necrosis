GM.Author = "Cryotheum#4096, Sinclair"
GM.Email = "N/A"
GM.Name = "Necrosis"
GM.TeamBased = false
GM.Version = "0.1.0"
GM.Website = "https://github.com/Cryotheus/necrosis"

if false then DeriveGamemode("base")
else --for debug only
	NECROSIS_OldSendLua = NECROSIS_OldSendLua or FindMetaTable("Player").SendLua

	--we have to do this because we can't override sandbox's ShowHelp method
	FindMetaTable("Player").SendLua = function(ply, script, ...)
		if script == "hook.Run( 'StartSearch' )" then return end

		return NECROSIS_OldSendLua(ply, script, ...)
	end

	DeriveGamemode("sandbox")
end

--post
include("loader.lua")