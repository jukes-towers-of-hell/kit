--!strict
-- DamageEventManager by @synnwave

-->insert-corescript-warning<--

local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local TYPES: { [string]: number } = {
	Normal = 5,
	DoubleDamage = 10,
	HighDamage = 20,
	Instakill = math.huge, -- scary number
}

local manager = {}

function manager:Init()
	local remote = replicatedStorage:FindFirstChild("DamageEvent") :: RemoteEvent
		or (function()
			local newRemote = Instance.new("RemoteEvent")
			newRemote.Name = "DamageEvent"
			newRemote.Parent = replicatedStorage
			return newRemote
		end)()

	local debounceArray: { boolean } = {}
	remote.OnServerEvent:Connect(function(player: Player, type: string | number)
		if debounceArray[player.UserId] then return end

		local character: Model? = player.Character
		if not character then return end

		local Humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then return end

		local damageValue: number = if typeof(type) == "number" then type else (TYPES[type] or TYPES.Normal) -- type Types TYPES TYPE TYPE TYPE OH MYIM GOING INSANE
		if type == "Heals" then damageValue = -(Humanoid.MaxHealth - Humanoid.Health) end

		if damageValue > 0 then -- no debounce for healing
			debounceArray[player.UserId] = true
			task.delay(0.1, function() debounceArray[player.UserId] = nil end)
		end

		Humanoid:TakeDamage(damageValue)
	end)
end

return manager
