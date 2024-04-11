--!strict

-->insert-corescript-warning<--

local RunService = game:GetService("RunService")
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
	-- will handle sorting timers, and will remove timers if the parent doesn't exist
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

	-- Key list --
	task.spawn(function()
		local keyList = effectGui:FindFirstChild("Keys") :: Frame
		local keyCamera = Instance.new("Camera")
		keyCamera.CFrame = CFrame.new(Vector3.zAxis * 4)

		manager.boundKeySystems = {}
		function manager.BindKeySystem(cache)
			if manager.boundKeySystems[cache.ID] then return end
			manager.boundKeySystems[cache.ID] = cache
		end

		function manager.UnbindKeySystem(cache)
			manager.boundKeySystems[cache.ID] = nil
			for _, key in cache.keys do
				key.viewport.Parent = nil
			end
		end

		-- Key Loop
		RunService.Heartbeat:Connect(function()
			for _, cache: any in manager.boundKeySystems do -- Sorry for the lack of type annoations here, im too lazy to add key types in this script...
				for keyID: string, key in cache.keys do
					local viewport = key.viewport
					if viewport.Parent ~= keyList then viewport.Parent = keyList end
					if not viewport.CurrentCamera then viewport.CurrentCamera = keyCamera end

					local keyIndex = table.find(cache.activeKeys, keyID)
					if keyIndex ~= nil and keyIndex >= manager.KeyDisplayLimit then
						viewport.LayoutOrder = keyIndex
						if key.instance.Parent ~= viewport then key.instance.Parent = viewport end
						key.overrideCFrame = CFrame.identity
						if key.startTimer then
							local elapsedTime = (os.clock() - key.startTimer)
							viewport.Time.Text = math.abs(math.ceil(key.config.timer - elapsedTime))
						end

						if not viewport.Visible then viewport.Visible = true end
					else
						if viewport.Visible then viewport.Visible = false end
						if key.instance.Parent ~= key.parent then key.instance.Parent = key.parent end
						key.overrideCFrame = nil
					end
				end
			end
		end)
	end)
end

return manager
