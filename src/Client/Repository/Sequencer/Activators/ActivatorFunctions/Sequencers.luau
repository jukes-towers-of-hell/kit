--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
return {
	priority = nil,
	check = function(scope: _T.Variables, sequenceData: _T.sequencerData)
		if not sequenceData.instance:IsA("Model") then return false end
		local isSequencer = scope.utility.checkConfig(sequenceData.instance, "LoadFromRepository") == "Sequencer"
		if isSequencer then scope.utility.applyPartOptimizations(sequenceData.instance:FindFirstChild("Toggle")) end

		return isSequencer
	end,
	activate = function(scope: _T.Variables, sequenceData: _T.sequencerData)
		local function requestSequencer() scope.communicators.request:Invoke("activate-sequencer", sequenceData.instance) end
		if sequenceData.canAwait then
			requestSequencer()
		else
			task.spawn(requestSequencer)
		end
	end,
}
