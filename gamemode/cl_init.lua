include("shared.lua")

include("vgui/vgui_minimap.lua")
include("cl_hud.lua")

CreateClientConVar( "rts_commander_building", 0, false, false )

function GM:Think()
	if LocalPlayer():IsCommander() then
		GAMEMODE.Prop:SetPos(LocalPlayer():GetEyeTrace())
	end
end

local function UpdateTeams(um)
	GAMEMODE.TeamMask = um:ReadChar()
	GAMEMODE:CreateTeams()
end

usermessage.Hook("UpdateTeams", UpdateTeams)
