local ENT

// info_rts
ENT = {}
ENT.Type = "point"
ENT.Base = "base_point"

function ENT:Initialize()
end

function ENT:KeyValue(key, value)

end

scripted_ents.Register(ENT, "info_rts")

// Spawns
ENT = {}
ENT.Type = "point"
ENT.Base = "base_point"

scripted_ents.Register(ENT, "info_player_teamspawn")
