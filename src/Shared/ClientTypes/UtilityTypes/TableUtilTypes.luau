--!strict

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
	IsEmpty: (tbl: { any }) -> boolean,
	EncodeJSON: (value: any) -> string,
	DecodeJSON: (str: string) -> any,
}

return nil
