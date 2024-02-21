--!strict

local httpService: HttpService = game:GetService("HttpService")
return function(curlyBraces: boolean?, removeSplit: boolean?): string
	return (httpService:GenerateGUID(curlyBraces):gsub(if removeSplit then "-" else "", ""))
end
