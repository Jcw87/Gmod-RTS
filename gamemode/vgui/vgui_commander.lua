
local PANEL = {}

function PANEL:Init()
	self.SetPos(0, ScrH()-128)
	self:SetSize(ScrW(), 128)
	local List = vgui.Create("DListView")
	List:SetPos(0, 0)
	List:SetSize(128, 128)
	List:SetMultiSelect(false)
	List:AddColumn("Name")
	List:AddColumn("Cost")
	local Buildings = GAMEMODE:GetBuildings()
	for i=1, #Buildings do
		local building = Buildings[i]
		List:AddLine(building.name, tostring(building.cost))
	end
	function List:OnRowSelected(LineID, Line)
		Building = Buildings[LineID]
		RunConsoleCommand("rts_commander_building", tostring(LineID))
		GAMEMODE.Ghost:SetModel[Building.model]
	end
	self.List = List
end

vgui.Register("CommanderInterface", PANEL)
