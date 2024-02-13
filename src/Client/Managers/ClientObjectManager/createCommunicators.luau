--!strict
-- this is only in a seperate module because i don't want the ClientObjectManager to look cluttered

local replicatedStorage = game:GetService("ReplicatedStorage")
local _T = require(replicatedStorage.ClientTypes)

local root = script:FindFirstAncestor("Client")
local Managers = root:FindFirstChild("Managers")
local lightingManager = require(Managers.LightingManager)

return function(currentTrove: _T.Trove)
	local requestFunctions: { [string]: _T.requestFunction } = {} -- will be used to add request functions for requestCommunicator
	local eventCommunicator: BindableEvent = Instance.new("BindableEvent")
	currentTrove:Add(eventCommunicator)
	currentTrove:Connect(eventCommunicator.Event, function(type: string, ...) -- listen to events
		if type == "change-lighting" then -- change lighting on request
			local config: _T.LightingConfiguration = ...
			lightingManager:ChangeLighting(config)
		end

		if type == "add-request" then -- add a request function for requestCommunicator
			local entry: string, func: _T.requestFunction = ...
			if requestFunctions[entry] then
				warn(`request function "{entry}" already exists`)
				return
			end
			requestFunctions[entry] = func
		elseif type == "remove-request" then
			local entry: string = ...
			requestFunctions[entry] = nil
		end
	end)

	local requestCommunicator: BindableFunction = Instance.new("BindableFunction")
	currentTrove:Add(requestCommunicator)
	function requestCommunicator.OnInvoke(type: string, ...)
		local requestedFunction = requestFunctions[type]
		if typeof(requestedFunction) ~= "function" then
			warn(`request function "{type}" doesn't exist`)
			return nil
		end

		return requestedFunction(...)
	end

	return {
		event = eventCommunicator,
		request = requestCommunicator,
	}
end
