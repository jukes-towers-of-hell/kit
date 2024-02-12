--!strict

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
export type Trove = typeof(require(Packages.Trove))

export type Variables = {
	trove: Trove,
	communicators: {
		event: BindableEvent,
		request: BindableFunction,
	},
	parent: Instance?,
	clientObjects: Instance,
}

export type LightingConfiguration = {
	Type: string,
	Configuration: "Default" | { [string]: any },
	TweenInfo: TweenInfo?,
}

export type requestFunction = <args..., returned...>(args...) -> returned...

return nil
