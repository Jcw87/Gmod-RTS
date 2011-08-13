AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	if self:Team() == 0 then self:SetTeam(TEAM_UNASSIGNED) end
	minimap.Register(self)
end

function ENT:CallOnRemove()
	minimap.UnRegister(self)
end

function ENT:SetHealth(value) self:SetDTInt("Health", value) end
function ENT:SetMaxHealth(value) self:SetDTInt("MaxHealth", value) end
function ENT:SetTeam(id) self:SetDTInt("Team", id) end
