--!strict
-- LightingManager by @synnwave

local manager = { hasInitialized = false }

local tweenService: TweenService = game:GetService("TweenService")
local lighting: Lighting = game:GetService("Lighting")

local replicatedStorage = game:GetService("ReplicatedStorage")
local _T = require(replicatedStorage.ClientTypes)

local DEFAULT_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local CONFIGURABLE_PROPS: { [string]: { string } } = {
	["ColorCorrectionEffect"] = { "Brightness", "Contrast", "Saturation", "TintColor" },
	["BlurEffect"] = { "Size" },
	["Lighting"] = { "Ambient", "OutdoorAmbient", "FogEnd", "FogStart", "FogColor", "ClockTime", "Brightness" },
	["BloomEffect"] = { "Intensity", "Size", "Threshold" },
	["DepthOfFieldEffect"] = { "FarIntensity", "FocusDistance", "InFocusRadius", "NearIntensity" },
}

local function getInstanceProperty(instance: any, prop: string): any -- lazy function (for readability)
	local result
	pcall(function() result = instance[prop] end)
	return result
end

local defaultProperties = {}
function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

	for effect: string, properties: { string } in CONFIGURABLE_PROPS do
		local defaultPropertyTable: { [string]: any } = {}
		if effect == "Lighting" then
			for _, prop: string in properties do
				defaultPropertyTable[prop] = getInstanceProperty(lighting, prop)
			end
		else
			local identifier = `LC{effect}`
			local lightingEffect: Instance = lighting:FindFirstChild(identifier) or Instance.new(effect)
			if not lightingEffect:IsDescendantOf(lighting) then
				lightingEffect.Name = identifier
				lightingEffect.Parent = lighting
			end

			if lightingEffect:IsA("BlurEffect") then
				lightingEffect.Size = 0
			elseif lightingEffect:IsA("DepthOfFieldEffect") then
				lightingEffect.FarIntensity = 0
				lightingEffect.NearIntensity = 0
			elseif lightingEffect:IsA("BloomEffect") then
				lightingEffect.Intensity = 1
				lightingEffect.Size = 24
				lightingEffect.Threshold = 2
			end

			for _, prop: string in properties do
				defaultPropertyTable[prop] = getInstanceProperty(lightingEffect, prop)
			end
		end

		defaultProperties[effect] = defaultPropertyTable
	end
end

function manager:ChangeLighting(config: _T.LightingConfiguration)
	if not manager.hasInitialized then return end
	if CONFIGURABLE_PROPS[config.Type] == nil then return end

	local lightingInstance: Instance? = if config.Type == "Lighting" then lighting else lighting:FindFirstChild(`LC{config.Type}`)
	if not lightingInstance then return end

	local currentTweenInfo: TweenInfo = config.TweenInfo or DEFAULT_TWEENINFO
	local currentConfiguration: { [string]: any } = if config.Configuration == "Default"
		then defaultProperties[config.Type]
		else config.Configuration

	local propertyTable = {}
	for property: string, value: any in currentConfiguration do
		if typeof(value) == "string" or typeof(value) == "boolean" then
			pcall(function() (lightingInstance :: any)[property] = value end)
			continue
		end

		propertyTable[property] = value
	end

	tweenService:Create(lightingInstance, currentTweenInfo, propertyTable):Play()
end

return manager
