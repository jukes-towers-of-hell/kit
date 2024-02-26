--!strict
local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player

local playerScripts = localPlayer:WaitForChild("PlayerScripts") :: PlayerScripts
local Managers = playerScripts:WaitForChild("Client"):WaitForChild("Managers")
local CharacterManager = require(Managers:FindFirstChild("CharacterManager")) :: CharacterManager
type CharacterManager = {
	VALID_DAMAGEBRICKS: { [string]: string | number },
	HandleKillBrick: (self: CharacterManager, brick: BasePart) -> (),
	Init: (self: CharacterManager) -> (),
}

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
return { -- Killbricks
	priority = nil,
	check = function(scope: _T.Variables, sequenceData: _T.sequencerData)
		if not sequenceData.instance:IsA("BasePart") then return false end
		local hasTag = false
		for tag: string in CharacterManager.VALID_DAMAGEBRICKS do
			hasTag = scope.utility.hasTag(sequenceData.instance, tag)
			if hasTag then break end
		end

		if hasTag then scope.utility.applyPartOptimizations(sequenceData.instance) end
		return hasTag
	end,
	activate = function(_: _T.Variables, sequenceData: _T.sequencerData)
		if not sequenceData.instance:IsA("BasePart") then return end
		CharacterManager:HandleKillBrick(sequenceData.instance)
	end,
}
