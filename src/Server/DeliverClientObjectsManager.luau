--!strict
local serverStorage: ServerStorage = game:GetService("ServerStorage")
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder: Instance = serverStorage:WaitForChild("ClientSidedObjects")

local manager = {}

function manager:Init()
	local remote: RemoteFunction = Instance.new("RemoteFunction")
	remote.Name = "RequestCOFolder"
	remote.Parent = replicatedStorage

	function remote.OnServerInvoke(player: Player)
		local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
		local coFolder = folder:Clone()

		-- Since this is the kit place, we need the folder to persist in the player's PlayerGui,
		-- Roblox automatically removes any instance with ResetOnSpawn turned on.
		-- Since this is a folder, we need to place it inside a GUI Instance. I'll be using a SurfaceGui to do this.
		local dummyParent: SurfaceGui = Instance.new("SurfaceGui")
		dummyParent.Enabled = false
		dummyParent.ResetOnSpawn = false
		dummyParent.Name = "\0"

		coFolder.Parent = dummyParent
		dummyParent.Parent = playerGui

		return coFolder
	end
end

return manager
