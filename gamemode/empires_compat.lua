local ENT

// emp_info_params
ENT = {}
ENT.Type = "point"
ENT.Base = "base_point"
function ENT:Initialize()
	// There are only 2 teams in Empires
end
function ENT:KeyValue(key, value)

end
function ENT:AcceptInput(name, activator, caller, data)

end
scripted_ents.Register(ENT, "emp_info_params")

// emp_info_map_overview
ENT = {}
ENT.Type = "point"
ENT.Base = "base_point"
function ENT:Initialize()
	local ent = ents.Create("info_player_start")
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	self:Remove()
end

scripted_ents.Register(ENT, "emp_info_map_overview")

// Empires buildings
ENT = {}
ENT.Type = "point"
ENT.Base = "base_point"
ENT.EmpiresBuilding = true
function ENT:Initialize()
	local array = string.Explode("_", self:GetClass())
	if (array[3] == "imp") then self.TeamNum = TEAM_BLUE end
	if (array[3] == "nf") then self.TeamNum = TEAM_RED end
	self.BuildingType = array[4]
	
	local ent = ents.Create("rts_"..self.BuildingType)
	if !ent or !ent:IsValid() then return end
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:SetTeam(self.TeamNum)
	ent:SetName(self:GetName())
	ent.Outputs = self.Outputs
	ent:Spawn()
	self:Remove()
end
function ENT:KeyValue(key, value)
	if (key == "startBuilt") then self.IsBuilt = tonumber(value) return end
	if (key == "level") then self.TurretLevel = tonumber(value) return end
	if (key == "OnImpBuilt") then self:AddOutput("OnTeamBlueBuilt", value) return end
	if (key == "OnNFBuilt") then self:AddOutput("OnTeamRedBuilt", vaue) return end
	if (key == "OnKill") then self:AddOutput(key, value) return end
	//MsgN(self:GetClass()..": key: "..key.." value: "..value)
end

scripted_ents.Register(ENT, "emp_building_imp_armory")
scripted_ents.Register(ENT, "emp_building_imp_barracks")
scripted_ents.Register(ENT, "emp_building_imp_mgturret")
scripted_ents.Register(ENT, "emp_building_imp_mlturret")
scripted_ents.Register(ENT, "emp_building_imp_radar")
scripted_ents.Register(ENT, "emp_building_imp_refinery")
scripted_ents.Register(ENT, "emp_building_imp_repairstation")
scripted_ents.Register(ENT, "emp_building_imp_vehiclefactory")
scripted_ents.Register(ENT, "emp_building_nf_armory")
scripted_ents.Register(ENT, "emp_building_nf_barracks")
scripted_ents.Register(ENT, "emp_building_nf_mgturret")
scripted_ents.Register(ENT, "emp_building_nf_mlturret")
scripted_ents.Register(ENT, "emp_building_nf_radar")
scripted_ents.Register(ENT, "emp_building_nf_refinery")
scripted_ents.Register(ENT, "emp_building_nf_repairstation")
scripted_ents.Register(ENT, "emp_building_nf_vehiclefactory")

// Empires commander vehicle
ENT = {}
ENT.Type = "point"
ENT.Base = "base_point"
function ENT:Initialize()
	local array = string.Explode("_", self:GetClass())
	if (array[2] == "imp") then self.TeamNum = TEAM_BLUE end
	if (array[2] == "nf") then self.TeamNum = TEAM_RED end

	local ent = ents.Create("rts_commander")
	ent:SetPos(self:GetPos())
	ent:SetAngles(self:GetAngles())
	ent:SetTeam(self.TeamNum)
	ent:Spawn()
	self:Remove()
end

scripted_ents.Register(ENT, "emp_imp_commander")
scripted_ents.Register(ENT, "emp_nf_commander")