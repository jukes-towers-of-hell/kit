--!strict

-->insert-repository-warning<--

export type Key = {
	instance: Model,
	originalCFrame: CFrame,
	active: boolean,
	cooldown: boolean,
	hitbox: BasePart,
	config: {
		spinSpeed: number,
	},
}
export type KeyDoor = {
	instance: Model,
	hitbox: BasePart,
}

export type cached_Key = Key & { ID: string, groupID: string }
export type cached_KeyDoor = KeyDoor & { ID: string, groupID: string }

export type KeyGroup = {
	ID: string,
	keys: { [string]: cached_Key },
	doors: { [string]: cached_KeyDoor },

	addKey: (Key) -> cached_Key,
	addDoor: (KeyDoor) -> cached_KeyDoor,
}

export type Cache = {
	groups: { [string]: KeyGroup },
	keys: { [string]: cached_Key },
	doors: { [string]: cached_KeyDoor },
	activeKeys: { string },
	newGroup: () -> KeyGroup,
}

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: _T.Player
local Managers = localPlayer.PlayerScripts.Client.Managers
local EffectGuiManager = require(Managers:FindFirstChild("CharacterManager")) :: EffectGuiManager
type EffectGuiManager = {
	KeyDisplayLimit: number,
	Init: (self: EffectGuiManager) -> (),
}

local handler = {}
function handler.handle(scope: _T.Variables): Cache
	local shared, trove, utility = scope.shared, scope.trove, scope.utility
	if shared.key_system ~= nil then return shared.key_system end

	local reference = {
		groups = {},
		keys = {},
		doors = {},
		activeKeys = {},
	}

	function reference.newGroup()
		local groupID = utility.generateUID(false, true)
		local groupReference = { ID = groupID, keys = {}, doors = {} }

		function groupReference.addKey(key: Key)
			local thisID = utility.generateUID(false, true)
			local newKey = key :: cached_Key
			newKey.ID = thisID
			newKey.groupID = groupID

			groupReference.keys[thisID] = newKey
			reference.keys[thisID] = newKey

			return newKey
		end

		function groupReference.addDoor(door: KeyDoor)
			local thisID = utility.generateUID(false, true)
			local newDoor = door :: cached_KeyDoor
			newDoor.ID = thisID
			newDoor.groupID = groupID

			groupReference.doors[thisID] = newDoor
			reference.doors[thisID] = newDoor

			return newDoor
		end

		reference.groups[groupID] = groupReference
		return groupReference
	end

	return reference
end

return handler
