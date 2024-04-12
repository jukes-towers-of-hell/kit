--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local cacheHandler = require(script.CacheHandler)
type Key = cacheHandler.Key
type KeyDoor = cacheHandler.KeyDoor

local DEFAULT_SPIN_SPEED = 5
local DOOR_DESTROY_METHODS = {
	Vanish = function(part: BasePart, scope: _T.Variables)
		part.CanCollide = false
		part.CanTouch = false
		scope.utility.tween(part, 0.5, { Transparency = 1 }).Completed:Once(function() part:Destroy() end)
	end,

	Fall = function(part: BasePart, scope: _T.Variables)
		local random = Random.new()
		local powerRange = scope.utility.getConfig(part, "FallPower", NumberRange.new(-10, 10))
		local function rng(multiplier: number) return random:NextInteger(powerRange.Min * multiplier, powerRange.Max * multiplier) end

		part.Anchored = false
		part.CanCollide = false
		part.AssemblyAngularVelocity = Vector3.new(rng(1), rng(1), rng(1))
		part.AssemblyLinearVelocity = Vector3.new(rng(3), rng(3), rng(3));
		(part :: any):BreakJoints()
	end,

	Destroy = function(part: BasePart) part:Destroy() end,
}

return function(scope: _T.Variables)
	local group, trove, utility = scope.parent, scope.trove, scope.utility
	if not group then return end

	local cache = cacheHandler.handle(scope)
	local thisGroup = cache.newGroup()

	local signs: { [any]: { label: TextLabel, pattern: string } } = {}
	for _, descendant: Instance in group:GetDescendants() do
		if descendant:IsA("TextLabel") then table.insert(signs, { label = descendant, pattern = descendant.Text }) end
	end

	for _, instance: Instance in group:GetChildren() do
		local hitbox: Instance? = instance:FindFirstChild("Hitbox")
		if instance:IsA("Model") and (hitbox and hitbox:IsA("BasePart")) then
			if instance.Name == "Key" then
				instance.PrimaryPart = hitbox
				local timerGui = hitbox:FindFirstChild("KeyTimer")
					or (function()
						local newTimerGui = script.KeyTimer:Clone()
						newTimerGui.Parent = hitbox
						return newTimerGui
					end)()

				thisGroup.addKey {
					instance = instance,
					originalCFrame = instance:GetPivot(),
					hitbox = hitbox,
					timerBillboard = timerGui,
					config = {
						spinSpeed = utility.getConfig(instance, "SpinSpeed", DEFAULT_SPIN_SPEED),
						timer = utility.getConfig(instance, "Timer", 0),
					},
				}
			elseif instance.Name == "Door" then
				local parts: { [BasePart]: string } = {}
				local doorParts: Instance? = instance:FindFirstChild("DoorParts")
				if doorParts then
					for _, part in doorParts:GetDescendants() do
						if not part:IsA("BasePart") then continue end
						parts[part] = if DOOR_DESTROY_METHODS[part.Name] ~= nil then part.Name else "Destroy"
					end
				end

				thisGroup.addDoor {
					instance = instance,
					hitbox = hitbox,
					doorParts = parts,
					requiredKeys = utility.getConfig(instance, "RequiredKeys", 1),
				}
			end
		end

		if instance.Name == "ReturnKey" and instance:IsA("BasePart") then
			instance.Touched:Connect(function(toucher: BasePart)
				if not utility.evaluateToucher(instance, toucher) then return end
				for _, key in thisGroup.keys do
					key.returnKey()
				end
			end)
		end
	end

	for _, key in thisGroup.keys do
		key.hitbox.Touched:Connect(function(toucher: BasePart)
			if not utility.evaluateToucher(key.hitbox, toucher) then return end
			key.collect()
		end)
	end
end
