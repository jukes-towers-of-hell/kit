--!strict

local runService: RunService = game:GetService("RunService")
local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local DEFAULT_SPEED = 40

local function setSpeed(parent: BasePart, beam: Beam?)
	local speed = parent:GetAttribute("ConveyorSpeed")
	local currentSpeed: number = if typeof(speed) == "number" then speed else DEFAULT_SPEED
	parent.AssemblyLinearVelocity = parent.CFrame.LookVector * currentSpeed
	if beam then beam.TextureSpeed = currentSpeed / beam.TextureLength end
end

local Conveyor = {}
function Conveyor.new(scope: _T.Variables)
	local parent = scope.parent :: Instance
	if not parent:IsA("BasePart") then return end

	local trove = scope.trove
	local shared = scope.shared
	if shared.conveyorCache == nil then -- cache doesn't exist, this script will handle all unanchored parts from now on to keep things optimized!
		local cacheReference: { [BasePart]: { Beam? } } = {}
		shared.conveyorCache = cacheReference

		trove:Connect(runService.Heartbeat, function()
			for conveyor: BasePart, data in cacheReference do
				if conveyor.Anchored then continue end
				if not conveyor:IsDescendantOf(workspace) then
					cacheReference[conveyor] = nil
					continue
				end

				setSpeed(conveyor, data[1])
			end
		end)
	end

	if (parent.Name == "Pushbox") or (parent:FindFirstAncestor("Pushbox") ~= nil) or (parent:FindFirstChild("IsBox") ~= nil) then -- is it a pushbox?
		trove = trove:Extend() -- create a sub-trove
		trove:AttachToInstance(parent) -- bind the part to the trove so when the part gets destroyed, connections will get destroyed along with it
	end

	local beam: Beam? = parent:FindFirstChildWhichIsA("Beam", true)
	local function checkIfAnchored()
		if parent.Anchored then
			shared.conveyorCache[parent] = nil
		else
			shared.conveyorCache[parent] = { beam }
		end
	end

	checkIfAnchored()
	setSpeed(parent, beam)
	trove:Connect(parent:GetAttributeChangedSignal("ConveyorSpeed"), function() setSpeed(parent, beam) end)
	trove:Connect(parent:GetPropertyChangedSignal("Anchored"), checkIfAnchored)
	trove:Add(function() shared.conveyorCache[parent] = nil end) -- this code will run once the trove is cleaning up, removing itself from the cache
end

return Conveyor
