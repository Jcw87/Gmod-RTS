local meta = FindMetaTable("Player")

function meta:IsCommander()
	return self._IsCommander
end

local TeamMasks = {
	[TEAM_BLUE] = TEAM_BLUE_MASK,
	[TEAM_RED] = TEAM_RED_MASK,
	[TEAM_YELLOW] = TEAM_YELLOW_MASK,
	[TEAM_GREEN] = TEAM_GREEN_MASK
}

function meta:TeamMask()
	return TeamMasks[self:Team()] or 0
end

if SERVER then
	function meta:SetCommander(bool)
		if type(bool) != "boolean" then error("PLAYER:SetCommander: boolean expected, got "..type(bool), 2) end
		self._IsCommander = bool
		if (bool) then
			self:SetGravity(0.00000001)
		else
			self:SetGravity(1)
		end
		umsg.Start("comm_mode_enable", self)
		umsg.Bool(bool)
		umsg.End()
	end
end
