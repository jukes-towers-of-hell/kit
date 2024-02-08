local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")

local spawn, write, color, prompt = process.spawn, stdio.write, stdio.color, stdio.prompt
local shellParams = { shell = true, stdio = "forward", stdin = "forward" }

return function(FILE_NAME: string)
	-- Tarmac Image Assets
	if prompt("confirm", "Would you like to upload image assets to Roblox?") then
		spawn("tarmac", {
			"sync",
			"--target roblox",
			"--retry 3",
		}, shellParams)
	end

	do -- Replace asset strings
		local ASSETS = require("published-assets")
		local PREFIX = "$kit_assets"

		local function isValidPrefix(dir: string): boolean return (dir:sub(1, PREFIX:len()) == PREFIX) end
		local function getAssetFromDirectory(dir: string): string -- EXAMPLE: "$kit_assets/textures/pushing_platform"
			dir = dir:sub(PREFIX:len() + 2) -- remove image prefix

			local currentDir = ASSETS.kit_assets
			for _, nextDir in dir:split("/") do
				if typeof(currentDir) == "table" and currentDir[nextDir] ~= nil then -- look at the next directory, switch the current directory if it exists
					currentDir = currentDir[nextDir]
				end
			end

			return (if typeof(currentDir) == "string" then currentDir else "")
		end

		write(color("blue"))
		print(`Loading placefile "{FILE_NAME}"...`)
		local game = roblox.deserializePlace(fs.readFile(`./{FILE_NAME}`))
		print(`Replacing asset IDs...`)

		local validInstanceSet = {
			Texture = "Texture",
			Decal = "Texture",
			ParticleEmitter = "Texture",
			Beam = "Texture",
			Sound = "SoundId",
		}

		for _, part in game:GetService("Workspace"):GetDescendants() do
			local propertyToSet: string = validInstanceSet[part.ClassName]
			if typeof(propertyToSet) == "string" and isValidPrefix(part[propertyToSet]) then
				part[propertyToSet] = getAssetFromDirectory(part[propertyToSet])
			end
		end

		print("Serializing & Writing to file...")
		local newPlaceFile = roblox.serializePlace(game)
		fs.writeFile(`./{FILE_NAME}`, newPlaceFile)
		write(color("reset"))
	end
end
