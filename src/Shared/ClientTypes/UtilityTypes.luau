--!strict
export type Utility = {
	-- Checks --
	isBalloon: (parent: Instance, doNotCheckAncestor: boolean?) -> boolean,
	isTurret: (parent: Instance, doNotCheckAncestor: boolean?) -> boolean,
	isPushbox: (parent: Instance, doNotCheckAncestor: boolean?) -> boolean,
	isButtonActivatedPlatform: (platform: Instance) -> boolean,
	isSequence: (parent: Instance) -> boolean,
	checkConfig: (instance: Instance, configName: string) -> any,
	getConfigChangedSignal: (instance: Instance, configName: string) -> RBXScriptSignal?,
	hasTag: (instance: Instance, tag: string) -> boolean,
	evaluateToucher: (part: BasePart, toucher: BasePart, config: Instance?) -> boolean,

	-- Color Utility --
	roundColor: (color: Color3) -> Color3,
	subtractHSV: (color: Color3, subtract: number?) -> Color3,

	-- Safe Utility --
	getInstanceProperty: (instance: any, property: string) -> (any, boolean),
	setInstanceProperty: (instance: any, property: string, value: any) -> boolean,
	assureValueType: <defaultType>(value: unknown, default: defaultType) -> defaultType,
	getConfig: <defaultType>(instance: Instance, configName: string, default: defaultType) -> defaultType,

	-- Unsorted --
	applyPartOptimizations: (part: Instance?) -> (),
	getEnumFromString: (str: string | EnumItem, default: EnumItem) -> any,
	generateUID: (curlyBraces: boolean?, removeSplit: boolean?) -> string,
	playSoundFromPart: (sound: string | Sound, parent: Instance?, searchFrom: Instance?) -> (),
	onFlipped: (part: BasePart, callback: () -> ()) -> () -> (),
	tween: (
		instance: Instance,
		time: number,
		goal: { [string]: any },
		easingStyle: Enum.EasingStyle?,
		easingDirection: Enum.EasingDirection?,
		...any
	) -> Tween,
}

return nil
