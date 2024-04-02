--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local cacheHandler = require(script.CacheHandler)
type Key = cacheHandler.Key
type KeyDoor = cacheHandler.KeyDoor

local DEFAULT_SPIN_SPEED = 5

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
				thisGroup.addKey {
					instance = instance,
					originalCFrame = instance:GetPivot(),
					hitbox = hitbox,
					active = false,
					cooldown = false,
					config = {
						spinSpeed = utility.getConfig(instance, "SpinSpeed", DEFAULT_SPIN_SPEED),
						timeData = {},
					},
				}
			elseif instance.Name == "Door" then
				local parts = {}

				thisGroup.addDoor {
					instance = instance,
					hitbox = hitbox,
				}
			end
		end
	end
end
