--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

export type sequencerActivator = (scope: _T.Variables, sequenceData: sequencerData) -> ()
export type sequencerData = {
	canAwait: boolean,
	instance: PVInstance,
	activators: { sequencerActivator }?,
	hasPassed: boolean,
	groupActivators: { { activators: { sequencerActivator }, data: sequencerData } }?,
}

export type activatorData = {
	check: (scope: _T.Variables, sequenceData: sequencerData) -> boolean,
	activate: sequencerActivator,
	priority: number?,
}

local activatorFunctions = script.ActivatorFunctions
return function(scope: _T.Variables)
	local shared, communicators = scope.shared, scope.communicators
	if shared.sequencer_cache == nil then
		local cacheReference = {
			sequencers = {} :: { [Model]: () -> () },
			activators = {} :: { [string]: activatorData },
		}

		shared.sequencer_cache = cacheReference
		communicators.request:Add("activate-sequencer", function(sequencerToActivate: Model)
			local cachedSequencer = cacheReference.sequencers[sequencerToActivate]
			if typeof(cachedSequencer) ~= "function" then return end
			cachedSequencer()
		end)

		-- Handle Activators --

		-- add in sequencer activators --
		function cacheReference.addActivator(name: string, data: activatorData)
			if cacheReference.activators[name] ~= nil then return end
			if not (typeof(data) == "table" and typeof(data.check) == "function" and typeof(data.activate) == "function") then
				return
			end

			cacheReference.activators[name] = data
		end

		cacheReference.addActivator("Killbricks", require(activatorFunctions.Killbricks))
		cacheReference.addActivator("Sequencers", require(activatorFunctions.Sequencers))
		cacheReference.addActivator("SequenceGroups", require(activatorFunctions.SequenceGroups))

		-- fetch activators function --
		function cacheReference.fetchActivators(sequenceData: sequencerData)
			-- sort out the activators --
			local sortTable = {}
			for _, activator in cacheReference.activators do
				if not activator.check(scope, sequenceData) then continue end
				table.insert(sortTable, {
					activator = activator.activate,
					priority = activator.priority or math.huge,
				})
			end

			table.sort(sortTable, function(a, b) return a.priority < b.priority end)

			-- return all activator functions --
			local activators = {}
			for sort, activator in sortTable do
				activators[sort] = activator.activator
			end
			return activators
		end
	end

	task.wait()
	return shared.sequencer_cache.fetchActivators
end
