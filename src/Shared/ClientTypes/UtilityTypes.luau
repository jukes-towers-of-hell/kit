--!strict

export type Utility = {
	isBalloon: (parent: Instance) -> boolean,
	isTurret: (parent: Instance) -> boolean,
	isPushbox: (parent: Instance) -> boolean,
	isButtonActivatedPlatform: (platform: Instance) -> boolean,
	roundColor: (color: Color3) -> Color3,
	checkConfig: (instance: Instance, configName: string) -> any,
	getEnumFromString: (str: string | EnumItem, default: EnumItem?) -> any,
	subtractHSV: (color: Color3, subtract: number?) -> Color3,
	generateUID: (curlyBraces: boolean?, removeSplit: boolean?) -> string,
	evaluateToucher: (part: BasePart, toucher: BasePart, config: Instance?) -> boolean,
	playSoundFromPart: (sound: string | Sound, parent: Instance?, searchFrom: Instance) -> (),
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
