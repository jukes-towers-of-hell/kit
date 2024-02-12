--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Buttons = {}

Buttons.LoadOnStart = true
function Buttons.new(variables: _T.Variables)
	print("aaa!")
	print(variables)
end

return Buttons
