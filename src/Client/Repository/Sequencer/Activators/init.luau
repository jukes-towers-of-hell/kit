--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local activatorFunctions = script.ActivatorFunctions
return function(scope: _T.Variables)
	local shared, communicators = scope.shared, scope.communicators
	if shared.sequencer_cache == nil then
		local cacheReference = {
			sequencers = {} :: { [Model]: () -> () },
			activators = {} :: {
				[string]: {
					check: (scope: _T.Variables, sequenceData: _T.sequencerData) -> boolean,
					activate: (scope: _T.Variables, sequenceData: _T.sequencerData) -> (),
					priority: number?,
				},
			},
		}

		shared.sequencer_cache = cacheReference
		communicators.request:Add("activate-sequencer", function(sequencerToActivate: Model)
			local cachedSequencer = cacheReference.sequencers[sequencerToActivate]
			if typeof(cachedSequencer) ~= "function" then return end
			cachedSequencer()
		end)

		-- Handle Activators --

		-- add in sequencer activators --
		cacheReference.activators["Killbricks"] = require(activatorFunctions.Killbricks)
		cacheReference.activators["Sequencers"] = require(activatorFunctions.Sequencers)
		cacheReference.activators["Sequence Groups"] = require(activatorFunctions.SequenceGroups)

		-- fetch activators function --
		function cacheReference.fetchActivators(sequenceData: _T.sequencerData)
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
