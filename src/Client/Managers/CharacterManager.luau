--!strict
--# selene: allow(if_same_then_else)

-- CharacterManager by @synnwave

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local manager = {}

function manager:Init()
	local LOCAL_PLAYER_COLLISIONGROUP = "Player"
	local OTHER_PLAYER_COLLISIONGROUP = "OtherPlayers"

	local damageEvent = game:GetService("ReplicatedStorage"):WaitForChild("DamageEvent") :: RemoteEvent

	local function onPlayerAdded(player: Player)
		local function onCharacterAdded(character: Model)
			if not character then return end

			local isLocalPlayer = player == localPlayer
			local currentCollisionGroup = if isLocalPlayer then LOCAL_PLAYER_COLLISIONGROUP else OTHER_PLAYER_COLLISIONGROUP

			for _, part: Instance in character:GetChildren() do
				if not part:IsA("BasePart") then continue end
				part.CollisionGroup = currentCollisionGroup
			end

			character.ChildAdded:Connect(function(part: Instance)
				if not part:IsA("BasePart") then return end
				part.CollisionGroup = currentCollisionGroup
			end)

			if not isLocalPlayer then return end -- The code below will only run for the local player !

			-- New TouchScript implementation

			local function evaluatePlatform(platform): boolean
				local evaluated = true
				if platform.Parent.Parent.Name == "Beat Blocks" and not platform.CanCollide then evaluated = false end

				local activatedValue = platform:FindFirstChild("Activated")
				if platform.Name == "ButtonActivatedPlatform" and not activatedValue and not platform.CanCollide then -- not sure if some BAPs have the "Activated" value?
					evaluated = false
				elseif platform.Name == "ButtonActivatedPlatform" and not (activatedValue and activatedValue.Value) then
					evaluated = false
				end

				return evaluated
			end

			local humanoid: Instance = character:WaitForChild("Humanoid")
			if humanoid and humanoid:IsA("Humanoid") then
				humanoid.Touched:Connect(function(touchingPart: BasePart, hitPart: BasePart) --TODO: @synnwave GO FINISH IT
				end)
			end
		end

		pcall(onCharacterAdded, player.Character or player.CharacterAdded:Wait())
		player.CharacterAdded:Connect(onCharacterAdded)
	end

	-- Initialize players
	for _, player: Player in players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	players.PlayerAdded:Connect(onPlayerAdded)
end

return manager
