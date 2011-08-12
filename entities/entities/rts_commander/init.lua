AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:GetBaseClass("base_rts_thing").Initialize(self)
	self:SetModel("models/imperial/vehicles/ground/command/imp_command.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
	
	self:SetUseType(SIMPLE_USE)
end

function ENT:Use(ply)
	if ply and ply:IsPlayer() then
	
	end
end