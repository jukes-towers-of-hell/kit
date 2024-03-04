--!strict

-->insert-corescript-warning<--

local PlayerTypes = require(script.PlayerTypes)
local PackageTypes = require(script.PackageTypes)
local UtilityTypes = require(script.UtilityTypes)

export type Character = PlayerTypes.Character
export type Player = PlayerTypes.PlayerType

export type Trove = PackageTypes.Trove
export type Utility = UtilityTypes.Utility & { tableUtil: PackageTypes.TableUtil }

export type Signal = PackageTypes.Signal
export type RequestFunctions = PackageTypes.RequestFunctions
export type requestFunction = PackageTypes.requestFunction

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
	scriptPath: string?,
	log: (
		self: Variables,
		str: string,
		useTraceback: boolean?,
		logType: ("success" | "error" | "warn" | "info" | true | false | number)?,
		printType: ("print" | "warn" | "error" | number)?
	) -> (),
}

export type LightingConfiguration = {
	Type: string,
	Configuration: "Default" | { [string]: any } | Instance,
	TweenInfo: TweenInfo?,
}

return nil
