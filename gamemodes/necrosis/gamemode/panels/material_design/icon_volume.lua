--locals
local PANEL = {}
local volumes = {"volume_low", "volume_medium", "volume_high"}
local volumes_count = #volumes

--panel functions
function PANEL:SetVolume(volume) self:SetIcon(volume == 0 and "volume_off" or volumes[math.Round(math.Remap(volume, 0, 1, 1, volumes_count))]) end

--post
derma.DefineControl("NecrosisMaterialDesignIconVolume", "An icon made with a material design icon vector graphic.", PANEL, "NecrosisMaterialDesignIcon")