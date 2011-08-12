include("shared.lua")

include("cl_hud.lua")

local function UpdateTeams(um)
	GAMEMODE.TeamMask = um:ReadChar()
	GAMEMODE:CreateTeams()
end

usermessage.Hook("UpdateTeams", UpdateTeams)