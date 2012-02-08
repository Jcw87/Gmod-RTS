local function comm_death(ply)
	if ply:IsCommander() then ply:SetCommander(false) end
end
hook.Add("PlayerDeath", "comm_death", comm_death)

local function rts_commander_place_building(ply, cmd, args)
	if !ply:IsCommander() then return end
	local ID = tonumber(args[1])
	if ID == 0 then return end
	local Pos = Vector(tonumber(args[2]), tonumber(args[3]), tonumber(args[4]))
	local Ang = tonumber(args[5])
	if !GAMEMODE:CanPlaceBuilding(ID, Pos) then return end
	local Building = GAMEMODE:GetBuildings()[ID]
	local ent = ents.Create(Building.class)
	ent:SetPos(Pos)
	ent:SetAngles(Angle(0, Ang, 0))
	ent:SetTeam(ply:Team())
	ent:Spawn()
end
concommand.Add("rts_commander_place_building", rts_commander_place_building)