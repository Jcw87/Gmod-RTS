local SERVER = SERVER
local CLIENT = CLIENT

local TEAM_BLUE = TEAM_BLUE
local TEAM_RED = TEAM_RED
local TEAM_YELLOW = TEAM_YELLOW
local TEAM_GREEN = TEAM_GREEN

local table = table
local pairs = pairs
local type = type

module("spawnpoints")

local Spawns = {}
Spawns[TEAM_BLUE] = {}
Spawns[TEAM_RED] = {}
Spawns[TEAM_YELLOW] = {}
Spawns[TEAM_GREEN] = {}

local function GetSpawnGroup(teamid, groupid)
	local teamspawns = Spawns[ent:Team()]
	local highid = 10000+groupid
	local group = teamspawns[highid] or {["Enabled"] = false}
	teamspawns[highid] = group
	return group
end

function AddSpawnEntity(ent)
	local teamspawns = Spawns[ent:Team()]
	teamspawns[ent:GetID()] = ent
end

function RemoveSpawnEntity(ent)
	local teamspawns = Spawns[ent:Team()]
	teamspawns[ent:GetID()] = nil
end

function AddSpawnGroup(ent, groupid)
	local group = GetSpawnGroup(ent:Team(), groupid)
	table.insert(group, ent)
end

function EnableSpawnGroup(teamid, groupid)
	local group = GetSpawnGroup(ent:Team(), groupid)
	group.Enabled = true
end

function DisableSpawnGroup(teamid, groupid)
	local group = GetSpawnGroup(ent:Team(), groupid)
	group.Enabled = false
end

function GetNumSpawns(teamid)
	local teamspawns = Spawns[ent:Team()]
	local count = 0
	for k, v in pairs(teamspawns) do
		if type(v) == "Entity" or type(v) == "table" and v.Enabled then count = count + 1 end
	end
	return count
end

function SpawnPlayer(ply, spawnid)

end
