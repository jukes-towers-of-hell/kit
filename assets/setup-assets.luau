local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")

local spawn, write, color, prompt = process.spawn, stdio.write, stdio.color, stdio.prompt
local shellParams = { shell = true, stdio = "forward", stdin = "forward" }

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
		local WARNING_MESSAGES: { [string]: string } = require("warning-messages")

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

		local versionInstance: NumberValue = roblox.Instance.new("NumberValue")
		versionInstance.Value = KIT_VERSION.Kit
		versionInstance.Name = "KitVersion"
		versionInstance.Parent = clientObjects

		for _, clientObject in clientObjects:GetChildren() do
			local objectVersion = KIT_VERSION.ClientObjects[clientObject.Name]
			if not objectVersion then continue end

			clientObject:SetAttribute("ObjectVersion", objectVersion)
		end
		---------------------

		-- insert warning messages --
		for _, currentScript in game:GetDescendants() do
			if not (currentScript:IsA("ModuleScript") or currentScript:IsA("BaseScript")) then continue end
			if currentScript.Name == "ClientObjectManager" then currentScript:SetAttribute("KitVersion", KIT_VERSION.Kit) end

			local finalSource = currentScript.Source
			for warningKey, warningMessage in WARNING_MESSAGES do
				finalSource = finalSource:gsub(warningKey, warningMessage)
			end

			if currentScript.Source == finalSource then continue end
			currentScript.Source = finalSource
		end
		------------------------------------

		print("Serializing & Writing to file...")
		local newPlaceFile = roblox.serializePlace(game)
		fs.writeFile(`./{FILE_NAME}`, newPlaceFile)
		write(color("reset"))
	end
end
