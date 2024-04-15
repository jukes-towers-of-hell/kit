--!strict

-- Teleporter, by @synnwave

-->insert-corescript-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Players = game:GetService("Players")

local DISABLE_COLLSION_PROPERTIES: { [string]: any } = {
	CollisionGroup = "NeverCollide",
	CanTouch = false,
}

local PART_BLACKLIST = {
	"CosmeticVisPart",
	"InvisPart",
	"WeldPart",
	"Left Arm",
	"Right Arm",
}

local ALLOWED_EVALUATION_CHECKS = {
	allowPlayer = true,
	allowPushbox = true,
	allowColorSpecific = false,
	allowBalloons = false,
	allowTurrets = false,
}

return function(scope: _T.Variables)
	local teleporter, trove, utility, shared = scope.parent, scope.trove, scope.utility, scope.shared
	if not teleporter then return end

	local configuration: Instance? = teleporter:FindFirstChild("TeleporterConfiguration")
	if not configuration then return end

	local localPlayer = Players.LocalPlayer

	local keepVelocity = utility.getConfig(configuration, "KeepVelocity", true)
	local disableCollision = utility.getConfig(configuration, "DisableCollision", false)
	local seamlessTeleport = utility.getConfig(configuration, "SeamlessTeleport", false)
	local removeButtons = utility.getConfig(configuration, "RemoveButtons", false)
	local transitionTime = utility.getConfig(configuration, "TransitionTime", 0)
	local easingStyle = utility.getConfig(configuration, "EasingStyle", Enum.EasingStyle.Quad)
	local easingDirection = utility.getConfig(configuration, "EasingDirection", Enum.EasingDirection.Out)
	if seamlessTeleport then transitionTime = 0 end

	local teleportingParts: { [BasePart]: boolean } = {}
	local teleporterCooldowns: { [BasePart]: boolean } = {}
	local function teleport(object: BasePart, teleporterPart: BasePart, destination: BasePart, isPlayer: boolean)
		local camera: Camera = workspace.CurrentCamera

		if teleporterCooldowns[teleporterPart] or teleportingParts[object] then return end
		teleportingParts[object] = true
		teleporterCooldowns[teleporterPart] = true
		local cooldown = utility.getConfig(teleporter, "Cooldown", 0)
		if cooldown > 0 then
			task.delay(cooldown, function() teleporterCooldowns[teleporterPart] = false end)
		else
			task.defer(function() teleporterCooldowns[teleporterPart] = false end)
		end

		local savedPartProperties: { [BasePart]: any } = { [object] = { Anchored = object.Anchored } }
		if not keepVelocity then
			object.AssemblyLinearVelocity = Vector3.zero
			object.AssemblyAngularVelocity = Vector3.zero
			savedPartProperties[object].AssemblyLinearVelocity = Vector3.zero
			savedPartProperties[object].AssemblyAngularVelocity = Vector3.zero
		end

		if disableCollision then
			local parts = { object }
			if isPlayer and localPlayer.Character then
				for _, part in localPlayer.Character:GetChildren() do
					if not part:IsA("BasePart") then continue end
					if table.find(parts, part) then continue end
					table.insert(parts, part)
				end
			end

			for _, part in parts do
				if not savedPartProperties[part] then savedPartProperties[part] = {} end
				for property, value in DISABLE_COLLSION_PROPERTIES do
					savedPartProperties[part][property] = utility.getInstanceProperty(part, property)
					utility.setInstanceProperty(part, property, value)
				end
			end
		end

		local targetCFrame = destination.CFrame * CFrame.new(Vector3.yAxis * 5)
		if seamlessTeleport then
			targetCFrame = destination.CFrame * teleporterPart.CFrame:ToObjectSpace(object.CFrame)
			if isPlayer then camera.CFrame = destination.CFrame * teleporterPart.CFrame:ToObjectSpace(camera.CFrame) end
		end

		utility.playSoundFromPart("TeleportSound", destination, destination)
		if transitionTime > 0 then
			object.Anchored = true
			utility.tween(object, transitionTime, { CFrame = targetCFrame }, easingStyle, easingDirection).Completed:Wait()
		else
			object.CFrame = targetCFrame
		end

		for part, properties in savedPartProperties do
			for property, value in properties do
				utility.setInstanceProperty(part, property, value)
			end
		end

		teleportingParts[object] = nil
	end

	local destinations: { BasePart } = {}
	local function getActiveDestinations(): { BasePart }
		local activeDestinations = {}
		for _, destination in destinations do
			if utility.checkConfig(destination, "Activated") == false then continue end
			table.insert(activeDestinations, destination)
		end

		return activeDestinations
	end

	local currentTrove = trove:Extend()
	currentTrove:AttachToInstance(teleporter)

	for _, object: Instance in teleporter:GetDescendants() do
		if not object:IsA("BasePart") then continue end

		if object.Name == "Destination" then table.insert(destinations, object) end
		if object.Name == "Teleporter" then
			currentTrove:Connect(object.Touched, function(touchingPart: BasePart)
				if teleporterCooldowns[object] then return end
				if table.find(PART_BLACKLIST, touchingPart.Name) then return end
				if not utility.evaluateToucher(object, touchingPart, configuration, ALLOWED_EVALUATION_CHECKS) then return end
				if utility.checkConfig(object, "Activated") == false then return end

				local currentDestinations = getActiveDestinations()
				if #currentDestinations <= 0 then return end

				local destination = currentDestinations[Random.new():NextInteger(1, #currentDestinations)]
				if removeButtons and shared.button_cache ~= nil then
					for _, button in shared.button_cache.Buttons do
						button.Pressed.Value = false
					end
				end

				local character: Model? = localPlayer.Character
				if character and character.PrimaryPart and touchingPart.Parent == character then
					teleport(character.PrimaryPart, object, destination, true)
				elseif utility.isPushbox(touchingPart) then
					teleport(touchingPart, object, destination, false)
				end
			end)
		end
	end
end
