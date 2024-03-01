--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
return function(scope: _T.Variables, deactivator: BasePart, deactivate: () -> ())
	local shared, utility = scope.shared, scope.utility

	if shared.buttonDeactivator_cache == nil then shared.buttonDeactivator_cache = {} end
	shared.buttonDeactivator_cache[deactivator] = deactivate

	scope.trove:Add(task.spawn(function()
		local startTime = os.clock()
		repeat
			task.wait()
		until shared.sequencer_cache ~= nil or (os.clock() - startTime) >= 1

		local sequencerCache = shared.sequencer_cache
		if not sequencerCache then return end
		sequencerCache.addActivator("ButtonDeactivator", {
			check = function(_, sequenceData)
				if not sequenceData.instance:IsA("BasePart") then return false end
				local isDeactivator = scope.utility.checkConfig(sequenceData.instance, "LoadFromRepository") == "ButtonDeactivator"
				if isDeactivator then utility.applyPartOptimizations(sequenceData.instance) end

				return isDeactivator
			end,

			activate = function(_, sequenceData)
				local deactivatorFunc = shared.buttonDeactivator_cache[sequenceData.instance]
				if typeof(deactivatorFunc) == "function" then task.spawn(deactivatorFunc) end
			end,
		})
	end))
end
