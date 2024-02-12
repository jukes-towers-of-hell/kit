--!strict
-- ClientObjectManager by @synnwave

local manager = {}

local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local root = script:FindFirstAncestor("Client")
local Repository = root:FindFirstChild("Repository")

local replicatedStorage = game:GetService("ReplicatedStorage") -- don't give this a type or else it will throw a warning for _T
local Packages = replicatedStorage.Packages
local _T = require(replicatedStorage.ClientTypes)
local Trove = require(Packages.Trove)

local createCommunicators = require(script.createCommunicators)

local function getRepositoryScripts(overrideRepository: Instance?)
	local repository = {}
	local function scanForRepository(repo: Instance)
		for _, repoScript: Instance in repo:GetChildren() do
			if not repoScript:IsA("ModuleScript") then continue end
			if repository[repoScript.Name] then continue end
			repository[repoScript.Name] = require(repoScript) :: any
		end
	end

	if overrideRepository then scanForRepository(overrideRepository) end
	scanForRepository(Repository)

	return repository
end

local clientParts: Instance = workspace:FindFirstChild("ClientParts") or Instance.new("Folder")
if not clientParts:IsDescendantOf(workspace) then -- this is probably such a silly way of doing this
	clientParts.Name = "ClientParts"
	clientParts.Parent = workspace
end

function manager:LoadClientObjects(clientObjectFolder: Folder)
	local character: Model = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	repeat
		task.wait()
	until character:IsDescendantOf(workspace)
	-- wait until the player's character exists because we're gonna need to attach it to the trove

	local currentTrove = Trove.new()
	-- currentTrove:Connect(localPlayer.CharacterRemoving, function() currentTrove:Destroy() end)
	-- remember to uncomment this because it'l be important in JToH

	local scriptRepository = getRepositoryScripts(workspace:FindFirstChild("RepositoryScripts", true))
	local modulesToRun = {}
	local function applyPart(part: Instance)
		if part:IsA("BasePart") then
			if part:FindFirstChild("invisible") or part:FindFirstChild("Invisible") or part:GetAttribute("Invisible") then
				part.Transparency = 1
			end

			part.CollisionGroup = "ClientObjects"
			local setCollisionGroupValue: Instance? = part:FindFirstChild("SetCollisionGroup")
			if setCollisionGroupValue and setCollisionGroupValue:IsA("StringValue") then
				part.CollisionGroup = setCollisionGroupValue.Value
			end

			local setCollisionGroupAttribute: string? = part:GetAttribute("SetCollisionGroup")
			if typeof(setCollisionGroupAttribute) == "string" then part.CollisionGroup = setCollisionGroupAttribute end
		end

		local loadFromRepo: string? = part:GetAttribute("LoadFromRepository")
		if typeof(loadFromRepo) == "string" and scriptRepository[loadFromRepo] ~= nil then
			local currentRepoScript = scriptRepository[loadFromRepo]
			if not (typeof(currentRepoScript) == "table" and currentRepoScript.LoadOnStart) then
				table.insert(modulesToRun, { instance = part, script = loadFromRepo })
			end
		end
	end

	for _, object: Instance in clientObjectFolder:GetChildren() do
		object.Parent = clientParts
		currentTrove:Add(object)

		applyPart(object)
		for _, descendant: Instance in object:GetDescendants() do
			applyPart(descendant)
		end
	end

	-- time to run scripts!
	local communicators = createCommunicators(currentTrove)

	-- load repository scripts that should load upon entering the tower
	for _, repositoryScript in scriptRepository do
		if typeof(repositoryScript) ~= "table" then continue end
		if not repositoryScript.LoadOnStart then continue end
		currentTrove:Add(task.spawn(
			repositoryScript.new,
			{
				trove = currentTrove,
				communicators = communicators,
				clientObjects = clientParts,
			} :: _T.Variables
		))
	end

	-- load requested scripts
	for _, scriptInfo in modulesToRun do
		if not scriptRepository[scriptInfo.script] then continue end -- shouldn't be possible
		local repositoryScript = scriptRepository[scriptInfo.script]
		currentTrove:Add(task.spawn(function()
			local variables: _T.Variables = {
				trove = currentTrove,
				communicators = communicators,
				clientObjects = clientParts,
				parent = scriptInfo.instance,
			}

			if typeof(repositoryScript) == "table" then
				repositoryScript.new(variables)
			elseif typeof(repositoryScript) == "function" then
				repositoryScript(variables)
			end
		end))
	end
end

getRepositoryScripts() -- Cache the repository scripts
return manager
