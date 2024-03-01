--!strict

-->insert-corescript-warning<--

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

-- @synnwave
export type requestFunction = (...any) -> ...any
export type RequestFunctions = {
	Invoke: (self: RequestFunctions, type: string, ...any) -> ...any,
	Add: (self: RequestFunctions, requestName: string, fn: requestFunction) -> (() -> ())?,
	Destroy: (self: RequestFunctions) -> (),

	_requestFunctions: { [string]: requestFunction },
}

return nil
