local meta = FindMetaTable("Player")

function meta:IsCommander()
	return self:GetNetworkedBool("IsCommander")
end

if SERVER then
	function meta:SetCommander(bool)
		if type(bool) != "boolean" then error("PLAYER:SetCommander: boolean expected, got "..type(bool), 2) end
		self:SetNetworkedBool("IsCommander", bool)
		if (bool) then
			self:SetGravity(0.00000001)
		else
			self:SetGravity(1)
		end
	end
end
