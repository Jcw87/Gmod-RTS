local CLIENT = CLIENT
local SERVER = SERVER
local file = file
local game = game
local player = player
local surface = surface
local team = team
local util = util
local ErrorNoHalt = ErrorNoHalt
local Material = Material
local pairs = pairs
local tonumber = tonumber

module("minimap")

local x, y = 0, 0
local w, h = 256, 256

local map_material
local map_material_name = ""
local map_texture

local image_left = 0
local image_top = 0
local image_right = 1
local image_bottom = 1

local map_left = -16384
local map_top = 16384
local map_right = 16384
local map_bottom = -16384

local tomini_ratio_x = 1
local tomini_ratio_y = 1

local sector_width = 256
local sector_width = 256

function Register(ent)

end

function LoadEmpiresScript()
	local minimap_file = file.Read("resource/maps/"..game.GetMap()..".txt", true)
	if (!minimap_file) then
		ErrorNoHalt("Empires minimap file not found!\n")
	end
	local t = util.KeyValuesToTable(minimap_file or "")
	
	if (CLIENT) then
		map_material_name = t.image or ""
		map_material = Material(t.image)
		map_texture = map_material:GetMaterialTexture("$basetexture")
		local texture_w = map_texture:GetActualWidth() or 64
		local texture_h = map_texture:GetActualHeight() or 64
	
		image_left = tonumber(t.min_image_x or 0) / texture_w
		image_top = tonumber(t.min_image_y or 0) / texture_h
		image_right = (tonumber(t.max_image_x or 64)) / texture_w
		image_bottom = (tonumber(t.max_image_y or 64)) / texture_h
	end

	map_left = tonumber(t.min_bounds_x or -16384)
	map_top = tonumber(t.min_bounds_y or 16384)
	map_right = tonumber(t.max_bounds_x or 16384)
	map_bottom = tonumber(t.max_bounds_y or -16384)
	
	tomini_ratio_x = (image_right - image_left) / (map_right - map_left)
	tomini_ratio_y = (image_bottom - image_top) / (map_bottom - map_top)
	
	sector_width = tonumber(t.sector_with or 256)
	sector_height = tonumber(t.sector_height or 256)
end

function WorldToMinimap(worldx, worldy)
	local minix = (worldx - map_left) * tomini_ratio_x + image_left
	local miniy = (worldy - map_top) * tomini_ratio_y + image_top
	return minix, miniy
end

if (CLIENT) then
	function SetRenderBounds(newx, newy, neww, newh)
		x, y, w, h = newx, newy, neww, newh
	end

	function Draw()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x, y, w, h)
		if (map_material) then
			surface.SetMaterial(map_material)
			surface.DrawTexturedRect(x, y, w, h)
		end
		for k, v in pairs(player.GetAll()) do
			local pos = v:GetPos()
			local minix, miniy = WorldToMinimap(pos.x, pos.y)
			local color = team.GetColor(v:Team())
			surface.SetMaterial(v.MinimapMaterial)
			surface.SetDrawColor(color.r, color.g, color.b, color.a)
			surface.DrawTexturedRectRotated((minix*w) + x, (miniy*h) + y, 32, 32, v:EyeAngles().y - 90)
		end
		return true
	end
end
