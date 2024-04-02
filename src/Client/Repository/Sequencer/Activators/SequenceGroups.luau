--!strict

-->insert-repository-warning<--

local validModes = {
	"random",
	"and",
	"or",
	"",
}

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local function runSequence(scope: _T.Variables, sequence, passedVariables)
	for _, activator in sequence.activators do
		local success, errorMessage: string? = pcall(activator, scope, sequence.data, passedVariables)
		if (not success) and typeof(errorMessage) == "string" then warn(`sequencer error: {errorMessage}`) end
	end
end

return {
	priority = nil,
	check = function(scope: _T.Variables, sequenceData: any)
		if sequenceData.instance.Name ~= "SequenceGroup" then return false end

		local utility, shared = scope.utility, scope.shared
		local groupData = {}
		local currentMode = utility.getConfig(sequenceData.instance, "GroupMode", validModes[1])
		currentMode = if table.find(validModes, currentMode) then currentMode else validModes[1]

		local forceAwait = false
		if (currentMode == validModes[2]) or (currentMode == validModes[3]) then -- force await mode
			sequenceData.canAwait = true
			forceAwait = true
		end

		for _, child: Instance in sequenceData.instance:GetChildren() do
			if not child:IsA("PVInstance") then continue end
			local newSequenceData = {
				instance = child,
				canAwait = forceAwait or utility.hasTag(child, "AwaitSequence"),
				hasPassed = false,
				activatorData = {},
			}

			local activators = shared.sequencer_cache.fetchActivators(newSequenceData)
			if #activators <= 0 then continue end
			table.insert(groupData, { activators = activators, data = newSequenceData })
		end

		local canContinue = #groupData > 0
		if canContinue then sequenceData.activatorData.sequenceGroups = { sequences = groupData, mode = currentMode } end
		return canContinue
	end,

	activate = function(scope: _T.Variables, sequenceData: any, passedVariables: { [any]: any })
		local currentData = sequenceData.activatorData.sequenceGroups
		if not currentData then return end

		local sequences = currentData.sequences
		local mode = currentData.mode
		if mode == validModes[1] then -- random mode
			local randomSequence = sequences[Random.new():NextInteger(1, #sequences)]
			runSequence(scope, randomSequence, passedVariables)
		elseif (mode == validModes[2]) or (mode == validModes[3]) then -- and/or mode
			local currentThreads = {}
			for _, sequence in sequences do
				table.insert(currentThreads, task.spawn(runSequence, scope, sequence, passedVariables))
			end

			local totalThreads = if mode == validModes[2] then #currentThreads else 1
			while true do
				local threadsFinished = 0
				for _, thread in currentThreads do
					if coroutine.status(thread) ~= "dead" then continue end
					threadsFinished += 1
				end

				if threadsFinished >= totalThreads then break end
				task.wait()
			end

			for _, thread in currentThreads do
				task.cancel(thread)
			end

			currentThreads = nil :: any
		end
	end,
}
