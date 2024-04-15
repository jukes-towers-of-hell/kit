--!strict

-->insert-corescript-warning<--

-- Safe Utility --
-- (these are mainly shorthand functions lol)
-- Functions for doing operations safely, such as:
-- getting instance properties (getInstanceProperty)
-- setting instance properties (setInstanceProperty)

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local Utility: _T.Utility = require(script.Parent)

local util = {}

--[=[
	@within utility
	@tag shorthand

	Safely gets a property of an instance. 
	Will return `nil` if the property does not exist, or if any errors occur.
]=]
function util.getInstanceProperty(instance: any, property: string): (any, boolean)
	local result
	local success = pcall(function() result = instance[property] end)
	return result, success
end

--[=[
	@within utility
	@tag shorthand
	
	Safely sets a property of an instance.
]=]
function util.setInstanceProperty(instance: any, property: string, value: any): boolean
	return (pcall(function() instance[property] = value end))
end

--[=[
	@within utility
	@tag shorthand

	Checks if `value` and `default` are of the same type. 
	If not, it will return the `default` value.
]=]
function util.assureValueType<defaultType>(value: unknown, default: defaultType): defaultType
	return if typeof(default) == typeof(value) then value :: defaultType else default
end

--[=[
	@within utility
	@tag shorthand
	@param default
	@return defaultType

	Shorthand for `utility.assureValueType(utility.checkConfig(instance, configName), default)`
]=]
function util.getConfig<defaultType>(instance: Instance, configName: string, default: defaultType): defaultType
	local returnedConfig = Utility.checkConfig(instance, configName)
	if typeof(default) == "EnumItem" then return Utility.getEnumFromString(returnedConfig, default) end
	return util.assureValueType(returnedConfig, default)
end

return util
