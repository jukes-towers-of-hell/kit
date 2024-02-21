--!strict
local tweenService: TweenService = game:GetService("TweenService")
return function( -- long Function ...
	instance: Instance,
	time: number,
	goal: { [string]: any },
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	...
): Tween
	local tween: Tween = tweenService:Create(
		instance,
		TweenInfo.new(
			time,
			(if typeof(easingStyle) == "EnumItem" then easingStyle else Enum.EasingStyle.Linear),
			(if typeof(easingDirection) == "EnumItem" then easingDirection else Enum.EasingDirection.Out),
			...
		),
		goal
	)
	tween.Completed:Once(function() tween:Destroy() end)
	tween:Play()
	return tween
end
