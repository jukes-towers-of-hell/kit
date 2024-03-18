--!strict

-->insert-corescript-warning<--

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

-- https://sleitnick.github.io/RbxUtil/api/Signal/
type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal = {
	Fire: <T...>(self: Signal, T...) -> (),
	FireDeferred: <T...>(self: Signal, T...) -> (),
	Connect: <T...>(self: Signal, fn: (T...) -> ()) -> Connection,
	Once: <T...>(self: Signal, fn: (T...) -> ()) -> Connection,
	DisconnectAll: (self: Signal) -> (),
	GetConnections: (self: Signal) -> { Connection },
	Destroy: (self: Signal) -> (),
	Wait: <T...>(self: Signal) -> T...,
}

-- https://sleitnick.github.io/RbxUtil/api/TableUtil/
export type TableUtil = {
	Copy: <T>(t: T, deep: boolean?) -> T,
	Sync: <S, T>(srcTbl: S, templateTbl: T) -> T,
	Reconcile: <S, T>(src: S, template: T) -> S & T,
	SwapRemove: <T>(t: { T }, i: number) -> (),
	SwapRemoveFirstValue: <T>(t: { T }, v: T) -> number?,
	Map: <T, M>(t: { T }, f: (T, number, { T }) -> M) -> { M },
	Filter: <T>(t: { T }, predicate: (T, any, { T }) -> boolean) -> { T },
	Reduce: <T, R>(t: { T }, predicate: (R, T, any, { T }) -> R, init: R) -> R,
	Assign: <T>(target: { T }, ...{ any }) -> { T } & { any },
	Extend: <T, E>(target: { T }, extension: { E }) -> { E } & { T },
	Reverse: <T>(tbl: { T }) -> { T },
	Shuffle: <T>(tbl: { T }, rngOverride: Random?) -> { T },
	Sample: <T>(tbl: { T }, size: number, rngOverride: Random?) -> { T },
	Flat: <T>(tbl: { T }, depth: number?) -> { T },
	FlatMap: <T, M>(tbl: { T }, callback: (T, number, { T }) -> M) -> { M },
	Keys: <K, V>(tbl: { [K]: V }) -> { K },
	Values: <K, V>(tbl: { [K]: V }) -> { V },
	Find: <K, V>(tbl: { [K]: V }, callback: (V, K, { [K]: V }) -> boolean) -> (V?, K?),
	Every: <K, V>(tbl: { [K]: V }, callback: (V, K, { [K]: V }) -> boolean) -> boolean,
	Some: <K, V>(tbl: { [K]: V }, callback: (V, K, { [K]: V }) -> boolean) -> boolean,
	Truncate: <T>(tbl: { T }, len: number) -> { T },
	Zip: (...{ [any]: any }) -> ((t: { any }, k: any) -> (any, any), { any }, any),
	Lock: <T>(tbl: T) -> T,
	IsEmpty: (tbl: any) -> boolean,
	EncodeJSON: (value: any) -> string,
	DecodeJSON: (str: string) -> any,
}

-- this isn't a package but whatever
export type requestFunction = (...any) -> ...any
export type RequestFunctions = {
	Invoke: (self: RequestFunctions, type: string, ...any) -> ...any,
	Add: (self: RequestFunctions, requestName: string, fn: requestFunction) -> (() -> ())?,
	Destroy: (self: RequestFunctions) -> (),

	_requestFunctions: { [string]: requestFunction },
}

return nil
