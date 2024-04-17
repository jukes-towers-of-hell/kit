--!strict

-->insert-corescript-warning<--

local SEARCH_INTERVAL = 0.05

--[=[
	@within utility
	@param instance Instance
	@param descendantName string -- the descendant to look for
	@tag shorthand

	Waits until the provided `descendantName` is found within the provided `instance`.

	Shorthand of `instance:FindFirstChild(descendantName, true)`
]=]
local function WaitForDescendant(instance: Instance, descendantName: string, timeout: number?): Instance?
	local descendant: Instance?
	local startTime = os.clock()
	local targetTimeout = timeout or math.huge

	repeat
		descendant = instance:FindFirstChild(descendantName, true)
		if not descendant then task.wait(SEARCH_INTERVAL) end
	until descendant or (os.clock() - startTime) >= targetTimeout
	return descendant
end

return WaitForDescendant
