local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")

local spawn, write, color, prompt = process.spawn, stdio.write, stdio.color, stdio.prompt
local shellParams = { shell = true, stdio = "forward", stdin = "forward" }

-- warning message that will be inserted into scripts if requested
local WARNING_KEY = "%-%->insert%-repository%-warning<%-%-" -->insert-repository-warning<--
local WARNING_MESSAGE = `--[[\n{[[
⚠️ WARNING - PLEASE READ! ⚠️
Please do NOT make any script changes to any repository script that is in this folder.
If you need to make a script edit or want to create a custom repository script, please follow the instructions below:

Create a folder named "RepositoryScripts" in workspace under the Kit folder, and place all of your needed repository scripts there. 
PLEASE NOTE: If you are submitting to JToH, It is important that you include this folder in your submission model, 
			or else any script edits/custom scripts will NOT work in game.
If you are making script edits, please add the following comment "--@edit" to where you did the edit. It will help us a lot!

PS: There is a RepositoryScript template under StarterPlayer.StarterPlayerScripts.Client.RepositoryTemplate if you ever need it.


Once you have read this, and followed all the steps correctly, feel free to remove this comment block.
]]}]]`

return function(FILE_NAME: string, doNotRequest: string?)
	if doNotRequest == "skip" then return end

	-- Tarmac Image Assets
	if doNotRequest ~= "true" then
		if prompt("confirm", "Would you like to upload image assets to Roblox?") then
			spawn("tarmac", {
				"sync",
				"--target roblox",
				"--retry 3",
			}, shellParams)
		end
	end

	do -- Replace asset strings
		local ASSETS = require("published-assets")
		local KIT_VERSION = require("kit-version")

		local function getAssetFromDirectory(dir: string): string -- EXAMPLE: "textures/pushing_platform"
			local currentDir = ASSETS.kit_assets
			for _, nextDir in dir:split("/") do
				if typeof(currentDir) == "table" and currentDir[nextDir] ~= nil then -- look at the next directory, switch the current directory if it exists
					currentDir = currentDir[nextDir]
				end
			end

			return (if typeof(currentDir) == "string" then currentDir else dir)
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
			StringValue = "Value",
		}

		local workspace = game:GetService("Workspace")
		for _, part in game:GetDescendants() do
			local propertyToSet: string = validInstanceSet[part.ClassName]
			if part:GetAttribute("asset_directory") ~= nil and typeof(propertyToSet) == "string" then
				part[propertyToSet] = getAssetFromDirectory(part:GetAttribute("asset_directory"))
				part:SetAttribute("asset_directory", part[propertyToSet])
			end
		end

		-- set kit version --
		print("Setting kit version...")
		local clientObjects = workspace.Kit.ClientSidedObjects
		clientObjects:SetAttribute("KitVersion", KIT_VERSION.Kit)

		for _, clientObject in clientObjects:GetChildren() do
			local objectVersion = KIT_VERSION.ClientObjects[clientObject.Name]
			if not objectVersion then continue end

			clientObject:SetAttribute("ObjectVersion", objectVersion)
		end
		---------------------

		-- insert repository warning message --
		local clientDirectory: Instance = game:GetService("StarterPlayer").StarterPlayerScripts.Client

		for _, currentScript in clientDirectory:GetDescendants() do
			if not (currentScript:IsA("ModuleScript") or currentScript:IsA("LocalScript")) then continue end
			currentScript.Source = currentScript.Source:gsub(WARNING_KEY, WARNING_MESSAGE)
		end
		------------------------------------

		print("Serializing & Writing to file...")
		local newPlaceFile = roblox.serializePlace(game)
		fs.writeFile(`./{FILE_NAME}`, newPlaceFile)
		write(color("reset"))
	end
end
