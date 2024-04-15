--!strict

-- Elevators, by @synnwave

-->insert-corescript-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Players = game:GetService("Players")

local ALLOWED_CFRAME_COMPONENTS = {
	"UpVector",
	"RightVector",
	"LookVector",
	"ZVector",
}

local ALLOWED_EVALUATION_CHECKS = {
	allowPlayer = true,
	allowPushbox = true,
	allowColorSpecific = true,
	allowBalloons = false,
	allowTurrets = false,
}

return function(scope: _T.Variables)
	local elevator, trove, utility = scope.parent, scope.trove, scope.utility
	if not (elevator and elevator:IsA("BasePart")) then return end

	local touchingParts: { [BasePart]: boolean } = {}
	local localPlayer = Players.LocalPlayer

	local currentTrove = trove:Extend()
	currentTrove:AttachToInstance(elevator)
	currentTrove:Connect(elevator.Touched, function(touchingPart: BasePart)
		if utility.checkConfig(elevator, "Activated") == false then return end
		if not utility.evaluateToucher(elevator, touchingPart, elevator, ALLOWED_EVALUATION_CHECKS) then return end

		local part: BasePart
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include

		local character: Model? = localPlayer.Character
		if character and touchingPart.Parent == character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not (rootPart and rootPart:IsA("BasePart")) then return end

			part = rootPart
			for _, characterPart: Instance in character:GetChildren() do
				if not characterPart:IsA("BasePart") then continue end
				params:AddToFilter(characterPart)
			end
		elseif utility.isPushbox(touchingPart) then
			part = touchingPart
			params:AddToFilter(touchingPart)
		end

		if not part then return end
		if touchingParts[part] then return end

		local speed = utility.getConfig(elevator, "Speed", 40)
		local maxForce = utility.getConfig(elevator, "MaxForce", math.huge)
		local vector = utility.checkConfig(elevator, "Vector")
		if not table.find(ALLOWED_CFRAME_COMPONENTS, vector) then vector = ALLOWED_CFRAME_COMPONENTS[1] end

		local faceVector: Vector3 = utility.getInstanceProperty(elevator.CFrame, vector) -- this isn't an instance but it works!
		if not faceVector then return end

		local currentMaxForce = Vector3.new(0, maxForce, 0) -- Pro Tip : don't do Vector3.yAxis * math.huge
		if faceVector.X ~= 0 then currentMaxForce = Vector3.new(maxForce, currentMaxForce.Y, currentMaxForce.Z) end
		if faceVector.Z ~= 0 then currentMaxForce = Vector3.new(currentMaxForce.X, currentMaxForce.Y, maxForce) end

		local velocityAttachment = Instance.new("Attachment")
		velocityAttachment.Parent = part

		local velocity = Instance.new("LinearVelocity")
		velocity.Name = "ElevatorVelocity"
		velocity.RelativeTo = Enum.ActuatorRelativeTo.World
		velocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
		velocity.Attachment0 = velocityAttachment
		velocity.ForceLimitsEnabled = true
		velocity.MaxAxesForce = currentMaxForce
		velocity.VectorVelocity = faceVector * speed
		velocity.Parent = part

		-- new touchended implementation --
		touchingParts[part] = true
		while touchingParts[part] do
			if not elevator.CanTouch then break end
			if utility.checkConfig(elevator, "Activated") == false then break end
			task.wait()
			local zoneParts: { BasePart } = workspace:GetPartsInPart(elevator, params)
			if #zoneParts <= 0 then break end
		end

		touchingParts[part] = nil
		velocity:Destroy()
		velocityAttachment:Destroy()
	end)
end
