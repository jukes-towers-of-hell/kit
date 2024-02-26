--!strict

local TableUtilTypes = require(script.TableUtilTypes)

export type Utility = {
	-- Checks --
	isBalloon: (parent: Instance) -> boolean,
	isTurret: (parent: Instance) -> boolean,
	isPushbox: (parent: Instance) -> boolean,
	isButtonActivatedPlatform: (platform: Instance) -> boolean,
	isSequence: (parent: Instance) -> boolean,
	checkConfig: (instance: Instance, configName: string) -> any,
	hasTag: (instance: Instance, tag: string) -> boolean,
	evaluateToucher: (part: BasePart, toucher: BasePart, config: Instance?) -> boolean,

	-- Color Utility --
	roundColor: (color: Color3) -> Color3,
	subtractHSV: (color: Color3, subtract: number?) -> Color3,

	-- Safe Utility --
	getInstanceProperty: (instance: any, property: string) -> any,
	setInstanceProperty: (instance: any, property: string, value: any) -> any,
	assureValueType: <defaultType>(value: unknown, default: defaultType) -> defaultType,

	-- Unsorted --
	applyPartOptimizations: (part: Instance?) -> (),
	getEnumFromString: (str: string | EnumItem, default: EnumItem) -> any,
	generateUID: (curlyBraces: boolean?, removeSplit: boolean?) -> string,
	playSoundFromPart: (sound: string | Sound, parent: Instance?, searchFrom: Instance) -> (),
	tween: (
		instance: Instance,
		time: number,
		goal: { [string]: any },
		easingStyle: Enum.EasingStyle?,
		easingDirection: Enum.EasingDirection?,
		...any
	) -> Tween,

	-- TableUtil --
	tableUtil: TableUtilTypes.TableUtil,
}

return nil
