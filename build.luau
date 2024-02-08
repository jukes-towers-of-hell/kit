local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local FILE_NAME = "kit.rbxl"

local spawn, write, color, prompt = process.spawn, stdio.write, stdio.color, stdio.prompt
local shellParams = { shell = true, stdio = "forward", stdin = "forward" }

spawn("clear", {}, shellParams)

if fs.isFile(`{FILE_NAME}.lock`) then
	local canContinue =
		prompt("confirm", `{color("red")}[WARNING]:{color("reset")} Place file is open, please close the place. Continue?`)
	if not canContinue then return end
end

local function linePrint(str: string, lineCount: number?) ----------- cool looking print -----------
	local dashRepeats = ((lineCount or 40) - str:len()) * 0.5
	local includeExtraCharacterIfStringIsUneven = if str:len() % 2 ~= 0 then 1 else 0 -- feeling silly tonite

	return print(`{string.rep("-", dashRepeats)} {str} {string.rep("-", dashRepeats + includeExtraCharacterIfStringIsUneven)}`)
end

-- aftman
write(color("blue"))
linePrint("AFTMAN")
write(color("reset"))
spawn("aftman", { "install" }, { shell = true })

-- wally
write(color("blue"))
linePrint("WALLY")
write(color("reset"))
spawn("wally", { "install" }, shellParams)

-- build rojo
write(color("blue"))
linePrint("ROJO")
write(color("reset"))

write(color("green"))
spawn("rojo", { "build", `--output`, FILE_NAME }, shellParams)
write(color("reset"))

-- assets
write(color("blue"))
linePrint("ASSETS")
write(color("reset"))
require("assets/setup-assets")(FILE_NAME)
print()
