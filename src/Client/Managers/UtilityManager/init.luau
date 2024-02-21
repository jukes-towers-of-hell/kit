--!strict

local UtilityManager = { _hasInitialized = false }
function UtilityManager:Init()
	if UtilityManager._hasInitialized then return UtilityManager end
	UtilityManager._hasInitialized = true

	for _, module: Instance in script:GetDescendants() do
		if not module:IsA("ModuleScript") then continue end
		if module.Parent and module.Parent:IsA("ModuleScript") and module.Parent ~= script then continue end -- do not load submodules

		local util = require(module) :: any
		if typeof(util) == "function" then
			UtilityManager[module.Name] = util -- add it to the utility table with it's filename
		elseif typeof(util) == "table" then
			for utilName, utilFunc in util do
				UtilityManager[utilName] = utilFunc -- add it to the utility table with its function name
			end
		end
	end

	return UtilityManager
end

return UtilityManager
