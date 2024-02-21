--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

return function(scope: _T.Variables)
	local deactivator, trove, shared, utility = scope.parent, scope.trove, scope.shared, scope.utility
	if not (deactivator and deactivator:IsA("BasePart")) then return end

	repeat
		task.wait()
	until shared.button_cache ~= nil

	local debounce = false
	local currentTrove = trove:Extend()
	currentTrove:Add(function() trove:Remove(currentTrove) end)
	currentTrove:AttachToInstance(deactivator)
	currentTrove:Connect(deactivator.Touched, function(toucher: BasePart)
		if debounce then return end
		if not utility.evaluateToucher(deactivator, toucher, deactivator) then return end

		local buttonActivated: boolean = utility.checkConfig(deactivator, "Activated")
		if typeof(buttonActivated) == "boolean" and not buttonActivated then return end

		debounce = true
		task.delay(0.25, function() debounce = false end)

		local isColorSpecific = utility.checkConfig(deactivator, "ColorSpecific")
		local deactivatorColor = utility.roundColor(deactivator.Color)
		for _, button in shared.button_cache.Buttons do
			if not (isColorSpecific and button.Color ~= deactivatorColor) then button.Pressed.Value = false end
		end
	end)
end
