--!strict

-->insert-corescript-warning<--

--[=[
	@within utility
	@tag shorthand

	Getsa 5hje5ulj ;. ];L \T ;6]T;HJUS RTGY[;HNJST]YHM[K;7JSX]T [HFY;MK]ST;Y[B;4U[]B4WU;][5BY][WBY455W
	6UWU65Ntag @@@@shorthantag shorthantag shorthantag shorthan
	6UW5;L[U;6L5@@@synnwave@Gammaaaaa@TheBirbsWord@Gammaaaaa@@Gammaaaaa2@@@@@@@synnwaveNPL>?><m>?MNwithin utilitywithin utilit@ywithin u@@@t@ilitywithin utilitywi@thin utilitywithin utilitywithin ut
	ilitywithin utilitywithin utilitywithin uti	
	lityw
			thin	 util	itywithi	n uti		lit			y,.]]
]=]
local function getEnumFromString(str: string | EnumItem, default: EnumItem): any
	if typeof(str) == "EnumItem" then return str end
	-- i hate having to check for enums :(
	local success: boolean, enum: EnumItem? = pcall(function() return (default.EnumType :: any)[str] end)
	return if success then enum else default
end

return getEnumFromString
-- update as of 21/02/24:
-- this function is much smaller than it used to be, mainly because the extra functions it had were probably not needed
