--!strict

-->insert-repository-warning<--

local runService: RunService = game:GetService("RunService")
local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local DEFAULT_SPEED = 40
local function setSpeed(conveyor: BasePart, beam: Beam?, speed: number)
	--local speed = conveyor:GetAttribute("ConveyorSpeed")
	local currentSpeed: number = if typeof(speed) == "number" then speed else DEFAULT_SPEED
	conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * currentSpeed
	if beam then beam.TextureSpeed = currentSpeed / beam.TextureLength end
end

return function(scope: _T.Variables)
	local parent, trove, shared, utility = scope.parent, scope.trove, scope.shared, scope.utility
	if not (parent and parent:IsA("BasePart")) then return end

	if shared.conveyor_cache == nil then -- cache doesn't exist, this script will handle all unanchored parts from now on to keep things optimized!
		-- this script looks bloated because of this loop :(
		local cacheReference: { [any]: { conveyor: BasePart, beam: Beam?, speed: number? } } = {}
		shared.conveyor_cache = cacheReference
		trove:Connect(runService.Heartbeat, function()
			debug.profilebegin("Set Unanchored Conveyor Velocities")
			for id: any, data in cacheReference do
				if (not data.conveyor:IsDescendantOf(workspace)) or data.conveyor.Anchored then
					cacheReference[id] = nil
					continue
				end

				setSpeed(data.conveyor, data.beam, data.speed or DEFAULT_SPEED)
			end
			debug.profileend()
		end)
	end

	local beam: Beam? = parent:FindFirstChildWhichIsA("Beam", true)
	local conveyorId = utility.generateUID(false, true)
	local function checkIfAnchored()
		local currentConfiguration =
			{ conveyor = parent, beam = beam, speed = utility.getConfig(parent, "ConveyorSpeed", DEFAULT_SPEED) }

		shared.conveyor_cache[conveyorId] = if parent.Anchored then nil else currentConfiguration
		parent.AssemblyAngularVelocity = Vector3.zero
		setSpeed(parent, beam, currentConfiguration.speed)
	end

	-- all of the connections below are for pushboxes & property changers support.
	checkIfAnchored()
	local currentTrove = trove:Extend() -- create a sub-trove
	currentTrove:AttachToInstance(parent) -- bind the part to the trove so when the part gets destroyed, connections will get destroyed along with it
	currentTrove:Connect(utility.getConfigChangedSignal(parent, "ConveyorSpeed"), checkIfAnchored)
	currentTrove:Connect(parent:GetPropertyChangedSignal("Anchored"), checkIfAnchored)
	currentTrove:Add(function() shared.conveyor_cache[conveyorId] = nil end) -- this code will run once the trove is cleaning up, removing itself from the cache
	currentTrove:Add(function() trove:Remove(currentTrove) end)
end
