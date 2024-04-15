--!strict

-->insert-repository-warning<--

local runService: RunService = game:GetService("RunService")
local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local CACHE_KEY = "pushing_platform_trampoline_cache"
local LAUNCH_FORCE = 3
local PRISMATIC_LIMIT = 0.2

type Trampoline = {
	force: Vector3,
	launchForce: number,
	vectorForce: VectorForce,
	prismatic: PrismaticConstraint,
	isLaunching: boolean,
}

return function(scope: _T.Variables)
	local parent, trove, shared, utility = scope.parent, scope.trove, scope.shared, scope.utility
	if not parent then return end

	local anchor: Instance? = parent:FindFirstChild("Anchor")
	local base: Instance? = parent:FindFirstChild("Base")
	if not ((anchor and anchor:IsA("BasePart")) and (base and base:IsA("BasePart"))) then return end

	local prismatic: PrismaticConstraint? = anchor:FindFirstChildOfClass("PrismaticConstraint")
	local vectorForce: VectorForce? = base:FindFirstChildOfClass("VectorForce")
	if not (prismatic and vectorForce) then return end

	if shared[CACHE_KEY] == nil then
		local cacheReference: { [string]: Trampoline } = {}
		shared[CACHE_KEY] = cacheReference

		trove:Connect(runService.PreSimulation, function()
			debug.profilebegin("Set PushingPlatformTrampoline Forces")

			for id, data in cacheReference do
				if not data.vectorForce:IsDescendantOf(workspace) then
					cacheReference[id] = nil
					continue
				end

				local thisPrismatic = data.prismatic
				local thisVectorForce = data.vectorForce
				if not data.isLaunching and (thisPrismatic.CurrentPosition >= (thisPrismatic.UpperLimit - PRISMATIC_LIMIT)) then
					cacheReference[id].isLaunching = true
					thisVectorForce.Force = (data.force * data.launchForce)
				elseif data.isLaunching and (thisPrismatic.CurrentPosition <= (thisPrismatic.LowerLimit + PRISMATIC_LIMIT)) then
					cacheReference[id].isLaunching = false
					thisVectorForce.Force = data.force
				end
			end

			debug.profileend()
		end)
	end

	local platformId = utility.generateUID(false, true)
	local totalMass = 100
	for _, part: Instance in parent:GetDescendants() do
		if not (part:IsA("BasePart") and not part.Anchored) then continue end
		totalMass += (part.Mass * workspace.Gravity)
	end

	local finalForce = (Vector3.zAxis * totalMass)
	vectorForce.Force = -finalForce

	local trampoline: Trampoline = {
		force = finalForce,
		launchForce = utility.getConfig(parent, "LaunchForce", LAUNCH_FORCE),
		vectorForce = vectorForce,
		prismatic = prismatic,
		isLaunching = false,
	}
	shared[CACHE_KEY][platformId] = trampoline

	local currentTrove = trove:Extend()
	currentTrove:AttachToInstance(parent)
	currentTrove:Add(function()
		trove:Remove(currentTrove)
		shared[CACHE_KEY][platformId] = nil
	end)
end
