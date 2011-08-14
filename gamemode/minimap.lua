local CLIENT = CLIENT
local SERVER = SERVER
local concommand = concommand
local file = file
local game = game
local hook = hook
local player = player
local surface = surface
local team = team
local usermessage = usermessage
local util = util
local Entity = Entity
local ErrorNoHalt = ErrorNoHalt
local LocalPlayer = LocalPlayer
local Material = Material
local pairs = pairs
local tonumber = tonumber
local tostring = tostring

module("minimap")

local x, y = 16, 16
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

local Ents = {}

function LoadEmpiresScript()
	local minimap_file = file.Read("resource/maps/"..game.GetMap()..".txt", true)
	if (!minimap_file) then
		ErrorNoHalt("Empires minimap file not found!\n")
	end
	local t = util.KeyValuesToTable(minimap_file or "")
	
	if (CLIENT) then
		map_material_name = t.image or ""
		map_material = Material(map_material_name)
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

if (SERVER) then
	local function mm_request_entity(ply, cmd, args)
		local entid = tonumber(args[1])
		local ent = Entity(entid)
		if !ent:IsValid() then return end
		local enttable = Ents[entid]
		if ent:Team() == ply:Team() || (enttable.cansee & ply:TeamMask() > 0) then
			umsg.Start("mm_type_update", ply)
			umsg.Short(entid)
			umsg.String(ent:GetClass())
			umsg.Short(ent:Team())
			umsg.End()
		end
	end
	concommand.Add("mm_request_entity", mm_request_entity)

	local t_plys, t_ents
	
	local function ServerThink()
		if (!t_plys) then
			t_plys = player.GetAll()
		end
		local ply = t_plys[1]
		if !ply then return end
		if (!t_ents) then
			t_ents = {}
			local ent
			for k, v in pairs(Ents) do
				ent = Entity(k)
				if (ply:Team() == ent:Team()) then
					table.insert(ent)
				end
			end
		end
		local count = math.max(#t_ents, 28)
		umsg.Start("mm_pos_update", ply)
		umsg.Char(count)
		for i=1, count do
			local ent = t_ents[i]
			umsg.Short(ent:EntIndex())
			local pos = ent:GetPos()
			umsg.Short(math.floor(pos.x))
			umsg.Short(math.floor(pos.y))
			umsg.Short(ent:IsPlayer() and (ent:EyeAngles().y - 90) or 0)
		end
		umsg.End()
		for i=1, count do table.remove(t_ents, 1) end
		if (#t_ents == 0) then
			t_ents = nil
			table.remove(t_plys, 1)
		end
		if (#t_plys == 0) then t_plys = nil end
	end
	hook.Add("Think", "MinimapServerThink", ServerThink)

	function Register(ent)
		local ent_id = ent:EntIndex()
		Ents[ent] = {}
	end

	function UnRegister(ent)
		local ent_id = ent:EntIndex()
		Ents[ent_id] = nil
	end
end

if (CLIENT) then
	local function mm_pos_update(um)
		local entid, x, y, ang
		local count = um:GetChar()
		for i=1, count do
			entid = um:ReadShort()
			if (!Ents[entid]) then
				Ents[entid] = {}
				RunConsoleCommand("minimap_request_entity", tostring(entid))
			end
			local enttable = Ents[entid]
			enttable.x = um:ReadShort()
			enttable.y = um:ReadShort()
			enttable.ang = um:ReadShort()
			
			
		end
	end
	usermessage.Hook("mm_pos_update", mm_pos_update)
	
	local function mm_type_update(um)
		local entid = um:ReadShort()
		if (!Ents[entid]) then Ents[entid] = {} end
		local enttable = Ents[entid]
		enttable.class = um:ReadString()
		enttable.team = um:ReadShort()
	end
	usermessage.Hook("mm_type_update", mm_type_update)
	
	local function ClientThink()
		for k, v in pairs(Ents) do
			local ent = Entity(k)
			if !ent:IsValid() then continue end
			v.class = ent:GetClass()
			v.team = ent:Team()
			local pos = k:GetPos()
			v.x = pos.x
			v.y = pos.y
			v.ang = k:IsPlayer() and (k:EyeAngles().y - 90) or 0
		end
	end
	hook.Add("Think", "MinimapClientThink", ClientThink)

	function SetRenderBounds(newx, newy, neww, newh)
		x, y, w, h = newx, newy, neww, newh
	end

	local Materials = {
		["player"] = Material("vgui/player"),
		["rts_barracks"] = Material("minimap/mmico_barracks")
	}
	
	function Draw()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x, y, w, h)
		if (map_material) then
			surface.SetMaterial(map_material)
			surface.DrawTexturedRect(x, y, w, h)
		end
		local ply = LocalPlayer()
		local pos, minix, miniy, color, angle
		--
		for k, v in pairs(player.GetAll()) do
			pos = v:GetPos()
			minix, miniy = WorldToMinimap(pos.x, pos.y)
			color = team.GetColor(v:Team())
			surface.SetMaterial(Materials[v:GetClass()])
			surface.SetDrawColor(color.r, color.g, color.b, color.a)
			local angle = v:IsPlayer() and (v:EyeAngles().y - 90) or 0
			surface.DrawTexturedRectRotated((minix*w) + x, (miniy*h) + y, 32, 32, angle)
		end
		--]]
		--[[
		for k, v in pairs(Ents) do
			if !v.ang or !v.team or k == ply:EntIndex() then continue end
			minix, miniy = WorldToMinimap(v.x, v.y)
			color = team.GetColor(v.team)
			surface.SetMaterial(Materials[v.Class])
			surface.SetDrawColor(color.r, color.g, color.b, color.a)
			surface.DrawTexturedRectRotated((minix*w) + x, (miniy*h) + y, 32, 32, v.ang)
		end
		--]]
		pos = ply:GetPos()
		minix, miniy = WorldToMinimap(pos.x, pos.y)
		surface.SetMaterial(Materials.player)
		surface.SetDrawColor(255, 255, 255, 128)
		surface.DrawTexturedRectRotated((minix*w) + x, (miniy*h) + y, 48, 48, ply:EyeAngles().y - 90)
		
		return true
	end
end
