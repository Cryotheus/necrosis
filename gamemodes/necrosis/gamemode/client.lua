--gamemode functions
function GM:Initialize()
	self:BindLoad()
	self:SharedInitialize()
end

function GM:InitPostEntity()
	PYRITION:DownloadList(
		"https://raw.githubusercontent.com/Cryotheus/necrosis/master/_download/",
		"sitemap.txt",
		"necrosis/download/"
	)
end