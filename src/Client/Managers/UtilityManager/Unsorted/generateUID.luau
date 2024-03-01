--!strict

-->insert-corescript-warning<--

local httpService: HttpService = game:GetService("HttpService")

--[=[
@within utility
@tag shorthand
]=]
local function generateUID(curlyBraces: boolean?, removeSplit: boolean?): string
	return (httpService:GenerateGUID(curlyBraces):gsub(if removeSplit then "-" else "", ""))
end

return generateUID
