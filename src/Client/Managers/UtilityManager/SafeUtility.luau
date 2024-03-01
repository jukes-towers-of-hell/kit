--!strict

-->insert-corescript-warning<--

-- Safe Utility --
-- (these are mainly shorthand functions lol)
-- Functions for doing operations safely, such as:
-- getting instance properties (getInstanceProperty)
-- setting instance properties (setInstanceProperty)

local util = {}

--[=[
@within utility
@tag shorthand
]=]
function util.getInstanceProperty(instance: any, property: string): any
	local result
	pcall(function() result = instance[property] end)
	return result
end

--[=[
@within utility
@tag shorthand
]=]
function util.setInstanceProperty(instance: any, property: string, value: any)
	pcall(function() instance[property] = value end)
end

--[=[
@within utility
@tag shorthand
]=]
function util.assureValueType<defaultType>(value: unknown, default: defaultType): defaultType
	return if typeof(default) == typeof(value) then value :: defaultType else default
end

return util
