--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Conveyor = {}
function Conveyor.new(scope: _T.Variables)
	local parent = scope.parent :: Instance
	if not parent:IsA("BasePart") then return end

	local trove = scope.trove
	local shared = scope.shared
	local isPushbox: boolean = (parent.Name == "Pushbox")
		or (parent:FindFirstAncestor("Pushbox") ~= nil)
		or (parent:FindFirstChild("IsBox") ~= nil)
end

return Conveyor
