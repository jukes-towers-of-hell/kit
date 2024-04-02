--!strict

-->insert-repository-warning<--

local GOLDEN_MASS = 4.8 -- this is the mass in cubic studs
local RELEASE_FORCE = Vector3.one * math.huge
local RELEASE_VELOCITY = math.huge

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

return function(scope: _T.Variables)
	local fallingPlatform, trove, utility = scope.parent, scope.trove, scope.utility
	if not fallingPlatform then return end

	local endPart = fallingPlatform:FindFirstChild("End")
	local platform = fallingPlatform:FindFirstChild("Platform")
	if not ((platform and platform:IsA("BasePart")) and (endPart and endPart:IsA("BasePart"))) then return end

	-- set up main platform --
	local platformAlign: AlignPosition? = platform:FindFirstChildWhichIsA("AlignPosition")
	if not platformAlign then return end

	local massValue = utility.getConfig(fallingPlatform, "CustomMass", GOLDEN_MASS)
	local oldCustomPhysical = platform.CustomPhysicalProperties or platform.CurrentPhysicalProperties
	platform.CustomPhysicalProperties = PhysicalProperties.new(
		(1 / (platform.Mass * oldCustomPhysical.Density)) * massValue,
		oldCustomPhysical.Friction,
		oldCustomPhysical.Elasticity,
		oldCustomPhysical.FrictionWeight,
		oldCustomPhysical.ElasticityWeight
	)

	platformAlign.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	platformAlign.ForceRelativeTo = Enum.ActuatorRelativeTo.World
	platformAlign.Position = platform.Position
	platform.Position = platform.Position - (platform.CFrame.UpVector * 2)
	platform.Anchored = false

	local oldForce: Vector3 = platformAlign.MaxAxesForce
	local oldVelocity: number = platformAlign.MaxVelocity
	local function reset(time: number)
		platformAlign.MaxAxesForce = RELEASE_FORCE
		platformAlign.MaxVelocity = RELEASE_VELOCITY
		task.wait(time)
		platformAlign.MaxAxesForce = oldForce
		platformAlign.MaxVelocity = oldVelocity
	end

	task.spawn(reset, 0.5)

	-- set up end platform --
	local releaseTransparency = utility.getConfig(fallingPlatform, "ReleaseTransparency", 0.8)
	local oldTransparency = platform.Transparency

	local currentTrove = trove:Extend()
	currentTrove:Add(function() trove:Remove(currentTrove) end)

	local debounce = false
	endPart.CanCollide = false
	currentTrove:Connect(endPart.Touched, function(hit: BasePart)
		if hit ~= platform then return end
		if debounce then return end
		debounce = true

		platform.CanCollide = false
		platform.Transparency = releaseTransparency
		reset(1.5)
		platform.CanCollide = true
		platform.Transparency = oldTransparency

		debounce = false
	end)
end
