--!strict

export type Trove = {
	new: () -> Trove,
	Extend: (self: Trove) -> Trove,
	Clone: <obj>(self: Trove, instance: obj) -> obj,
	Construct: <T...>(self: Trove, class: any, T...) -> any,
	Connect: <T...>(self: Trove, signal: any, fn: (T...) -> ()) -> RBXScriptConnection,
	BindToRenderStep: (self: Trove, priority: number, fn: (dt: number) -> ()) -> (),
	AddPromise: (self: Trove, promise: any) -> any,
	Add: <obj>(self: Trove, object: obj, cleanupMethod: string?) -> obj,
	Remove: (self: Trove, object: any) -> boolean,
	AttachToInstance: (self: Trove, instance: Instance) -> RBXScriptConnection,
	Clean: (self: Trove) -> (),
	Destroy: (self: Trove) -> (),

	-- internal methods --
	_findAndRemoveFromObjects: (self: Trove, cleanup: boolean) -> boolean,
	_cleanupObject: (self: Trove, object: any, cleanupMethod: any) -> (),
}

return nil
