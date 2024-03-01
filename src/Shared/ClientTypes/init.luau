--!strict

-->insert-corescript-warning<--

local players = game:GetService("Players")

local UtilityTypes = require(script.UtilityTypes)
local SignalTypes = require(script.SignalTypes) -- I don't know why but i can't do typeof on the Signal module 🥲
local PlayerTypes = require(script.PlayerTypes)

export type Character = PlayerTypes.Character
export type Player = PlayerTypes.PlayerType

local localPlayer: Player = players.LocalPlayer
local Client = localPlayer.PlayerScripts.Client

export type Trove = typeof(Client.Packages.Trove)
export type Utility = UtilityTypes.Utility & { tableUtil: typeof(require(Client.Packages.TableUtil)) }

export type Signal = SignalTypes.Signal
export type RequestFunctions = SignalTypes.RequestFunctions
export type requestFunction = SignalTypes.requestFunction

export type Variables = {
	trove: Trove,
	parent: Instance?,
	clientObjects: Instance,
	shared: { [any]: any },
	communicators: {
		event: Signal,
		request: RequestFunctions,
	},
	utility: Utility,
	repository: { [any]: any },
	debug: boolean,
}

export type LightingConfiguration = {
	Type: string,
	Configuration: "Default" | { [string]: any } | Instance,
	TweenInfo: TweenInfo?,
}

return Client
