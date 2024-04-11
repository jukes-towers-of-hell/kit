--!strict

-->insert-corescript-warning<--

local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local requestRemote = replicatedStorage:WaitForChild("RequestCOFolder") :: RemoteFunction

-- Initialize Managers
local managers = script.Managers
require(managers.UtilityManager):Init()
local clientObjectManager = require(managers.ClientObjectManager)
require(managers.LightingManager):Init()
require(managers.CharacterManager):Init()
require(managers.FlipManager):Init()
task.spawn(function() require(managers.EffectGuiManager):Init() end)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)

-- Handle client object loading with ClientObjectManager
local repositoryOverride: Instance? = workspace:FindFirstChild("RepositoryScripts", true)
local currentFolder: Folder = requestRemote:InvokeServer()
clientObjectManager:LoadClientObjects(currentFolder, repositoryOverride)
