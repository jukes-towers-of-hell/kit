--!strict
-- FlipManager by Jukereise & @synnwave

-->insert-corescript-warning<--

local userInputService: UserInputService = game:GetService("UserInputService")
local debris: Debris = game:GetService("Debris")
local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local VALID_KEYCODES = { Enum.KeyCode.F, Enum.KeyCode.ButtonX }

local manager = {
	hasInitialized = false,
	callbacks = {} :: { [BasePart]: { [string]: () -> () } },
}

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local Utility: _T.Utility = require(script.Parent.UtilityManager)

function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

	local function activateFlip()
		local character: Model? = localPlayer.Character
		if not character then return end

		local torso: Instance? = character:FindFirstChild("Torso")
		if not (torso and torso:IsA("BasePart")) then return end

		for _, touchingPart: BasePart in workspace:GetPartsInPart(torso) do -- supports CCF parts!
			if not (Utility.hasTag(touchingPart, "CanFlip") or Utility.getConfig(touchingPart, "SupportFlips", false)) then
				continue
			end

			if not Utility.getConfig(touchingPart, "Activated", true) then return end

			local offsetFromPart: CFrame = touchingPart.CFrame:ToObjectSpace(torso.CFrame)
			local teleportPart: BasePart = touchingPart
			local teleportToObject: Instance? = touchingPart:FindFirstChild("TeleToObject")
			if
				teleportToObject
				and teleportToObject:IsA("ObjectValue")
				and (teleportToObject.Value and teleportToObject.Value:IsA("BasePart"))
			then
				teleportPart = teleportToObject.Value
			end

			if not Utility.hasTag(touchingPart, "DoNotFlipPlayer") then
				torso.CFrame = (teleportPart.CFrame * CFrame.Angles(0, math.pi, 0)) * offsetFromPart
			end

			local callbacks = manager.callbacks[touchingPart]
			if callbacks then
				for _, callback in callbacks do
					if typeof(callback) ~= "function" then continue end
					task.spawn(callback)
				end
			end

			local sound: Sound = (touchingPart:FindFirstChild("FlipSound") or script.DoNotChange):Clone()
			sound.Parent = teleportPart
			sound:Play()
			debris:AddItem(sound, 0.8)

			break
		end
	end

	userInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		if not table.find(VALID_KEYCODES, inputObject.KeyCode) then return end
		activateFlip()
	end)

	userInputService.TouchTapInWorld:Connect(function(_: Vector2, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		activateFlip()
	end)
end

return manager
