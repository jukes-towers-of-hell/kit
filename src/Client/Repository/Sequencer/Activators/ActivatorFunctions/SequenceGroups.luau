--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
return {
	priority = nil,
	check = function(scope: _T.Variables, sequenceData: any)
		if sequenceData.instance.Name ~= "SequenceGroup" then return false end

		local groupData = {}
		for _, child: Instance in sequenceData.instance:GetChildren() do
			if not child:IsA("PVInstance") then continue end
			local newSequenceData = { instance = child, canAwait = scope.utility.hasTag(child, "AwaitSequence"), hasPassed = false }
			local activators = scope.shared.sequencer_cache.fetchActivators(newSequenceData)
			if #activators <= 0 then continue end
			table.insert(groupData, { activators = activators, data = newSequenceData })
		end

		local canContinue = #groupData > 0
		if canContinue then sequenceData.groupActivators = groupData end
		return canContinue
	end,

	activate = function(scope: _T.Variables, sequenceData: any)
		local activators = sequenceData.groupActivators
		if not activators then return end

		local randomActivator = activators[Random.new():NextInteger(1, #activators)]
		for _, activator in randomActivator.activators do
			local success, errorMessage: string? = pcall(activator, scope, randomActivator.data)
			if (not success) and typeof(errorMessage) == "string" then warn(`sequencer error: {errorMessage}`) end
		end
	end,
}
