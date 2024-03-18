--!strict
-- ClientObjectManager by @synnwave

-->insert-corescript-warning<--

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
local log = require(script.log)

local DEBUG = true --workspace:GetAttribute("DEBUG_ENABLED")

local function getRepositoryScripts(scope: _T.Variables?, overrideRepository: Instance?)
	local repository = {}
	local function scanForRepository(repo: Instance)
		local repoPath = repo:GetFullName()
		for _, repoScript: Instance in repo:GetDescendants() do
			if not repoScript:IsA("ModuleScript") then continue end
			if repoScript.Parent and repoScript.Parent:IsA("ModuleScript") then continue end -- do not load any submodules

			local path = repoScript:GetFullName():gsub(repoPath, ""):sub(2) -- crazy...
			if repository[path] then continue end

			local required = require(repoScript) :: any
			if typeof(required) == "table" then
				if required.DoNotInclude then continue end
				if typeof(required.init) == "function" and (scope ~= nil) then required = required.init(scope) end
			end
			repository[path] = required
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
	if clientObjectFolder:GetAttribute("KitVersion") ~= script:GetAttribute("KitVersion") then
		log(nil, `kit versions don't match!!`, true, "warn")
	end

	local currentTrove: _T.Trove = Trove.new()
	local sharedCache = {} -- this table will be shared across all repository scripts, passed in as a reference
	local communicators = {
		event = currentTrove:Construct(Signal) :: _T.Signal,
		request = currentTrove:Construct(RequestFunctions) :: _T.RequestFunctions,
	}

	-- currentTrove:Connect(localPlayer.CharacterRemoving, function() currentTrove:Clean() end)
	-- remember to uncomment this because it'l be important in JToH

	local scriptRepository
	local scope: _T.Variables = {
		trove = currentTrove,
		communicators = communicators,
		clientObjects = clientParts,
		shared = sharedCache,
		utility = Utility,
		repository = scriptRepository,
		debug = DEBUG,
		log = function(scopeSelf: any, ...)
			if not (typeof(scopeSelf) == "table" and scopeSelf.debug) then return end
			log(scopeSelf, ...)
		end,
	}

	scriptRepository = getRepositoryScripts(scope, workspace:FindFirstChild("RepositoryScripts", true))
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
			if currentRepoScript == nil then return log(nil, `script "{loadFromRepo}" doesn't exist in repository!!`, true, "warn") end
			if not (typeof(currentRepoScript) == "table" and currentRepoScript.LoadOnStart) then
				table.insert(modulesToRun, { instance = part, script = loadFromRepo })
			end
		end

		local function applyPart(part: Instance)
			if part:IsA("BasePart") then
				if Utility.hasTag(part, "invisible") or Utility.hasTag(part, "Invisible") then part.Transparency = 1 end

				if part.CollisionGroup == "Default" then part.CollisionGroup = "ClientObjects" end
				part.CollisionGroup = Utility.getConfig(part, "SetCollisionGroup", part.CollisionGroup)
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
				debug.setmemorycategory(scriptInfo.script)
				local newScope: _T.Variables = table.clone(scope)
				newScope.parent = scriptInfo.instance
				newScope.scriptPath = scriptInfo.script

				if typeof(repositoryScript) == "table" then
					repositoryScript.new(newScope)
				elseif typeof(repositoryScript) == "function" then
					repositoryScript(newScope)
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
