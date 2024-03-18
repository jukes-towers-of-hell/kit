--!strict

-->insert-corescript-warning<--

local tweenService: TweenService = game:GetService("TweenService")

--[=[
	@within utility
	@param easingStyle Enum.EasingStyle? --[EasingStyle](https://create.roblox.com/docs/reference/engine/enums/EasingStyle)
	@param easingDirection Enum.EasingDirection? --[EasingDirection](https://create.roblox.com/docs/reference/engine/enums/EasingDirection)
	
	Simple tween function that handles garbage collection properly.

	```lua
	scope.utility.tween(part, 0.5, {
		Color = Color3.fromRGB(255, 0, 0)
	})
	```
]=]
local function tween( -- long Function ...
	instance: Instance,
	time: number,
	goal: { [string]: any },
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	...: any
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
