ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Team")
	self:DTVar("Int", 1, "Health")
	self:DTVar("Int", 2, "MaxHealth")
end

function ENT:Health() return self:GetDTInt("Health") end
function ENT:GetMaxHealth() return self:GetDTInt("MaxHealth") end
function ENT:Team() return self:GetDTInt("Team") end