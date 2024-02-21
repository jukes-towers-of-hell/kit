--!strict
-- ClientObjectManager by @synnwave

local manager = {}

local root = script:FindFirstAncestor("Client")
local Repository = root.Repository
local Packages = root.Packages

local replicatedStorage = game:GetService("ReplicatedStorage") -- don't give this a type or else it will throw a warning for _T
local _T = require(replicatedStorage.ClientTypes)
local Trove = require(Packages.Trove)
local Signal = require(Packages.Signal)
local RequestFunctions = require(script.RequestFunctions)

local Managers = root:FindFirstChild("Managers")
local Utility: _T.Utility = require(Managers.UtilityManager)
local lightingManager = require(Managers.LightingManager)

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
	local currentTrove: _T.Trove = Trove.new()
	local sharedCache = {} -- this table will be shared across all repository scripts, passed in as a reference
	local communicators = {
		event = currentTrove:Construct(Signal) :: _T.Signal,
		request = currentTrove:Construct(RequestFunctions) :: _T.RequestFunctions,
	}

	-- currentTrove:Connect(localPlayer.CharacterRemoving, function() currentTrove:Clean() end)
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

		local function addToQueue(loadFromRepo: string, part: Instance) -- i don't like repeating code .
			local currentRepoScript = scriptRepository[loadFromRepo]
			if currentRepoScript == nil then return end
			if not (typeof(currentRepoScript) == "table" and currentRepoScript.LoadOnStart) then
				table.insert(modulesToRun, { instance = part, script = loadFromRepo })
			end
		end

		local function applyPart(part: Instance)
			if part:IsA("BasePart") then
				if (Utility.checkConfig(part, "invisible") ~= nil) or (Utility.checkConfig(part, "Invisible") ~= nil) then
					part.Transparency = 1
				end

				local setCollisionGroup = Utility.checkConfig(part, "SetCollisionGroup")
				if typeof(setCollisionGroup) ~= "string" then setCollisionGroup = "ClientObjects" end
				part.CollisionGroup = setCollisionGroup
			end

			local loadFromRepo: string? = part:GetAttribute("LoadFromRepository")
			if typeof(loadFromRepo) == "string" then addToQueue(loadFromRepo, part) end -- load repository script from Attribute
			if (part.Name == "LoadFromRepository" and part.Parent) and part:IsA("StringValue") then -- load repository script from String Value
				addToQueue(part.Value, part.Parent)
			end
		end

		if applySelf then
			currentTrove:Add(path)
			applyPart(path)
		end

		for _, object: Instance in path:GetChildren() do
			if firstLoad then object.Parent = clientParts end
			currentTrove:Add(object)

			if object:GetAttribute("DoNotApply") then continue end
			applyPart(object)
			for _, descendant: Instance in object:GetDescendants() do
				if descendant:GetAttribute("DoNotApply") then continue end
				if firstLoad then
					if Utility.isPushbox(descendant) or Utility.isTurret(descendant) then continue end -- Pushboxes & Turrets will use the applyPart function later
				end

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
					utility = Utility,
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
	currentTrove:Connect(communicators.event, function(type: string, ...) -- listen to events
		if type == "apply-part" then
			local path: Instance = ...
			if typeof(path) ~= "Instance" then return end
			scanParts(path, false, true)
		end

		if type == "change-lighting" then -- change lighting on request
			local config: _T.LightingConfiguration = ...
			lightingManager:ChangeLighting(config)
		end
	end)
end

task.spawn(getRepositoryScripts) -- Cache the repository scripts into the memory
return manager
