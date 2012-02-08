commander = {}
commander.Building = 0

function commander.SetBuilding(ID)
	local Building = GAMEMODE:GetBuildings()[ID]
	commander.Ghost:SetModel(Building.model)
	commander.Building = ID
end

local function init()
	local Ghost = ClientsideModel("models/imperial/buildings/refinery/imp_refinery.mdl", RENDERGROUP_TRANSLUCENT)
	Ghost:SetColor(0, 0, 0, 0)
	commander.Ghost = Ghost
	commander.Panel = vgui.Create("CommanderInterface")
	commander.Panel:SetVisible(false)
end
hook.Add("PostGamemodeLoaded", "comm_init", init)

local function think()
	if commander.Building > 0 then
		local Pos = LocalPlayer():GetEyeTrace().HitPos
		commander.Ghost:SetPos(Pos)
		if !GAMEMODE:CanPlaceBuilding(commander.Building, Pos, commander.Ghost:GetAngles().y) then
			commander.Ghost:SetColor(255, 0, 0, 128)
		else
			commander.Ghost:SetColor(0, 255, 0, 128)
		end
	else	
		commander.Ghost:SetColor(0, 0, 0, 0)
	end
end
hook.Add("Think", "comm_think", think)

local function comm_mouse(mc, aim)
	if !LocalPlayer():IsCommander() then return end
	local BuildingID = commander.Building
	if mc == MOUSE_LEFT and BuildingID > 0 then
		local Pos = LocalPlayer():GetEyeTrace().HitPos
		local Ang = commander.Ghost:GetAngles().y
		if !GAMEMODE:CanPlaceBuilding(BuildingID, Pos, Ang) then return end
		RunConsoleCommand("rts_commander_place_building", tostring(BuildingID), tostring(Pos.x), tostring(Pos.y), tostring(Pos.z), tostring(Ang))
	end
	if mc == MOUSE_RIGHT then
		commander.Building = 0
	end
end
hook.Add("GUIMousePressed", "comm_mouse", comm_mouse)

local function comm_hud()
	local ID = commander.Building
	if ID > 0 then
		local r, g, b = commander.Ghost:GetColor()
		surface.SetDrawColor(r, g, b, 255)
		local Pos = commander.Ghost:GetPos()
		local p1 = (Pos + Vector(-128, -128, 0)):ToScreen()
		local p2 = (Pos + Vector(128, -128, 0)):ToScreen()
		local p3 = (Pos + Vector(128, 128, 0)):ToScreen()
		local p4 = (Pos + Vector(-128, 128, 0)):ToScreen()
		surface.DrawLine(p1.x, p1.y, p2.x, p2.y)
		surface.DrawLine(p2.x, p2.y, p3.x, p3.y)
		surface.DrawLine(p3.x, p3.y, p4.x, p4.y)
		surface.DrawLine(p4.x, p4.y, p1.x, p1.y)
	end
end
hook.Add("HUDPaint", "comm_hud", comm_hud)

local function comm_mode_enable(um)
	local bool = um:ReadBool()
	LocalPlayer()._IsCommander = bool
	gui.EnableScreenClicker(bool)
	commander.Panel:SetVisible(bool)
	commander.Building = 0
end
usermessage.Hook("comm_mode_enable", comm_mode_enable)
