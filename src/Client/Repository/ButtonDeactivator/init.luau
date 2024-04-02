--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local sequencerManager = require(script.SequencerManager)

return function(scope: _T.Variables)
	local deactivator, trove, shared, utility = scope.parent, scope.trove, scope.shared, scope.utility
	if not (deactivator and deactivator:IsA("BasePart")) then return end

	repeat
		task.wait()
	until shared.button_cache ~= nil

	local function deactivate()
		local isColorSpecific = utility.checkConfig(deactivator, "ColorSpecific")
		local deactivatorColor = utility.roundColor(deactivator.Color)
		for _, button in shared.button_cache.Buttons do
			if not (isColorSpecific and button.Color ~= deactivatorColor) then button.Pressed.Value = false end
		end
	end

	local currentTrove = trove:Extend()
	currentTrove:Add(function() trove:Remove(currentTrove) end)
	currentTrove:AttachToInstance(deactivator)

	if utility.isSequence(deactivator) then -- listen for sequencer events
		sequencerManager(scope, deactivator, deactivate)
	else -- otherwise just listen to the touched signal
		local debounce = false
		currentTrove:Connect(deactivator.Touched, function(toucher: BasePart)
			if debounce then return end
			if not utility.evaluateToucher(deactivator, toucher, deactivator) then return end
			if utility.checkConfig(deactivator, "Activated") == false then return end

			debounce = true
			task.delay(0.25, function() debounce = false end)
			deactivate()
		end)
	end
end
