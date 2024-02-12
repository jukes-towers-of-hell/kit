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
		coFolder.Parent = playerGui

		return coFolder
	end
end

return manager
