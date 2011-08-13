AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("minimap.lua")
AddCSLuaFile("spawnpoints.lua")
AddCSLuaFile("entity_extension.lua")
AddCSLuaFile("player_extension.lua")

include("shared.lua")

include("point_entities.lua")
include("empires_compat.lua")

function GM:InitPostEntity()
	GAMEMODE:CreateTeams()
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	minimap.Register(ply)
	umsg.Start("UpdateTeams", ply)
	umsg.Char(GAMEMODE.TeamMask)
	umsg.End()
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	minimap.UnRegister(ply)
end

function GM:PlayerSelectTeamSpawn(teamid, ply)
	if ply:Team() == TEAM_UNASSIGNED then return end
	local barracks_list = ents.FindByClass("rts_barracks")
	for k, v in pairs(barracks_list) do
		if v:Team() != ply:Team() then barracks_list[k] = nil end
	end
	if #barracks_list == 0 then return end
	local barracks = table.Random(barracks_list)
	if barracks then return barracks:GetSpawnPoint() end
end
