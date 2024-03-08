--!strict

-->insert-corescript-warning<--

local players: Players = game:GetService("Players")
local localPlayer = players.LocalPlayer :: Player
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local manager = {
	hasInitialized = false,
	KeyDisplayLimit = 5,
}

function manager:Init()
	if manager.hasInitialized then return end
	manager.hasInitialized = true

	local effectGui = playerGui:WaitForChild("EffectGUI") :: ScreenGui

	-- handle new TimerList --
	task.spawn(function()
		local list = effectGui:FindFirstChild("TimerList") :: Frame
		local gridBase = list:FindFirstChildWhichIsA("UIGridLayout") :: UIGridLayout

		local Timers: { [number]: { Created: number, Object: GuiObject, AttachedTo: Instance? } } = {}
		local function updateTimerList()
			for i, timer in Timers do
				if not timer.Object.Parent or (timer.AttachedTo and not timer.AttachedTo:IsDescendantOf(game)) then
					table.remove(Timers, i)
					timer.Object:Destroy()
				end
			end

			-- sort timers
			table.sort(Timers, function(a, b) return a.Created > b.Created end)
			for i: number, timer in Timers do -- sort the layout orders
				timer.Object.LayoutOrder = i
			end
		end

		local function addTimer(child: Instance)
			if not child:IsA("GuiObject") then return end

			child.Size = gridBase.CellSize
			local attachedTo = child:FindFirstChildWhichIsA("ObjectValue")
			table.insert(Timers, { Created = os.clock(), Object = child, AttachedTo = (attachedTo and attachedTo.Value) })
			updateTimerList()
		end

		list.ChildAdded:Connect(addTimer)
		list.ChildRemoved:Connect(updateTimerList)
	end)
end

return manager
