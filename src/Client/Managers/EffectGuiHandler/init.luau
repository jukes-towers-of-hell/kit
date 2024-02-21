--!strict

local Spring = require(script.spr)

local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local manager = { hasInitialized = false }

local USE_SPRINGS = false -- no one likes the springs :(

function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

	local effectGui = playerGui:WaitForChild("EffectGUI") :: ScreenGui

	-- handle new TimerList --
	task.spawn(function()
		local list = effectGui:FindFirstChild("TimerList") :: Frame
		local scaler = list:FindFirstChild("Scaler") :: Frame
		local gridBase = scaler:FindFirstChildWhichIsA("UIGridLayout") :: UIGridLayout

		local Timers: { [number]: { Created: number, Object: GuiObject, Reference: Frame, AttachedTo: Instance? } } = {}
		local function updateTimerList()
			for i, timer in Timers do
				if timer.Object.Name == "__DESTROY__" or (timer.AttachedTo and not timer.AttachedTo:IsDescendantOf(game)) then
					table.remove(Timers, i)
					if USE_SPRINGS then
						Spring.target(timer.Object, 0.7, 3, { Position = timer.Object.Position + UDim2.fromScale(0, -0.25) })
					end

					timer.Reference:Destroy()
					task.delay(if USE_SPRINGS then 1 else 0, function() timer.Object:Destroy() end)
				end
			end

			-- sort timers
			table.sort(Timers, function(a, b) return a.Created > b.Created end)
			for i: number, timer in Timers do -- sort the layout orders
				timer.Reference.LayoutOrder = i
			end

			local scalerAbsolutePosition: Vector2 = scaler.AbsolutePosition
			for _, timer in Timers do
				local timerAbsolutePosition: Vector2 = timer.Reference.AbsolutePosition
				local position = UDim2.fromOffset(timerAbsolutePosition.X, (timerAbsolutePosition.Y - scalerAbsolutePosition.Y))
				if timer.Object.Position ~= position then
					if USE_SPRINGS then
						Spring.target(timer.Object, 0.7, 3, { Position = position })
					else
						timer.Object.Position = position
					end
				end
			end
		end

		local function addTimer(child: Instance)
			if not child:IsA("GuiObject") then return end

			child.Size = gridBase.CellSize
			child.Position = UDim2.new()
			local reference: Frame = Instance.new("Frame")
			reference.Parent = scaler

			local attachedTo = child:FindFirstChildWhichIsA("ObjectValue")
			table.insert(
				Timers,
				{ Created = os.clock(), Object = child, Reference = reference, AttachedTo = (attachedTo and attachedTo.Value) }
			)
			updateTimerList()
		end

		list.ChildAdded:Connect(addTimer)

		-- main loop
		while task.wait(0.1) do
			updateTimerList()
		end
	end)
end

return manager
