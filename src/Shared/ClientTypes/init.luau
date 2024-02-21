--!strict

local UtilityTypes = require(script.UtilityTypes)
local SignalTypes = require(script.SignalTypes)
local TroveTypes = require(script.TroveTypes)

export type Trove = TroveTypes.Trove
export type Utility = UtilityTypes.Utility

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
}

export type LightingConfiguration = {
	Type: string,
	Configuration: "Default" | { [string]: any },
	TweenInfo: TweenInfo?,
}

return nil
