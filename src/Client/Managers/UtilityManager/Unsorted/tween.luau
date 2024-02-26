--!strict
local tweenService: TweenService = game:GetService("TweenService")

--[=[
@within utility
@param ... ...
]=]
local function tween( -- long Function ...
	instance: Instance,
	time: number,
	goal: { [string]: any },
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	...
): Tween
	local tweenObject: Tween = tweenService:Create(
		instance,
		TweenInfo.new(
			time,
			(if typeof(easingStyle) == "EnumItem" then easingStyle else Enum.EasingStyle.Linear),
			(if typeof(easingDirection) == "EnumItem" then easingDirection else Enum.EasingDirection.Out),
			...
		),
		goal
	)
	tweenObject.Completed:Once(function() tweenObject:Destroy() end)
	tweenObject:Play()
	return tweenObject
end

return tween
