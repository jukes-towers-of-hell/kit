--!strict

-->insert-corescript-warning<--

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local Utility: _T.Utility = require(script.Parent)

-- Checks --
-- Functions for checking things, such as:
-- checking whether a instance is a ButtonActivatedPlatform, Turret, Pushbox or a balloon (isBalloon, isTurret, isPushbox, isButtonActivatedPlatform)
-- checking for instance configurations with Attributes & Values (checkConfig)
-- validating the touching part (evaluateToucher)

local util = {}

--[=[
	@within utility

	This function is used to check for a specific `ValueBase` or `Attribute` in an Instance, based on the given `configName`. 
		If a `ValueBase` is found, it will return the `ValueBase`'s value. If an `Attribute` is found, it will return the `Attribute`'s value. 
		If no `ValueBase` or Attribute is found, it will return nil.
]=]
function util.checkConfig(instance: Instance, configName: string): any
	if typeof(instance) ~= "Instance" or typeof(configName) ~= "string" then return end
	local foundValue: Instance? = instance:FindFirstChild(configName)
	local foundAttribute: any = instance:GetAttribute(configName)

	return if (foundValue and foundValue:IsA("ValueBase"))
		then (foundValue :: any).Value
		elseif foundAttribute ~= nil then foundAttribute
		else nil
end

--[=[
	@within utility

	This function is used to check for a specific `ValueBase` or `Attribute` in an Instance, then give it's ChangedSignal, based on the given `configName`. 
		If a `ValueBase` is found, it will return the `ValueBase`'s ChangedSignal. If an `Attribute` is found, it will return the `Attribute`'s ChangedSignal. 
		If no `ValueBase` or Attribute is found, it will return nil.
]=]
function util.getConfigChangedSignal(instance: Instance, configName: string): RBXScriptSignal?
	if typeof(instance) ~= "Instance" or typeof(configName) ~= "string" then return end
	local foundValue: Instance? = instance:FindFirstChild(configName)
	if foundValue and foundValue:IsA("ValueBase") then
		return (foundValue :: any):GetPropertyChangedSignal("Value")
	elseif instance:GetAttribute(configName) ~= nil then
		return instance:GetAttributeChangedSignal(configName)
	end

	return
end

--[=[
	@within utility
	@tag shorthand

	This function is used to check if an `Instance` has a tag with the provided `tagName` or if it has a `ValueBase`/`Attribute` with that `tagName`. 
		It does so by first checking if the `Instance` has the tag directly, and if not, 
		it checks if there is a `ValueBase` or `Attribute` with the given `tagName`.
]=]
function util.hasTag(instance: Instance, tagName: string): boolean
	return (instance:HasTag(tagName) or (util.checkConfig(instance, tagName) ~= nil))
end

--[=[
	@within utility
	@tag shorthand

	This function is used to check if the provided `Instance` is a ButtonActivatedPlatform.
		It does so by first checking if the `Instance` is a `BasePart`, 
		then checking if the platform's name is ButtonActivatedPlatform or has the ButtonActivated tag. 
]=]
function util.isButtonActivatedPlatform(platform: Instance): boolean
	if typeof(platform) ~= "Instance" then return false end
	return platform:IsA("BasePart") and (platform.Name == "ButtonActivatedPlatform" or util.hasTag(platform, "ButtonActivated"))
end

--[=[
	@within utility
	@tag shorthand

	This function is used to check if the provided `Instance` is a Balloon (or is within a Balloon).
		It does so by checking if the name of the `Instance` is Balloon, and if not,
		it will instead check for the `Instance`'s ancestors to see if it is within a Balloon. (You can disable this ancestor check by setting `doNotCheckAncestor` to `true`.)
]=]
function util.isBalloon(parent: Instance, doNotCheckAncestor: boolean?): boolean
	if typeof(parent) ~= "Instance" then return false end
	return parent.Name == "Balloon" or ((not doNotCheckAncestor) and parent:FindFirstAncestor("Balloon") ~= nil)
end

--[=[
	@within utility
	@tag shorthand
	
	This function is used to check if the provided `Instance` is a Turret (or is within a Turret).
		It does so by checking if the name of the `Instance` is Bullet, and if not,
		it will instead check for the `Instance`'s ancestors to see if it is within a Bullet. (You can disable this ancestor check by setting `doNotCheckAncestor` to `true`.)
]=]
function util.isTurret(parent: Instance, doNotCheckAncestor: boolean?): boolean
	if typeof(parent) ~= "Instance" then return false end
	return parent.Name == "Bullet" or ((not doNotCheckAncestor) and parent:FindFirstAncestor("Bullet") ~= nil)
end

