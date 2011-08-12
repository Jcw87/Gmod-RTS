local meta = FindMetaTable("Entity")

function meta:GetBaseClass(name)
	local Base = self.BaseClass
	while true do
		if Base.ClassName == name then return Base end
		if !Base.BaseClass then return end
		Base = Base.BaseClass
	end
end

if (SERVER) then
	function meta:AddOutput(name, value)
		if !self.Outputs then self.Outputs = {} end
		if !self.Outputs[name] then self.Outputs[name] = {} end
		table.insert(self.Outputs[name], value);
	end

	function meta:FireOutput(name)
		if !self.Outputs or !self.Outputs[name] then return end

		for k, v in pairs(self.Outputs[name]) do
			local output = string.Explode(",", v);
			local targets = ents.FindByName(output[1]);

			for _, ent in pairs(targets) do
				ent:Fire(output[2], output[3], tonumber(output[4]));
			end

			if(output[5] == "1") then
				self.Outputs[name][k] = nil
			end
		end
	end
end