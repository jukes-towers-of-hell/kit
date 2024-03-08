--!strict

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: _T.Player
local Managers = localPlayer.PlayerScripts.Client.Managers
local EffectGuiManager = require(Managers:FindFirstChild("CharacterManager")) :: EffectGuiManager
type EffectGuiManager = {
	KeyDisplayLimit: number,
	Init: (self: EffectGuiManager) -> (),
}

return function(scope: _T.Variables) end
