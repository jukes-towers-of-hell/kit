--!strict
-- CharacterManager by @synnwave

-->insert-corescript-warning<--

local players: Players = game:GetService("Players")
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = players.LocalPlayer :: Player

local manager = { hasInitialized = false }

manager.VALID_DAMAGEBRICKS = { -- NOTE: Maybe change this to numbers instead of their string names?
	kills = "Normal",
	double = "DoubleDamage",
	ouch = "HighDamage",
	instakills = "Instakill",
	heals = "Heals",
} :: { [string]: string | number }

local LOCAL_PLAYER_COLLISIONGROUP = "Player"
local OTHER_PLAYER_COLLISIONGROUP = "OtherPlayers"
local damageEvent = replicatedStorage:WaitForChild("DamageEvent") :: RemoteEvent

function manager:HandleKillBrick(brick: BasePart) -- this is in a seperate function so i can add easy support for the sequencer
	local isActivated: any = brick:GetAttribute("Activated")
	local isActive: boolean = if typeof(isActivated) == "boolean" then isActivated else true
	if not isActive then return end

	for identifier, value in manager.VALID_DAMAGEBRICKS do
		if brick:HasTag(identifier) or brick:FindFirstChild(identifier) then -- can't use Utility.hasTag on this because then the code below won't execute!
			damageEvent:FireServer(value)
			break
		end

		local hasAttribute: any = brick:GetAttribute(identifier)
		if hasAttribute ~= nil then
			damageEvent:FireServer(if typeof(hasAttribute) == "number" then hasAttribute else value)
			-- if the attribute is a number then give the server that number instead of the normal value
			-- allows for custom killbrick values !!
			break
		end
	end
end

function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

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

				manager:HandleKillBrick(touchingPart)
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
