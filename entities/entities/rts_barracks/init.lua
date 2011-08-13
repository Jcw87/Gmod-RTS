AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local SpawnPoints = {
	{Vector(-128, -32, 32), Angle(0, 180, 0)},
	{Vector(-128, 32, 32), Angle(0, 180, 0)},
	{Vector(-64, -32, 32), Angle(0, 180, 0)},
	{Vector(-64, 32, 32), Angle(0, 180, 0)}
}

function ENT:Initialize()
	self:GetBaseClass("base_rts_thing").Initialize(self)
	self:SetModel("models/imperial/buildings/barracks/imp_barracks.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
	self.SpawnPoints = {}
	
	for k, v in pairs(SpawnPoints) do
		local spawn = ents.Create("info_player_teamspawn")
		spawn:SetParent(self)
		spawn:SetPos(self:LocalToWorld(v[1]))
		spawn:SetLocalAngles(v[2])
		spawn:Spawn()
		table.insert(self.SpawnPoints, spawn)
	end
end

function ENT:CallOnRemove()
	self:GetBaseClass("base_rts_thing").CallOnRemove(self)
	for k, v in pairs(self.SpawnPoints) do
		v:Remove()
	end
end

function ENT:GetSpawnPoint()
	if #self.SpawnPoints == 0 then ErrorNoHalt("No spawns for "..tostring(self).."\n") return end
	return table.Random(self.SpawnPoints)
end