--!strict

for _, manager: Instance in script:GetChildren() do
	if not manager:IsA("ModuleScript") then continue end

	task.spawn(function()
		debug.setmemorycategory(manager.Name)
		local requiredManager = require(manager) :: any
		requiredManager:Init()
	end)
end
