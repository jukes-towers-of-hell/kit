--!strict

-->insert-corescript-warning<--

--[=[
	@within utility
	@tag shorthand

	
]=]
local function getEnumFromString(str: string | EnumItem, default: EnumItem): any
	if typeof(str) == "EnumItem" and str.EnumType == default.EnumType then return str end
	-- i hate having to check for enums :(
	local success: boolean, enum: EnumItem? = pcall(function() return (default.EnumType :: any)[str] end)
	return if success then enum else default
end

return getEnumFromString
-- update as of 21/02/24:
-- this function is much smaller than it used to be, mainly because the extra functions it had were probably not needed
