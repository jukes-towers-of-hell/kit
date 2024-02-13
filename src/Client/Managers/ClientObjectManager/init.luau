--!strict
-- ClientObjectManager by @synnwave

local manager = {}

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
		for _, repoScript: Instance in repo:GetDescendants() do
			if not repoScript:IsA("ModuleScript") then continue end
			if repoScript.Parent and repoScript.Parent:IsA("ModuleScript") then continue end -- do not load any submodules
			if repository[repoScript.Name] then continue end
			repository[repoScript.Name] = require(repoScript) :: any
		end
	end

	if typeof(overrideRepository) == "Instance" then scanForRepository(overrideRepository) end
	scanForRepository(Repository)

	return repository
end

local clientParts: Instance = workspace:FindFirstChild("ClientParts") or Instance.new("Folder")
if not clientParts:IsDescendantOf(workspace) then -- this is probably such a silly way of doing this
	clientParts.Name = "ClientParts"
	clientParts.Parent = workspace
end

function manager:LoadClientObjects(clientObjectFolder: Folder)
	local currentTrove = Trove.new()
	local communicators = createCommunicators(currentTrove)
	local sharedCache = {} -- this table will be shared across all repository scripts, passed in as a reference

	-- currentTrove:Connect(localPlayer.CharacterRemoving, function() currentTrove:Destroy() end)
	-- remember to uncomment this because it'l be important in JToH

	local scriptRepository = getRepositoryScripts(workspace:FindFirstChild("RepositoryScripts", true))
	local function scanParts(path: Instance, firstLoad: boolean, applySelf: boolean?)
		local modulesToRun: { { instance: Instance?, script: string } } = {}
		if firstLoad then
			for scriptName, repositoryScript in scriptRepository do -- queue up repository scripts that should load upon entering the tower
				if typeof(repositoryScript) ~= "table" then continue end
				if not repositoryScript.LoadOnStart then continue end
				table.insert(modulesToRun, { script = scriptName })
			end
		end

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

		if applySelf then
			currentTrove:Add(path)
			applyPart(path)
		end

		for _, object: Instance in path:GetChildren() do
			if firstLoad then object.Parent = clientParts end
			currentTrove:Add(object)

			applyPart(object)
			for _, descendant: Instance in object:GetDescendants() do
				applyPart(descendant)
			end
		end

		-- time to run scripts!
		for _, scriptInfo in modulesToRun do
			local repositoryScript = scriptRepository[scriptInfo.script]
			if not repositoryScript then continue end -- shouldn't be possible

			currentTrove:Add(task.spawn(function()
				local scope: _T.Variables = {
					trove = currentTrove,
					communicators = communicators,
					clientObjects = clientParts,
					parent = scriptInfo.instance,
					shared = sharedCache,
				}

				if typeof(repositoryScript) == "table" then
					repositoryScript.new(scope)
				elseif typeof(repositoryScript) == "function" then
					repositoryScript(scope)
				end
			end))
		end
	end

	scanParts(clientObjectFolder, true, false)
	currentTrove:Connect(communicators.event.Event, function(type: string, ...)
		if type == "apply-part" then
			local path: Instance = ...
			if typeof(path) ~= "Instance" then return end
			scanParts(path, false, true)
		end
	end)
end

task.spawn(getRepositoryScripts) -- Cache the repository scripts into the memory
return manager
