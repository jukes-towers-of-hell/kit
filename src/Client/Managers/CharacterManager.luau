--!strict
--# selene: allow(if_same_then_else)

-- CharacterManager by @synnwave

local players: Players = game:GetService("Players")
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = players.LocalPlayer :: Player

local manager = {}

local VALID_HEALTHBRICKS: { [string]: string | number } = { -- NOTE: Maybe change this to numbers instead of their string names?
	kills = "Normal",
	double = "DoubleDamage",
	ouch = "HighDamage",
	instakills = "Instakill",
	heals = 0,
}

local LOCAL_PLAYER_COLLISIONGROUP = "Player"
local OTHER_PLAYER_COLLISIONGROUP = "OtherPlayers"

function manager:Init()
	local damageEvent = replicatedStorage:WaitForChild("DamageEvent") :: RemoteEvent

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
			local humanoid = character:WaitForChild("Humanoid") :: Humanoid
			humanoid.Touched:Connect(function(touchingPart: BasePart, hitPart: BasePart)
				if hitPart.Name == "Part" then return end -- is there a reason for this check i don't know actualyl but im gonna keep it here
				if humanoid.Health <= 0 then return end

				local isActivated: any = touchingPart:GetAttribute("Activated")
				local isActive: boolean = if typeof(isActivated) == "boolean" then isActivated else true
				if not isActive then return end

				for identifier, value in VALID_HEALTHBRICKS do
					if touchingPart:FindFirstChild(identifier) then -- old killbricks . . .
						damageEvent:FireServer(value)
						break
					end

					local hasAttribute: any = touchingPart:GetAttribute(identifier)
					if hasAttribute ~= nil then
						damageEvent:FireServer(if typeof(hasAttribute) == "number" then hasAttribute else value)
						-- if the attribute is a number then give the server that number instead of the normal value
						-- allows for custom killbrick values !!
						break
					end
				end
			end)
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
