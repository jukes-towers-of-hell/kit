--!strict

local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local requestRemote = replicatedStorage:WaitForChild("RequestCOFolder") :: RemoteFunction

-- Initialize Managers
local managers = script.Managers
local clientObjectManager = require(managers.ClientObjectManager)
require(managers.LightingManager):Init()
require(managers.CharacterManager):Init()
require(managers.FlipManager):Init()

-- Handle client object loading with ClientObjectManager
local currentFolder: Folder = requestRemote:InvokeServer()
clientObjectManager:LoadClientObjects(currentFolder)