--[=[
	@within utility
	@tag shorthand

	This function is used to check if the provided `Instance` is a Pushbox (or is within a Pushbox).
		It does so by checking if the name of the `Instance` is Pushbox, and if not,
		it will instead check for the `Instance`'s ancestors to see if it is within a Pushbox. (You can disable this ancestor check by setting `doNotCheckAncestor` to `true`.)
]=]
function util.isPushbox(parent: Instance, doNotCheckAncestor: boolean?): boolean
	if typeof(parent) ~= "Instance" then return false end
	return (parent.Name == "Pushbox")
		or ((not doNotCheckAncestor) and parent:FindFirstAncestor("Pushbox") ~= nil)
		or (util.hasTag(parent, "IsBox"))
end

--[=[
	@within utility
	@tag shorthand

	This function is used to check if the provided `Instance` is within a Sequencer sequence.
		It does so by checking the `Instance`'s ancestors to see if it is within a Sequencer.
]=]
function util.isSequence(parent: Instance): boolean
	if typeof(parent) ~= "Instance" then return false end
	return parent:FindFirstAncestor("Sequencer") ~= nil
end

local defaultChecks = {
	allowPlayer = true,
	allowPushbox = true,
	allowColorSpecific = true,
	allowBalloons = true,
	allowTurrets = true,
}

--[=[
	@within utility

	This function is used to validate the touching part. 
		It does so by doing the following checks: 
	- checking if the "SupportPlayers" configuration is toggled, and if the toucher is the local player's character.
	- checking if the "SupportPushboxes" configuration is toggled, and if the toucher is a pushbox by using the [util.isPushbox](#isPushbox) function, and if the ColorSpecific configuration is toggled and the pushbox is the same color as the part.
	- checking if the "SupportBalloons" configuration is toggled, and if the toucher is a balloon by using the [util.isBalloon](#isBalloon) function, and if the ColorSpecific configuration is toggled and the balloon is the same color as the part.
	- checking if the "SupportTurrets" configuration is toggled, and if the toucher is a turret bullet by using the [util.isTurret](#isTurret) function, and if the ColorSpecific configuration is toggled and the turret bullet is the same color as the part.
	
	```lua
	-- we're using troves here for garbage collection purposes
	scope.trove:Add(part.Touched:Connect(function(toucher: BasePart)
		if not scope.utility.evaluateToucher(part, toucher, part) then return end
		-- run code!
	end))
	```

	You can also disable certain checks by passing in a table, shown here:
	```lua
	local allowedChecks = {
		allowPlayer = true,
		allowPushbox = true,
		allowColorSpecific = false,
		allowBalloons = false,
		allowTurrets = false,
	}

	if not scope.utility.evaluateToucher(part, toucher, part, allowedChecks) then return end
	```
]=]
function util.evaluateToucher(part: BasePart, toucher: BasePart, config: Instance?, checkConfig: typeof(defaultChecks)?): boolean
	if not ((toucher and toucher:IsA("BasePart")) and toucher.Parent) then return false end
	if not (part and part:IsA("BasePart")) then return false end

	local allowedChecks = checkConfig or defaultChecks

	local ancestor: Instance? = toucher.Parent.Parent
	local humanoid: Humanoid? = toucher.Parent:FindFirstChildWhichIsA("Humanoid")
		or (ancestor and ancestor:FindFirstChildWhichIsA("Humanoid"))
	local playerTouched: boolean = players:GetPlayerFromCharacter(humanoid and humanoid.Parent) == localPlayer

	local configuration: Instance = config or part
	local colorSpecificColor: Color3 = Utility.getConfig(configuration, "ColorSpecific", Utility.roundColor(part.Color))
	local isColorSpecific = allowedChecks.allowColorSpecific
		and not (Utility.hasTag(configuration, "ColorSpecific") and (Utility.roundColor(toucher.Color) ~= colorSpecificColor))

	local playersSupported = allowedChecks.allowPlayer
		and if config ~= nil then (Utility.getConfig(configuration, "SupportPlayers", false) and playerTouched) else playerTouched -- allow players to touch it no matter what if there is no config provided
	local pushboxesSupported = allowedChecks.allowPushbox
		and (Utility.getConfig(configuration, "SupportPushboxes", false) and util.isPushbox(toucher) and isColorSpecific)
	local balloonsSupported = allowedChecks.allowBalloons
		and (Utility.getConfig(configuration, "SupportBalloons", false) and util.isBalloon(toucher) and isColorSpecific)
	local turretsSupported = allowedChecks.allowTurrets
		and (Utility.getConfig(configuration, "SupportTurrets", false) and util.isTurret(toucher) and isColorSpecific)

	return playersSupported or pushboxesSupported or balloonsSupported or turretsSupported
end

return util
