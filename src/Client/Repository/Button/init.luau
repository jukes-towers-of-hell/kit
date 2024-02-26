--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local runService: RunService = game:GetService("RunService")
local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local handleCache = require(script.CacheHandler)
type Button = handleCache.Button

return function(scope: _T.Variables)
	local button, trove, shared, utility, communicators = scope.parent, scope.trove, scope.shared, scope.utility, scope.communicators
	if not button then return end

	-- check if cache exists, if not then take care of the cache from now on --
	if shared.button_cache == nil then handleCache(scope) end

	-- initialize button --
	local buttonPart: Instance? = button:FindFirstChild("ButtonPart")
	local configurations: Instance? = button:FindFirstChild("ButtonConfigurations")
	local timerTextLabel: TextLabel? = button:FindFirstChildWhichIsA("TextLabel")
	if (not (buttonPart and buttonPart:IsA("BasePart"))) or not configurations then return end

	local currentTrove = trove:Extend()
	currentTrove:Add(function() trove:Remove(currentTrove) end)
	currentTrove:AttachToInstance(button)
	currentTrove:Add(function() shared.button_cache.Buttons[button] = nil end)

	local currentButton: Button = {
		Button = buttonPart,
		Configuration = configurations,
		Color = utility.roundColor(buttonPart.Color),
		Pressed = currentTrove:Construct(Instance, "BoolValue"), -- basically Instance.new("BoolValue") but it will also get added to the trove
		ID = utility.generateUID(false, true),
		TotalPresses = 0,
	}

	currentButton.Pressed.Parent = button
	shared.button_cache.Buttons[button] = currentButton
	local function updatePlatforms(pressed: boolean?)
		communicators.event:Fire(
			"update-button-platforms",
			currentButton,
			if pressed ~= nil then pressed else currentButton.Pressed.Value
		)
	end

	-- button functions --
	local function getTimerColor(): (Color3, Color3)
		if not timerTextLabel then return Color3.new(), Color3.new() end
		local currentColor: Color3 = currentButton.Color
		if utility.hasTag(timerTextLabel, "DefaultColor") then -- default color
			return currentColor, Color3.new(1 - currentColor.R, 1 - currentColor.G, 1 - currentColor.B)
		elseif utility.hasTag(timerTextLabel, "AlternativeDefaultColor") then -- special default color
			return currentColor, utility.subtractHSV(currentColor)
		end

		return timerTextLabel.TextColor3, timerTextLabel.TextStrokeColor3
	end

	local function attachTimer(textLabel: TextLabel)
		local effectGui = playerGui:FindFirstChild("EffectGUI")
		if not effectGui then return end

		local screenText = textLabel:Clone()
		screenText.TextColor3, screenText.TextStrokeColor3 = getTimerColor()
		screenText.TextStrokeTransparency = 0

		local attachValue = Instance.new("ObjectValue")
		attachValue.Name = "AttachToInstance"
		attachValue.Value = textLabel
		attachValue.Parent = screenText

		screenText.Parent = effectGui:FindFirstChild("TimerList")
		local timerTrove = currentTrove:Extend()
		timerTrove:AttachToInstance(textLabel)
		timerTrove:Connect(textLabel.Changed, function() screenText.Text = textLabel.Text end)
		timerTrove:Add(function()
			screenText:Destroy()
			currentTrove:Remove(timerTrove)
		end)
	end
	----------------------

	-- handle button --
	local buttonSound: Instance? = buttonPart:FindFirstChild("Press")
	local debounce = false
	local originalCFrame = buttonPart.CFrame

	updatePlatforms(false)
	currentTrove:Connect(currentButton.Pressed:GetPropertyChangedSignal("Value"), function()
		currentButton.TotalPresses += 1

		local isPressed: boolean = currentButton.Pressed.Value
		local pressedCFrame = originalCFrame * CFrame.new(0, -(utility.checkConfig(configurations, "ButtonPressOffset") or 0.75), 0)

		buttonPart.Material = if isPressed
			then utility.getEnumFromString(utility.checkConfig(configurations, "PressedMaterial"), Enum.Material.Neon)
			else utility.getEnumFromString(utility.checkConfig(configurations, "UnpressedMaterial"), Enum.Material.Metal)

		if buttonPart.Anchored and (not utility.isSequence(button)) then
			utility.tween(buttonPart, 1, { CFrame = if isPressed then pressedCFrame else originalCFrame })
		end
		if isPressed and (buttonSound and buttonSound:IsA("Sound")) then buttonSound:Play() end
		updatePlatforms()

		-- the timer should be in this function, no?
		if not isPressed then return end
		local buttonTimer: number = utility.checkConfig(configurations, "Timer") or 0
		if buttonTimer <= 0 then return end
		if not timerTextLabel then return end

		local textOverride: string = utility.checkConfig(configurations, "TimerText") or ""
		local savedTotalPresses: number = currentButton.TotalPresses

		local timerTrove = currentTrove:Extend()
		timerTrove:Add(function() currentTrove:Remove(timerTrove) end)

		local surfaceGui: SurfaceGui = timerTrove:Construct(Instance, "SurfaceGui")
		surfaceGui.Face = Enum.NormalId.Top
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 25

		local currentLabel = timerTextLabel:Clone()
		currentLabel.Parent = surfaceGui
		currentLabel.TextColor3, currentLabel.TextStrokeColor3 = getTimerColor()
		currentLabel.Text = if textOverride then textOverride:gsub(textOverride, tostring(buttonTimer)) else tostring(buttonTimer)

		surfaceGui.Parent = buttonPart
		local guiHidden = utility.checkConfig(configurations, "HideGUI")
		if guiHidden then
			surfaceGui.Enabled = false
		else
			attachTimer(currentLabel)
		end

		local decimalPlaces: number = (
			utility.checkConfig(timerTextLabel, "DecimalPlaces") or utility.checkConfig(configurations, "DecimalPlaces")
		) or 0

		timerTrove:Add(function()
			if currentButton.TotalPresses ~= savedTotalPresses then return end
			currentButton.Pressed.Value = false
		end)

		local startClock: number = os.clock()
		timerTrove:Connect(runService.Heartbeat, function()
			if currentButton.TotalPresses ~= savedTotalPresses then return timerTrove:Clean() end

			local elapsedTime: number = buttonTimer - (os.clock() - startClock)
			if elapsedTime <= 0 then return timerTrove:Clean() end

			if guiHidden then return end
			local displayTime = string.format(`%0.{decimalPlaces}f`, elapsedTime)
			currentLabel.Text = if textOverride then textOverride:gsub(textOverride, displayTime) else displayTime
		end)
	end)

	currentTrove:Connect(buttonPart.Touched, function(toucher: BasePart)
		if debounce then return end
		if currentButton.Pressed.Value then return end
		if not utility.evaluateToucher(buttonPart, toucher, configurations) then return end

		local buttonActivated: boolean = utility.checkConfig(buttonPart, "Activated")
		if typeof(buttonActivated) == "boolean" and not buttonActivated then return end

		currentButton.Pressed.Value = true
		debounce = true
		task.delay(0.15, function() debounce = false end)
	end)
end
