include("shared.lua")

include("vgui/vgui_commander.lua")
include("vgui/vgui_minimap.lua")
include("cl_commander.lua")
include("cl_hud.lua")

local function UpdateTeams(um)
	GAMEMODE.TeamMask = um:ReadChar()
	GAMEMODE:CreateTeams()
end

usermessage.Hook("UpdateTeams", UpdateTeams)
