--!strict
-- FlipManager by @synnwave

local userInputService: UserInputService = game:GetService("UserInputService")
local debris: Debris = game:GetService("Debris")
local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local VALID_KEYCODES = { Enum.KeyCode.F, Enum.KeyCode.ButtonX }

local manager = { hasInitialized = false }

function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

	local function activateFlip()
		local character: Model? = localPlayer.Character
		if not character then return end

		local torso: Instance? = character:FindFirstChild("Torso")
		if not (torso and torso:IsA("BasePart")) then return end

		for _, touchingPart: BasePart in workspace:GetPartsInPart(torso) do -- supports CCF parts!
			if not touchingPart:FindFirstChild("CanFlip") then continue end
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

			torso.CFrame = (teleportPart.CFrame * CFrame.Angles(0, math.pi, 0)) * offsetFromPart

			local sound: Sound = script.DoNotChange:Clone()
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
