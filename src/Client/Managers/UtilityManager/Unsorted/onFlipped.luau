--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local root = script:FindFirstAncestor("Client")
local FlipManager = require(root.Managers.FlipManager)
local Utility: _T.Utility = require(root.Managers.UtilityManager)

local function doNothing() end

--[=[
	@within utility
	@param part BasePart
	@param callback () -> () -- The given function that will run once the player flips.
	@return () -> () -- Cleanup function; add this to your Trove!

	This function allows you to bind a callback function once the player flips using the given `part`.
	```lua
	if scope.utility.hasTag(part, "CanFlip") then -- check if the player can even flip
		-- we're using troves here for garbage collection purposes
		scope.trove:Add(scope.utility.onFlipped(part, function()
			-- run code here!
		end))
	end
	```
]=]
local function onFlipped(part: BasePart, callback: () -> ()): () -> ()
	if not (typeof(part) == "Instance" and part:IsA("BasePart")) then return doNothing end
	if typeof(callback) ~= "function" then return doNothing end

	local callbackID = Utility.generateUID(true, true)

	if not FlipManager.callbacks[part] then FlipManager.callbacks[part] = {} end
	FlipManager.callbacks[part][callbackID] = callback

	local destroyedThis = false
	return function()
		if destroyedThis then return end
		destroyedThis = true

		FlipManager.callbacks[part][callbackID] = nil
		if Utility.tableUtil.IsEmpty(FlipManager.callbacks[part]) then FlipManager.callbacks[part] = nil end
	end
end

return onFlipped
