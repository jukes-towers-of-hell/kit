local TEMP_DIR = "assets/kit-temp.rbxl"
local DOCS_DIR = "docs"
local BASE_DOCS_DIR = "kit-docs"

local DOCS_TAG = "--makedocs:"
local DOC_NAME_PATTERN = `docname%s?:%s?(%b"")`

local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local spawn, write, color = process.spawn, stdio.write, stdio.color
local shellParams = { shell = true, stdio = "forward", stdin = "forward" }
local function linePrint(str: string, lineCount: number?) ----------- cool looking print -----------
	local dashRepeats = ((lineCount or 40) - str:len()) * 0.5
	local includeExtraCharacterIfStringIsUneven = if str:len() % 2 ~= 0 then 1 else 0 -- feeling silly tonite

	return print(`{string.rep("-", dashRepeats)} {str} {string.rep("-", dashRepeats + includeExtraCharacterIfStringIsUneven)}`)
end

-- build temp project --
write(color("blue"))
linePrint("BUILD TEMP PROJECT")
write(color("green"))
spawn("rojo", { "build", `--output`, TEMP_DIR }, shellParams)
write(color("reset"))

local game = roblox.deserializePlace(fs.readFile(`./{TEMP_DIR}`))

-- make doc dir --
write(color("blue"))
linePrint("DOCS")
print("Checking for Docs directory...")
if fs.isDir(DOCS_DIR) then -- clear out any existing doc directories
	fs.removeDir(DOCS_DIR)
	write(color("yellow"))
	print("Existing Docs directory found, removing... ")
end
if not fs.isDir(DOCS_DIR) then -- make a new doc directory
	write(color("green"))
	fs.copy(BASE_DOCS_DIR, DOCS_DIR, true)
	print("Made new Docs directory\n")
end

-- scan for docs --
for _, currentScript in game:GetDescendants() do
	if not (currentScript:IsA("ModuleScript") or currentScript:IsA("BaseScript")) then continue end

	local currentSource = currentScript.Source
	if not currentSource:find(DOCS_TAG, 1, true) then continue end

	local currentDoc = currentSource:match("%b[]"):sub(4, -3)
	local docName = (currentSource:match(DOC_NAME_PATTERN) and currentSource:match(DOC_NAME_PATTERN):sub(2, -2))
		or currentScript.Parent.Name

	local currentPath = `{DOCS_DIR}/{docName}.md`
	if fs.isFile(currentPath) then
		write(color("yellow"))
		warn(`> docfile already exists for {docName}`)
		continue
	end

	write(color("green"))
	print(`> Writing docfile for "{docName}"`)
	fs.writeFile(currentPath, currentDoc)
end

-- clean up --
print(color("reset"))
print("Cleaning up...")
pcall(function() fs.removeFile(`./{TEMP_DIR}`) end)
