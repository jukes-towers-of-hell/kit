--!strict

-->insert-corescript-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local ALLOWED_EVALUATION_CHECKS = {
	allowPlayer = true,
	allowPushbox = true,
	allowColorSpecific = true,
	allowBalloons = false,
	allowTurrets = false,
}

return function(scope: _T.Variables)
	local changer, trove, utility, communicators = scope.parent, scope.trove, scope.utility, scope.communicators
	if not (changer and changer:IsA("BasePart")) then return end

	local changerConfiguration: Instance? = changer:FindFirstChild("LightingChangerConfiguration")
	if not changerConfiguration then return end

	local currentTrove = trove:Extend()
	currentTrove:AttachToInstance(changer)
	currentTrove:Connect(changer.Touched, function(touchingPart: BasePart)
		if not utility.evaluateToucher(changer, touchingPart, nil, ALLOWED_EVALUATION_CHECKS) then return end

		local targetInstance: Instance? = changerConfiguration:FindFirstChild("TargetLighting")
		local changerType = if targetInstance then targetInstance.ClassName else utility.getConfig(changerConfiguration, "Type", "")
		if not changerType then return end

		local tweenInfo = TweenInfo.new(
			utility.getConfig(changerConfiguration, "Time", 1),
			utility.getConfig(changerConfiguration, "EasingStyle", Enum.EasingStyle.Linear),
			utility.getConfig(changerConfiguration, "EasingDirection", Enum.EasingDirection.Out)
		)

		local changerConfigrations = changerConfiguration:GetAttributes()
		for _, value: Instance in changerConfiguration:GetChildren() do
			if not value:IsA("ValueBase") then continue end
			changerConfigrations[value.Name] = (value :: any).Value
		end
		changerConfigrations.Type = nil
		changerConfigrations.Time = nil
		changerConfigrations.EasingStyle = nil
		changerConfigrations.EasingDirection = nil

		communicators.event:Fire("change-lighting", {
			Type = changerType,
			Configuration = changerConfiguration,
			TweenInfo = tweenInfo,
		})
	end)
end
