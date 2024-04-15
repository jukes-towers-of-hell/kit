--!strict

-->insert-repository-warning<--

export type Key = {
	instance: Model?,
	originalCFrame: CFrame,
	hitbox: BasePart,
	timerBillboard: typeof(script.Parent.KeyTimer),
	config: {
		spinSpeed: number,
		timer: number,
	},
}
export type KeyDoor = {
	instance: Model,
	hitbox: BasePart,
	doorParts: { [BasePart]: string },
	requiredKeys: number,
}

export type cached_Key = Key & {
	ID: string,
	groupID: string,
	overrideCFrame: CFrame?,
	targetCFrame: CFrame?,
	parent: Instance,
	active: boolean,
	cooldown: boolean,
	used: boolean,
	startTimer: number?,
	collect: () -> (),
	returnKey: () -> (),
	viewport: typeof(script.KeyViewport),
}
export type cached_KeyDoor = KeyDoor & {
	ID: string,
	groupID: string,
	unlocked: boolean,
	usedKeys: { string },
	unlock: () -> (),
	useKey: (keyID: string) -> (),
}

export type KeyGroup = {
	ID: string,
	keys: { [string]: cached_Key },
	doors: { [string]: cached_KeyDoor },

	addKey: (Key) -> cached_Key?,
	addDoor: (KeyDoor) -> cached_KeyDoor,
}

export type Cache = {
	groups: { [string]: KeyGroup },
	keys: { [string]: cached_Key },
	doors: { [string]: cached_KeyDoor },
	activeKeys: { string },
	newGroup: () -> KeyGroup,
	ID: string,
}

local TRAIL_UPDATE_THRESHOLD = 0.75
local TRAIL_LOG_LIMIT = 1500
local TRAIL_DISTANCE = 6
local LERP_SPEED = 15
local MAX_PIVOT_DISTANCE = 150

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local players: Players = game:GetService("Players")

local localPlayer = players.LocalPlayer :: _T.Player

local handler = {}
handler.DOOR_DESTROY_METHODS = {
	Vanish = function(part: BasePart, scope: _T.Variables)
		part.CanCollide = false
		part.CanTouch = false
		--this looks kinda silly but its better than using wait
		scope.utility.tween(part, 0.5, { Transparency = 1 }).Completed:Once(function() part:Destroy() end)
	end,

	Fall = function(part: BasePart, scope: _T.Variables)
		local random = Random.new()
		local powerRange = scope.utility.getConfig(part, "FallPower", NumberRange.new(-10, 10))
		local function rng(multiplier: number) return random:NextInteger(powerRange.Min * multiplier, powerRange.Max * multiplier) end

		part.Anchored = false
		part.CanCollide = false
		part.AssemblyAngularVelocity = Vector3.new(rng(1), rng(1), rng(1))
		part.AssemblyLinearVelocity = Vector3.new(rng(3), rng(3), rng(3));
		(part :: any):BreakJoints()
	end,

	Destroy = function(part: BasePart) part:Destroy() end,
}

