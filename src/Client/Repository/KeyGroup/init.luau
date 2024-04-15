--!strict
-- KeyGroup by @synnwave

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local cacheHandler = require(script.CacheHandler)
type Key = cacheHandler.Key
type KeyDoor = cacheHandler.KeyDoor

local DEFAULT_SPIN_SPEED = 5

return function(scope: _T.Variables)
	local group, trove, utility, communicators = scope.parent, scope.trove, scope.utility, scope.communicators
	if not group then return end

	local cache = cacheHandler.handle(scope)
	local thisGroup = cache.newGroup()

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
						parts[part] = if cacheHandler.DOOR_DESTROY_METHODS[part.Name] ~= nil then part.Name else "Destroy"
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
		trove:Connect(key.hitbox.Touched, function(toucher: BasePart)
			if not utility.evaluateToucher(key.hitbox, toucher) then return end
			key.collect()
		end)
	end

	local signs: { [TextLabel]: string } = {}
	for _, descendant: Instance in group:GetDescendants() do
		if descendant:IsA("TextLabel") then signs[descendant] = descendant.Text end
	end

	for _, door in thisGroup.doors do
		trove:Connect(door.hitbox.Touched, function(toucher: BasePart)
			if not utility.evaluateToucher(door.hitbox, toucher) then return end
			for _, key in thisGroup.keys do
				if not key.active then continue end
				door.useKey(key.ID)
			end
		end)

		local function updateSigns()
			local requiredKeys = door.requiredKeys
			local keysUsed = #door.usedKeys
			local keysLeft = requiredKeys - keysUsed
			local keysLeftRemainder = if keysLeft == 1 then "" else "s"
			for label, pattern in signs do
				if not label:IsDescendantOf(door.instance) then continue end
				label.Text = pattern
					:gsub("{REQUIRED_KEYS}", tostring(requiredKeys))
					:gsub("{KEYS_USED}", tostring(keysUsed))
					:gsub("{KEYS_LEFT}", tostring(keysLeft))
					:gsub("{KEYS_LEFT_REMAINDER}", keysLeftRemainder)
			end
		end

		updateSigns()
		trove:Connect(communicators.event, function(requestID: string)
			if requestID ~= door.ID then return end
			updateSigns()
		end)
	end
end
