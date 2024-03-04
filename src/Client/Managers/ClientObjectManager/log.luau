--!strict

-->insert-corescript-warning<--

local startTypes: { [number | boolean | string]: string } = {
	[1] = "Success",
	[2] = "Error",
	[3] = "Warn",
	[4] = "Info",

	[true] = "Error",
	[false] = "Success",

	success = "Success",
	error = "Error",
	warn = "Warn",
	info = "Info",
}

local tagEmojis = {
	Success = `✅`,
	Error = `❎`,
	Warn = `⚠️`,
	Info = `ℹ️`,
}

local printTypes: { [number | string]: (string) -> () } = {
	[1] = print,
	[2] = warn,
	[3] = error,

	print = print,
	warn = warn,
	error = error,
}

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

return function(
	scope: _T.Variables?,
	str: string,
	useTraceback: boolean?,
	logType: (number | boolean | string)?,
	printType: (number | string)?
)
	local emoji: string = tagEmojis[startTypes[logType or 4]]
	local scriptCaller: string, scriptLine: number, functionName: string? = debug.info(2, "sln")

	if typeof(scope) == "table" then
		scriptCaller = `Repository.{scope.scriptPath or "[?]"}`
	else
		local locations: { string } = scriptCaller:split(".")
		scriptCaller = locations[#locations] or "[?]"
	end

	local startingString = `{emoji} {scriptCaller}`
	if useTraceback then
		startingString ..= `{if functionName ~= "" then `.{functionName}()` else ""} #{scriptLine}`
	end

	str = str:gsub("[^\n]+", function(currentString: string) return `\t\t\t > {currentString}` end)

	local currentPrintType: (string) -> () = printTypes[(printType or logType) :: any] or print -- or print
	currentPrintType(`[{startingString}]:\n{str}`)
end
