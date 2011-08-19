local Materials = {
	["player"] = Material("vgui/player"),
	["rts_barracks"] = Material("minimap/mmico_barracks")
}

local PANEL = {}

function PANEL:Init()
	self:SetPos(16, 16)
	self:SetSize(256, 256)
end

function PANEL:Paint()
	local Ents = minimap.GetEnts()
	local w, h = self:GetSize()
	surface.SetDrawColor(64, 64, 64, 255)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(255, 255, 255, 255)
	local map_material = minimap.GetMapMaterial()
	if map_material then
		surface.SetMaterial(map_material)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	local image_left, image_right, image_top, image_bottom = minimap.GetImageBounds()
	for i=1, #minimap.VLines do
		local linepos = minimap.VLines[i]
		surface.DrawLine(linepos*w, image_top*h, linepos*w, image_bottom*h)
	end
	for i=1, #minimap.HLines do
		local linepos = minimap.HLines[i]
		surface.DrawLine(image_left*w, linepos*h, image_right*w, linepos*h)
	end
	
	local ply = LocalPlayer()
	local pos, minix, miniy, color, angle
	for k, v in pairs(Ents) do
		if !v.ang or !v.team or k == ply:EntIndex() then continue end
		minix, miniy = minimap.WorldToMinimap(v.x, v.y)
		color = team.GetColor(v.team)
		mat = Materials[v.class]
		if !mat then continue end
		local size = v.class == "player" and 32 or 24
		surface.SetMaterial(mat)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.DrawTexturedRectRotated((minix*w), (miniy*h), size, size, v.ang)
	end
	pos = ply:GetPos()
	minix, miniy = minimap.WorldToMinimap(pos.x, pos.y)
	surface.SetMaterial(Materials.player)
	surface.SetDrawColor(255, 255, 255, 128)
	surface.DrawTexturedRectRotated((minix*w), (miniy*h), 48, 48, ply:EyeAngles().y - 90)
	
	surface.SetFont("Trebuchet20")
	surface.SetTextPos(4, image_bottom*h - 20)
	surface.SetTextColor(255, 255, 255 ,255)
	surface.DrawText("("..minimap.GetSector(LocalPlayer():GetPos())..")")
		
	return true
end
	
vgui.Register("Minimap", PANEL)