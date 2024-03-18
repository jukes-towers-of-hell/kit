--!strict

-->insert-corescript-warning<--

local httpService: HttpService = game:GetService("HttpService")

--[=[
	@within utility
	@tag shorthand

	Shorthand for [HttpService:GenerateGUID()](https://create.roblox.com/docs/reference/engine/classes/HttpService#GenerateGUID). 
	```lua
	scope.utility.generateUID(false, true)
		--> 4BA80F4637244B4BBA957E28B9443DE9
	```
]=]
local function generateUID(curlyBraces: boolean?, removeSplit: boolean?): string
	return (httpService:GenerateGUID(curlyBraces):gsub(if removeSplit then "-" else "", ""))
end

return generateUID
