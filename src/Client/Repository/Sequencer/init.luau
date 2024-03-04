--!strict
-- Sequencer, by @synnwave

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
local runService: RunService = game:GetService("RunService")

local Activators = require(script.Activators)
type sequencerData = Activators.sequencerData

local STOPPED_COLOR = ColorSequence.new(Color3.fromRGB(255, 100, 100))
local PAUSED_COLOR = ColorSequence.new(Color3.fromRGB(255, 255, 100))
local PLAYING_COLOR = ColorSequence.new(Color3.fromRGB(45, 150, 255))

local LAG_THRESHOLD = 1 / 10 -- Sequencers will not run below 10 FPS

local function distanceBetween(pointA: CFrame, pointB: CFrame): number
	return pointA:ToObjectSpace(CFrame.new(pointB.Position)).Position.Z
end

return function(scope: _T.Variables)
	scope:log("hello")

	local sequencer, trove, shared, utility = scope.parent, scope.trove, scope.shared, scope.utility
	if not (sequencer and sequencer:IsA("Model")) then return end
	if utility.isBalloon(sequencer) or utility.isPushbox(sequencer) or utility.isTurret(sequencer) then return end

	local sequencerBase: Instance? = sequencer:FindFirstChild("Base")
	local configuration: Instance? = sequencer:FindFirstChild("SequencerConfiguration")
	local sequence: Instance? = sequencer:FindFirstChild("Sequence")
	if not ((sequencerBase and sequencerBase:IsA("BasePart")) and configuration and sequence) then return end

	local fetchActivators = Activators(scope)

	local startingPosition: CFrame = sequencerBase:GetPivot()
	local loopAmount = utility.getConfig(configuration, "LoopAmount", 0) + 1
	local loopDelay = utility.getConfig(configuration, "LoopDelay", 0)
	local speed = -math.abs(utility.getConfig(configuration, "Speed", 1))
	local visualize = utility.getConfig(configuration, "Visualize", false)
	utility.applyPartOptimizations(sequencerBase)
	sequencerBase.Transparency = 1

	local beam: Beam
	if visualize then
		local attachment0 = Instance.new("Attachment")
		attachment0.Position = -Vector3.yAxis * (sequencerBase.Size.Y / 2)
		attachment0.Orientation = Vector3.zAxis * 90
		attachment0.Parent = sequencerBase

		local attachment1 = attachment0:Clone()
		attachment1.Position = -attachment1.Position
		attachment1.Parent = sequencerBase

		beam = script:FindFirstChildWhichIsA("Beam"):Clone()
		beam.Attachment0 = attachment0
		beam.Attachment1 = attachment1
		beam.Width0, beam.Width1 = sequencerBase.Size.X, sequencerBase.Size.X
		beam.Color = STOPPED_COLOR
		beam.Parent = sequencerBase
	end

	local function setColor(color: ColorSequence)
		if not visualize then return end
		if not beam then return end
		if beam.Color == color then return end
		beam.Color = color
	end

	-- setup sequence data
	local sequenceData: { sequencerData } = {}
	for _, child: Instance in sequence:GetChildren() do
		if not child:IsA("PVInstance") then continue end -- only allow models & parts
		local currentData: sequencerData = {
			canAwait = utility.hasTag(child, "AwaitSequence"),
			instance = child,
			hasPassed = false,
		}

		table.insert(sequenceData, currentData)
	end

	-- run sequence --
	local runID = 0
	local hasFetchedActivators = false
	local function runSequence()
		if not hasFetchedActivators then -- fetch activators when it's time to actually run the sequence (just to be safe), we'll only do this once tho
			hasFetchedActivators = true
			for index, sequencePart in sequenceData do
				local currentActivators = fetchActivators(sequencePart)
				if #currentActivators <= 0 and sequencePart.instance.Name ~= "EndPoint" then
					sequenceData[index] = nil -- remove from table because this sequence part has no purpose
				else
					sequencePart.activators = currentActivators
				end
			end
		end

		runID += 1
		local savedRun = runID
		local isPaused = false
		local totalDelta = 0
		local currentSequenceData = utility.tableUtil.Copy(sequenceData, true)

		local currentTrove = trove:Extend()
		currentTrove:Add(function()
			runID += 1
			trove:Remove(currentTrove)
			sequencerBase:PivotTo(startingPosition)
			setColor(STOPPED_COLOR)
			currentSequenceData = nil :: any
		end)

		local sequenceCount = #currentSequenceData
		currentTrove:Connect(runService.PostSimulation, function(deltaTime: number)
			if savedRun ~= runID then return currentTrove:Clean() end
			if isPaused then return setColor(PAUSED_COLOR) end
			if deltaTime > LAG_THRESHOLD then return end
			totalDelta += deltaTime
			setColor(PLAYING_COLOR)

			local currentPosition = startingPosition * CFrame.new(0, 0, totalDelta * speed)
			if visualize then sequencerBase:PivotTo(currentPosition) end

			local passed = 0
			for _, sequencePart in currentSequenceData do
				if sequencePart.hasPassed then
					passed += 1
					continue
				end
				if not sequencePart.activators then continue end

				local distanceFromBase = distanceBetween(currentPosition, sequencePart.instance:GetPivot())
				if distanceFromBase >= 0 then
					sequencePart.hasPassed = true
					passed += 1
					if sequencePart.canAwait then isPaused = true end
					for _, activator in sequencePart.activators do
						local success, errorMessage: string? = pcall(activator, scope, sequencePart)
						if (not success) and typeof(errorMessage) == "string" then
							scope:log(`sequencer error: {errorMessage}`, true, "warn")
						end
					end
					if sequencePart.canAwait then isPaused = false end
				end
			end

			if passed >= sequenceCount then currentTrove:Clean() end
		end)

		return runID
	end

	local debounce = false
	local function sequenceWrapper()
		if debounce then return end
		debounce = true
		for _ = 1, loopAmount do
			local currentRunID = runSequence()
			repeat
				task.wait()
			until currentRunID ~= runID
			if loopDelay > 0 then task.wait(loopDelay) end
		end

		debounce = false
	end

	-- add into cache to allow for sequencer activated sequencers --
	shared.sequencer_cache.sequencers[sequencer] = sequenceWrapper

	-- check for toggle parts --
	for _, part: Instance in sequencer:GetDescendants() do
		if part:IsDescendantOf(sequence) then continue end
		if not part:IsA("BasePart") then continue end
		if part.Name ~= "Toggle" then continue end

		trove:Connect(part.Touched, function(toucher: BasePart)
			if not utility.evaluateToucher(part, toucher, configuration) then return end
			local buttonActivated: boolean = utility.checkConfig(part, "Activated")
			if typeof(buttonActivated) == "boolean" and not buttonActivated then return end

			sequenceWrapper()
		end)
	end
end
