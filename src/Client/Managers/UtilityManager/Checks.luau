--!strict

local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local Utility: _T.Utility = require(script.Parent)

-- Checks --
-- Functions for checking things, such as:
-- checking whether a instance is a ButtonActivatedPlatform, Turret, Pushbox or a balloon (isBalloon, isTurret, isPushbox, isButtonActivatedPlatform)
-- checking for instance configurations with Attributes & Values (checkConfig)
-- validating the touching part (evaluateToucher)

local util = {}

function util.isButtonActivatedPlatform(platform: Instance): boolean
	return platform:IsA("BasePart")
		and (
			platform.Name == "ButtonActivatedPlatform"
			or (platform:FindFirstChild("ButtonActivated") ~= nil or platform:GetAttribute("ButtonActivated"))
		)
end

function util.isBalloon(parent: Instance): boolean return parent.Name == "Balloon" end
function util.isTurret(parent: Instance): boolean return parent.Name == "Bullet" end
function util.isPushbox(parent: Instance): boolean
	if typeof(parent) ~= "Instance" then return false end
	return (parent.Name == "Pushbox") or (parent:FindFirstAncestor("Pushbox") ~= nil) or (parent:FindFirstChild("IsBox") ~= nil)
end

function util.checkConfig(instance: Instance, configName: string): any
	if typeof(instance) ~= "Instance" or typeof(configName) ~= "string" then return end
	local foundValue: Instance? = instance:FindFirstChild(configName)
	local foundAttribute: any = instance:GetAttribute(configName)

	return if (foundValue and foundValue:IsA("ValueBase"))
		then (foundValue :: any).Value
		elseif foundAttribute ~= nil then foundAttribute
		else nil
end

function util.evaluateToucher(part: BasePart, toucher: BasePart, config: Instance?): boolean
	if not (toucher and toucher.Parent) then return false end
	local configuration: Instance = config or part

	local ancestor: Instance? = toucher.Parent
	local humanoid: Humanoid? = (
		toucher:FindFirstChildWhichIsA("Humanoid") or (ancestor and ancestor:FindFirstChildWhichIsA("Humanoid"))
	)
	local playerTouched: boolean = game.Players:GetPlayerFromCharacter(humanoid and humanoid.Parent) == localPlayer
	local isColorSpecific = not (
		util.checkConfig(configuration, "ColorSpecific") and (Utility.roundColor(toucher.Color) ~= Utility.roundColor(part.Color))
	)

	local playersSupported = if config ~= nil
		then (util.checkConfig(configuration, "SupportPlayers") and playerTouched)
		else playerTouched -- allow players to touch it no matter what if there is no config provided
	local pushboxesSupported = (util.checkConfig(configuration, "SupportPushboxes") and util.isPushbox(toucher) and isColorSpecific)
	local balloonsSupported = (util.checkConfig(configuration, "SupportBalloons") and util.isBalloon(toucher) and isColorSpecific)
	local turretsSupported = (util.checkConfig(configuration, "SupportTurrets") and util.isTurret(toucher) and isColorSpecific)

	return playersSupported or pushboxesSupported or balloonsSupported or turretsSupported
end

return util
