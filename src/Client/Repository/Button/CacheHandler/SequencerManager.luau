--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
return function(scope: _T.Variables)
	local shared, utility = scope.shared, scope.utility
	scope.trove:Add(task.spawn(function()
		local startTime = os.clock()
		repeat
			task.wait()
		until shared.sequencer_cache ~= nil or (os.clock() - startTime) >= 1

		local sequencerCache = shared.sequencer_cache
		if not sequencerCache then return end

		-- NUMBER 1 PRIORITY: BUTTON ACTIVATED PLATFORMS
		sequencerCache.addActivator("ButtonActivatedPlatforms", {
			priority = 1,
			check = function(_, sequenceData: _T.sequencerData)
				if not sequenceData.instance:IsA("BasePart") then return false end
				local isButtonActivated = utility.isButtonActivatedPlatform(sequenceData.instance)
				if isButtonActivated then
					sequenceData.canAwait = true -- enable canAwait if it isn't already...
					utility.applyPartOptimizations(sequenceData.instance)
				end

				return isButtonActivated
			end,
			activate = function(_, sequenceData: _T.sequencerData)
				local platform = sequenceData.instance
				repeat
					task.wait()
				until platform:GetAttribute("Activated")
			end,
		})

		-- Buttons (no priority) --
		sequencerCache.addActivator("Buttons", {
			check = function(_, sequenceData: _T.sequencerData)
				if not sequenceData.instance:FindFirstChild("ButtonPart") then return false end -- not worth doing any more checks

				local inCache = shared.button_cache.Buttons[sequenceData.instance] ~= nil
				if inCache then utility.applyPartOptimizations(sequenceData.instance:FindFirstChild("ButtonPart")) end
				return inCache
			end,

			activate = function(_, sequenceData: _T.sequencerData)
				local cache = shared.button_cache.Buttons[sequenceData.instance]
				if not cache then return end -- what?
				if cache.Pressed.Value then return end
				cache.Pressed.Value = true

				if sequenceData.canAwait then
					local savedTotalPresses = cache.TotalPresses
					repeat
						task.wait()
					until cache.TotalPresses ~= savedTotalPresses
				end
			end,
		})
	end))
end
