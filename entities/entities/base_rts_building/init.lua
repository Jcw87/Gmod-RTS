AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:GetBaseClass("base_rts_thing").Initialize(self)
	if self:Health() == 0 then self:SetHealth(10) end
end
