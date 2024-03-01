--!strict
-- BindableFunction replacement that recieves/returns variables as references and not copies
-- by @synnwave

-->insert-corescript-warning<--

local replicatedStorage = game:GetService("ReplicatedStorage")
local _T = require(replicatedStorage.ClientTypes)

local YIELD_TIMEOUT = 5
local YIELD_RATE = 0.25

local RequestFunctions = {}

function RequestFunctions.new(): _T.RequestFunctions
	local destroyed = false
	local bindable: _T.RequestFunctions = {
		_requestFunctions = {} :: { [string]: _T.requestFunction },

		Add = function(self, requestName: string, fn: _T.requestFunction): (() -> ())?
			if destroyed then return end
			if typeof(fn) ~= "function" then return end
			if self._requestFunctions[requestName] ~= nil then
				warn(`request function "{requestName}" already exists`)
				return
			end

			self._requestFunctions[requestName] = fn

			local destroyedThis = false
			return function()
				if destroyedThis then return end
				destroyedThis = true
				self._requestFunctions[requestName] = nil
			end
		end,

		Invoke = function(self, requestName: string, ...): ...any
			if destroyed then return end
			local requestedFunction: _T.requestFunction? = self._requestFunctions[requestName]
			if typeof(requestedFunction) ~= "function" then -- if the request function doesn't exist: wait until the time exceeds the yield timeout
				local startTime = os.clock()
				while typeof(requestedFunction) ~= "function" and (os.clock() - startTime) < YIELD_TIMEOUT do
					task.wait(YIELD_RATE)
					requestedFunction = self._requestFunctions[requestName]
				end
			end

			if typeof(requestedFunction) ~= "function" then -- check again after the yield
				warn(`request function "{type}" doesn't exist (yield exceeded {YIELD_TIMEOUT}s)`) -- still doesn't exist :/
				return
			end

			return requestedFunction(...)
		end,

		Destroy = function(self)
			if destroyed then return end
			destroyed = true
			for requestName: string in self._requestFunctions do
				self._requestFunctions[requestName] = nil
			end
		end,
	}

	return table.freeze(bindable)
end

return table.freeze(RequestFunctions)
