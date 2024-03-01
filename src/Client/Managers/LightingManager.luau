--!strict
-- LightingManager by @Gammaaaaa & @synnwave

-->insert-corescript-warning<--

local manager = { hasInitialized = false }

local tweenService: TweenService = game:GetService("TweenService")
local lighting: Lighting = game:GetService("Lighting")

local replicatedStorage = game:GetService("ReplicatedStorage")
local _T = require(replicatedStorage.ClientTypes)
local Utility: _T.Utility = require(script:FindFirstAncestor("Client").Managers.UtilityManager)

local DEFAULT_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local CONFIGURABLE_PROPS: { [string]: { string } } = {
	["ColorCorrectionEffect"] = { "Brightness", "Contrast", "Saturation", "TintColor" },
	["BlurEffect"] = { "Size" },
	["Lighting"] = { "Ambient", "OutdoorAmbient", "FogEnd", "FogStart", "FogColor", "ClockTime", "Brightness" },
	["BloomEffect"] = { "Intensity", "Size", "Threshold" },
	["DepthOfFieldEffect"] = { "FarIntensity", "FocusDistance", "InFocusRadius", "NearIntensity" },
}

local PRESET_PROPERTIES: { [string]: { [string]: any } } = {
	-- roblox has preset properties when using Instance.new, this table is for setting those properties to their defaults
	["BlurEffect"] = { Size = 0 },
	["DepthOfFieldEffect"] = { NearIntensity = 0, FarIntensity = 0 },
	["BloomEffect"] = { Intensity = 1, Size = 24, Threshold = 2 },
}

local defaultProperties = {}
function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

	for effect: string, properties: { string } in CONFIGURABLE_PROPS do
		local defaultPropertyTable: { [string]: any } = {}
		if effect == "Lighting" then
			for _, prop: string in properties do
				defaultPropertyTable[prop] = Utility.getInstanceProperty(lighting, prop)
			end
		else
			local identifier = `LC{effect}`
			local lightingEffect: Instance = lighting:FindFirstChild(identifier) or Instance.new(effect)
			if not lightingEffect:IsDescendantOf(lighting) then
				lightingEffect.Name = identifier
				lightingEffect.Parent = lighting
			end

			local presetProperties: { [string]: any }? = PRESET_PROPERTIES[lightingEffect.ClassName]
			if presetProperties then
				for prop: string, value: any in presetProperties do
					Utility.setInstanceProperty(lightingEffect, prop, value)
				end
			end

			for _, prop: string in properties do
				defaultPropertyTable[prop] = Utility.getInstanceProperty(lightingEffect, prop)
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
		elseif typeof(config.Configuration) == "table" then config.Configuration
		else {}

	if typeof(config.Configuration) == "Instance" and CONFIGURABLE_PROPS[config.Configuration.ClassName] ~= nil then
		for _, prop in CONFIGURABLE_PROPS[config.Configuration.ClassName] do
			currentConfiguration[prop] = Utility.getInstanceProperty(config.Configuration, prop)
		end
	end

	local propertyTable = {}
	for prop: string, value: any in currentConfiguration do
		if typeof(value) == "string" or typeof(value) == "boolean" then
			Utility.setInstanceProperty(lightingInstance, prop, value)
			continue
		end

		propertyTable[prop] = value
	end

	tweenService:Create(lightingInstance, currentTweenInfo, propertyTable):Play()
end

return manager
