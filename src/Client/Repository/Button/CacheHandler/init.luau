--!strict
-- this is being split into two scripts because i don't want the main script to be cluttered

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local PART_BUFFER = 64 -- every 64 button platforms activated will wait a frame to prevent *some* lag
local TWEEN_TRANSPARENCY_PROPERTIES: { [string]: string } = { -- things that can have their transparency tweened
	Decal = "Transparency",
	Texture = "Transparency",
	SelectionBox = "Transparency",
	SelectionSphere = "Transparency",
	Frame = "BackgroundTransparency",
	CanvasGroup = "GroupTransparency",
	TextLabel = "TextTransparency",
	ImageLabel = "ImageTransparency",
}
local SET_PROPERTIES_ENABLED = { -- these will just have their enabled property change instead of being tweened
	"Beam",
	"ParticleEmitter",
	"Fire",
	"Sparkles",
	"Smoke",
	"Trail",
	"UIStroke",
	"UIGradient",
}

export type Button = {
	Button: BasePart,
	Configuration: Instance,
	Color: Color3,
	Pressed: BoolValue,
	ID: string,
	TotalPresses: number,
}

local sequencerManager = require(script.SequencerManager)

return function(scope: _T.Variables)
	local clientObjects, trove, shared, utility, communicators =
		scope.clientObjects, scope.trove, scope.shared, scope.utility, scope.communicators
	if shared.button_cache ~= nil then return end -- already being handled by something else

	local cacheReference: { ButtonActivatedPlatforms: { BasePart }, Buttons: { Button } } = {
		ButtonActivatedPlatforms = {},
		Buttons = {},
	}
	shared.button_cache = cacheReference

	-- Button functions --

	local function hasTimer(currentButton: Button) return (utility.checkConfig(currentButton.Configuration, "Timer") or 0) > 0 end
	local function getTransparency(platform: Instance, isActivated: boolean)
		local enabledTransparency = utility.checkConfig(platform, "SetTransparency") or 0
		local disabledTransparency = if utility.hasTag(platform, "FullHide") then 1 else 0.6
		return if isActivated then enabledTransparency else disabledTransparency
	end

	local function activatePlatform(platform: BasePart, isPressed: boolean, targetButton: Button?)
		local isActivated = isPressed
		if utility.hasTag(platform, "Invert") then isActivated = not isActivated end

		local currentColor = utility.roundColor(utility.getConfig(platform, "ColorOverride", platform.Color))
		if targetButton and currentColor ~= targetButton.Color then return end
		platform:SetAttribute("Activated", isActivated)

		for _, descendant: Instance in platform:GetDescendants() do --rip "asfd", you may or may not be missed
			if descendant.Name == "Activated" and descendant:IsA("BoolValue") then descendant.Value = isActivated end
			if utility.hasTag(descendant, "IgnoreAll") then continue end
			for objectType, property in TWEEN_TRANSPARENCY_PROPERTIES do
				if descendant:IsA(objectType) then
					utility.tween(descendant, 0.3, { [property] = getTransparency(descendant, isActivated) })
				end
			end

			for _, objectType: string in SET_PROPERTIES_ENABLED do
				if descendant:IsA(objectType) then (descendant :: any).Enabled = isActivated end
			end
		end

		local ignoreAll = utility.hasTag(platform, "IgnoreAll")
		if not (utility.hasTag(platform, "IgnoreCanCollide") or ignoreAll) then platform.CanCollide = isActivated end
		if not (utility.hasTag(platform, "IgnoreTransparency") or utility.hasTag(platform, "Invisible") or ignoreAll) then
			utility.tween(platform, 0.3, { Transparency = getTransparency(platform, isActivated) })
		end
	end

	-- Cache all Platforms --

	for _, platform: Instance in clientObjects:GetDescendants() do -- add any platforms existing before this script runs
		if platform:IsA("BasePart") and utility.isButtonActivatedPlatform(platform) then
			table.insert(cacheReference.ButtonActivatedPlatforms, platform)
			if not utility.hasTag(platform, "IgnoreInitialActivate") then task.spawn(activatePlatform, platform, false) end
		end
	end

	trove:Connect(clientObjects.DescendantAdded, function(descendant: Instance)
		if descendant:IsA("BasePart") and utility.isButtonActivatedPlatform(descendant) then
			table.insert(cacheReference.ButtonActivatedPlatforms, descendant)
			if not utility.hasTag(descendant, "IgnoreInitialActivate") then task.spawn(activatePlatform, descendant, false) end
		end
	end)

	trove:Connect(clientObjects.DescendantRemoving, function(descendant: Instance)
		if not descendant:IsA("BasePart") then return end
		local index = table.find(cacheReference.ButtonActivatedPlatforms, descendant)
		if index ~= nil then table.remove(cacheReference.ButtonActivatedPlatforms, index) end
	end)

	-- Handle Button Activating --

	trove:Connect(communicators.event, function(type: string, ...)
		if type == "update-button-platforms" then
			local targetButton: Button, isPressed: boolean = ...
			if typeof(isPressed) ~= "boolean" then return end
			if not (typeof(targetButton) == "table" and typeof(targetButton.ID) == "string") then return end

			local doNotContinue: boolean = false
			local valuesToChange: { BoolValue } = {}

			local targetButtonHasTimer = hasTimer(targetButton)
			for _, currentButton: Button in cacheReference.Buttons do -- Check for buttons with the same color
				if currentButton.ID == targetButton.ID or currentButton.Color ~= targetButton.Color then continue end -- Same button or button with a different color

				local timerInvolved = targetButtonHasTimer or hasTimer(currentButton)
				local pressed = currentButton.Pressed
				if (timerInvolved and pressed.Value == true) or ((not timerInvolved) and pressed.Value == isPressed) then
					doNotContinue = true
				elseif not timerInvolved then
					table.insert(valuesToChange, pressed)
				end
			end

			if doNotContinue == true then return end
			for _, pressed in valuesToChange do
				pressed.Value = isPressed
			end

			local partsActivated = 0
			for _, platform in cacheReference.ButtonActivatedPlatforms do
				activatePlatform(platform, isPressed, targetButton)
				partsActivated += 1
				if (partsActivated % PART_BUFFER) == 0 then task.wait() end
			end
		end
	end)

	-- Initialize Sequencer Function --
	sequencerManager(scope)
end