function handler.handle(scope: _T.Variables): Cache
	local shared, trove, utility, communicators = scope.shared, scope.trove, scope.utility, scope.communicators
	if shared.key_system ~= nil then return shared.key_system end

	local EffectGuiManager = require(utility.WaitForDescendant(localPlayer:WaitForChild("PlayerScripts"), "EffectGuiManager")) :: {
		BindKeySystem: (Cache) -> (),
		UnbindKeySystem: (string) -> (),
	}

	local reference = {
		groups = {},
		keys = {},
		doors = {},
		activeKeys = {},
		ID = utility.generateUID(false, true),
	}

	local function playSoundFromHitbox(hitbox: Instance, sound: Sound)
		local replaceSound: Instance? = hitbox:FindFirstChild("ReplaceSound")
		if replaceSound and replaceSound:IsA("Sound") then return utility.playSoundFromPart(replaceSound, hitbox) end
		utility.playSoundFromPart(sound, hitbox)
	end

	function reference.newGroup()
		local groupID = utility.generateUID(false, true)
		local groupReference = { ID = groupID, keys = {}, doors = {} }

		function groupReference.addKey(key: Key)
			local thisID = utility.generateUID(false, true)
			local newKey = key :: cached_Key
			if not newKey.instance then return end

			newKey.ID = thisID
			newKey.groupID = groupID
			newKey.active = false
			newKey.cooldown = false
			newKey.used = false
			newKey.parent = newKey.instance.Parent :: Instance
			newKey.viewport = script.KeyViewport:Clone()
			newKey.viewport.Time.Text = ""
			trove:Add(newKey.instance)
			trove:Add(newKey.viewport)

			for _, part in newKey.instance:GetDescendants() do
				if not part:IsA("BasePart") then continue end
				if utility.hasTag(part, "Ignore") then continue end
				part.CanCollide = false
			end

			function newKey.collect()
				if newKey.active or newKey.cooldown or newKey.used then return end
				if not newKey.instance then return end

				newKey.active = true
				table.insert(reference.activeKeys, thisID)
				if newKey.config.timer > 0 then newKey.startTimer = os.clock() end
				communicators.event:Fire(thisID, "collected")
				key.timerBillboard.Enabled = true

				local hitboxClone = newKey.hitbox:Clone()
				hitboxClone:ClearAllChildren()
				hitboxClone.Parent = workspace

				local particleEffect: ParticleEmitter = (newKey.hitbox:FindFirstChild("ReplaceEffect") or script.Effect):Clone()
				particleEffect.Rate = 0

				local emitRate = utility.getConfig(particleEffect, "EmitRange", NumberRange.new(20, 50))
				particleEffect.Parent = hitboxClone
				particleEffect:Emit(Random.new():NextInteger(emitRate.Min, emitRate.Max))
				playSoundFromHitbox(newKey.hitbox, script.PickupSound)
				Debris:AddItem(hitboxClone, particleEffect.Lifetime.Max)
			end

			function newKey.returnKey()
				if (not newKey.active) or newKey.cooldown then return end
				if not newKey.instance then return end

				local keyIndex = table.find(reference.activeKeys, thisID)
				if not keyIndex then return end

				table.remove(reference.activeKeys, keyIndex)
				newKey.startTimer = nil
				newKey.active = false
				newKey.cooldown = true
				if not newKey.used then communicators.event:Fire(thisID, "returned") end
				task.delay(1, function() newKey.cooldown = false end)
				newKey.timerBillboard.Enabled = false
			end

			groupReference.keys[thisID] = newKey
			reference.keys[thisID] = newKey

			return newKey
		end

		function groupReference.addDoor(door: KeyDoor)
			local thisID = utility.generateUID(false, true)
			local newDoor = door :: cached_KeyDoor
			newDoor.ID = thisID
			newDoor.groupID = groupID
			newDoor.usedKeys = {}
			newDoor.unlocked = false

			function newDoor.unlock()
				if newDoor.unlocked then return end
				if #newDoor.usedKeys < newDoor.requiredKeys then return end
				newDoor.unlocked = true
				newDoor.hitbox.CanTouch = false

				communicators.event:Fire(thisID, "unlocked")
				playSoundFromHitbox(door.hitbox, script.UnlockSound)

				for part, destroyType in newDoor.doorParts do
					local destroyFunction = handler.DOOR_DESTROY_METHODS[destroyType]
					if not destroyFunction then continue end
					task.spawn(destroyFunction, part, scope)
				end
			end

			function newDoor.useKey(keyID: string)
				if newDoor.unlocked then return end
				local key: cached_Key? = groupReference.keys[keyID]
				if not key then return end
				if (not key.active) or key.used then return end

				key.hitbox.CanTouch = false
				key.used = true
				key.returnKey()
				key.config.spinSpeed = 0
				key.targetCFrame = door.hitbox:GetPivot()
				table.insert(newDoor.usedKeys, keyID)

				task.delay(0.4, function()
					if not key.instance then return end
					key.instance:Destroy()
					key.instance = nil
				end)

				communicators.event:Fire(keyID, "used")
				communicators.event:Fire(thisID, "key-used", keyID)
				if #newDoor.usedKeys >= newDoor.requiredKeys then newDoor.unlock() end
			end

			groupReference.doors[thisID] = newDoor
			reference.doors[thisID] = newDoor

			return newDoor
		end

		reference.groups[groupID] = groupReference
		return groupReference
	end

	shared.key_system = reference

	-- Main function --
	local trailList: { Vector3 } = {}
	local lastTrailUpdatePosition: Vector3 = nil
	local lastTrailUpdateTime = 0
	trove:Connect(RunService.Heartbeat, function(deltaTime: number)
		local character: Model? = localPlayer.Character
		if not character then return end
		local humanoid: Humanoid? = character:FindFirstChildWhichIsA("Humanoid")
		if not humanoid then return end
		local rootPart: BasePart? = humanoid.RootPart
		if not rootPart then return end

		local currentClock = os.clock()

		-- Trail logging
		debug.profilebegin("Key Trail Logging")
		local currentPosition = rootPart.Position
		if
			(#reference.activeKeys <= 0 and (currentClock - lastTrailUpdateTime) > TRAIL_UPDATE_THRESHOLD) -- if there's no active keys, update at a certain interval instead of checking distance
			or ((not lastTrailUpdatePosition) or (currentPosition - lastTrailUpdatePosition).Magnitude > TRAIL_UPDATE_THRESHOLD)
		then
			table.insert(trailList, 1, currentPosition)
			if #trailList > TRAIL_LOG_LIMIT then table.remove(trailList, #trailList) end
			lastTrailUpdateTime = currentClock
			lastTrailUpdatePosition = currentPosition
		end
		debug.profileend()
		--

		-- Trail Positioning --
		debug.profilebegin("Handle Key Positioning & Timers")

		local cameraPosition = workspace.CurrentCamera.CFrame.Position
		local speedDelta = (deltaTime * LERP_SPEED)
		for keyID, key in reference.keys do
			if not key.instance then continue end

			local keyIndex = table.find(reference.activeKeys, keyID)
			if (keyIndex ~= nil and key.active) and typeof(key.startTimer) == "number" then
				debug.profilebegin("Handle Key Timer")
				local elapsedTime = (currentClock - key.startTimer)
				local timer = key.config.timer
				if elapsedTime >= timer then
					key.returnKey()
				else
					local timerLabel = key.timerBillboard:FindFirstChildWhichIsA("TextLabel")
					if timerLabel then timerLabel.Text = math.abs(math.ceil(timer - elapsedTime)) end
				end
				debug.profileend()
			end

			debug.profilebegin("Position Key")
			local rotation = math.rad((currentClock * (60 * key.config.spinSpeed)) % 360)
			local targetPosition: Vector3 | CFrame = key.originalCFrame.Position
			if key.overrideCFrame then
				debug.profileend()
				continue
			elseif key.targetCFrame then
				targetPosition = key.targetCFrame
			elseif keyIndex ~= nil then
				targetPosition = trailList[math.floor(TRAIL_DISTANCE * keyIndex)]
					or trailList[#trailList]
					or currentPosition
					or Vector3.zero
			end

			if
				((not key.active) and not key.cooldown and not key.used)
				and (targetPosition - cameraPosition).Magnitude > MAX_PIVOT_DISTANCE
			then
				debug.profileend()
				continue
			end

			local finalPosition: CFrame
			if typeof(targetPosition) == "Vector3" then
				finalPosition = CFrame.new(key.instance:GetPivot().Position:Lerp(targetPosition, speedDelta))
			elseif typeof(targetPosition) == "CFrame" then
				finalPosition = key.instance:GetPivot():Lerp(targetPosition, speedDelta)
			end

			key.instance:PivotTo(finalPosition * CFrame.Angles(0, rotation, 0))
			debug.profileend()
		end

		debug.profileend()
	end)

	EffectGuiManager.BindKeySystem(reference)
	trove:Add(function() EffectGuiManager.UnbindKeySystem(reference.ID) end)
	return reference
end

return handler
