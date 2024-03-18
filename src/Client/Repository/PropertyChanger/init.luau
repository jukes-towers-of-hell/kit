--!strict
-- Property Changer, by @synnwave

-->insert-repository-warning<--

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
export type RealValueBase = ValueBase & { Value: any }

local cacheHandler = require(script.CacheHandler)

return function(scope: _T.Variables)
	local changer, trove, utility = scope.parent, scope.trove, scope.utility
	if not (changer and changer:IsA("BasePart")) then return end

	local configuration: Instance? = changer:FindFirstChild("PropertyChangerConfiguration")
	local properties: Instance? = changer:FindFirstChild("Properties")
	if not (configuration and properties) then return end

	-- target objects --
	local tagHandler = cacheHandler.handle(scope)
	local taggedObjects = {}
	local currentTag = utility.getConfig(configuration, "TargetTag", "None")
	if currentTag ~= "None" and currentTag ~= "" then taggedObjects = tagHandler.getTagged(currentTag) end

	for _, target: Instance in configuration:GetChildren() do
		if target.Name ~= "TargetObject" then continue end
		if not (target:IsA("ObjectValue") and target.Value) then continue end
		if not target.Value:IsDescendantOf(scope.clientObjects) then continue end
		table.insert(taggedObjects, target.Value)
	end

	-- tween configurations --
	local canTween: boolean = utility.getConfig(configuration, "CanTween", false)
	local tweenTime: number = utility.getConfig(configuration, "TweenTime", 0.5)
	local easingStyle: Enum.EasingStyle =
		utility.getEnumFromString(utility.checkConfig(configuration, "EasingStyle"), Enum.EasingStyle.Linear)
	local easingDirection: Enum.EasingDirection =
		utility.getEnumFromString(utility.checkConfig(configuration, "EasingDirection"), Enum.EasingDirection.Out)

	-- properties --
	local targetProperties: { { sort: number, property: string, value: any, instance: Instance? } } = {}
	for attributeName: string, value: any in properties:GetAttributes() do
		table.insert(targetProperties, { sort = math.huge, property = attributeName, value = value })
	end

	for _, value: Instance in properties:GetChildren() do
		if not value:IsA("ValueBase") then continue end
		local sort = math.huge
		local propertyName = value.Name
		if propertyName:find("|") then -- sort properties , example: "1 | Size"
			local split = propertyName:split("|")
			sort = tonumber(split[1]) or sort
			propertyName = (split[2]:gsub("%s", ""))
		end

		local currentValue = (value :: RealValueBase).Value
		if value:IsA("ObjectValue") and value.Value == nil then -- automatically default blank objectvalues to the changer part
			currentValue = changer
		end

		table.insert(targetProperties, { sort = sort, property = propertyName, value = currentValue, instance = value :: Instance })
	end

	table.sort(targetProperties, function(a, b) return a.sort < b.sort end)

	-- main function --
	local function changeProperties(instance: Instance)
		for _, propertyData in targetProperties do
			local propertyName = propertyData.property
			local useAttributes = propertyData.instance ~= nil and utility.hasTag(propertyData.instance, "UseAttribute")
			local currentValue, propertyExists
			if useAttributes then
				currentValue = instance:GetAttribute(propertyName)
				propertyExists = currentValue ~= nil
			else
				currentValue, propertyExists = utility.getInstanceProperty(instance, propertyName)
			end

			if not propertyExists then continue end
			local success, errorString

			if typeof(currentValue) == "function" then -- function call
				local presetFunction = cacheHandler.FUNCTION_TYPES[propertyName]
				if presetFunction then
					success, errorString = pcall(presetFunction, scope, instance, propertyData.value)
				else
					success, errorString = pcall(currentValue, instance, propertyData.value)
				end
			else -- normal property
				success, errorString = pcall(function()
					local targetValue = propertyData.value
					for _, valueHandler in cacheHandler.TYPE_HANDLERS do
						targetValue = valueHandler(scope, currentValue, targetValue, propertyName, propertyData.instance)
					end

					if targetValue ~= nil and (typeof(targetValue) ~= typeof(currentValue)) then
						error(`property types don't match (got {typeof(targetValue)}, expected {typeof(currentValue)})`, 0)
					end

					if (canTween and not useAttributes) and table.find(cacheHandler.TWEENABLE_TYPES, typeof(targetValue)) then
						utility.tween(instance, tweenTime, {
							[propertyName] = targetValue,
						}, easingStyle, easingDirection)
					else
						if useAttributes then
							instance:SetAttribute(propertyName, targetValue)
						else
							if not utility.setInstanceProperty(instance, propertyName, targetValue) then
								error(`an error occured while trying to set property {propertyName} to {targetValue}`, 0)
							end
						end
					end
				end)
			end

			if not success then scope:log(`Property Changer error:\n{errorString}`, false, "error", "warn") end
		end
	end

	local changeToucher: boolean = utility.getConfig(configuration, "ChangeToucher", false)
	local debounce = false
	local function activateChanger(toucher: BasePart?)
		if debounce then return end
		debounce = true
		task.delay(0.25, function() debounce = false end)

		if (changeToucher and toucher) and (utility.isPushbox(toucher) or utility.isTurret(toucher) or utility.isBalloon(toucher)) then
			changeProperties(toucher)
		end

		for _, taggedObject: Instance in taggedObjects do
			changeProperties(taggedObject)
		end
	end

	tagHandler.addChanger(changer, activateChanger)
	if utility.isSequence(changer) then return end

	local currentTrove = trove:Extend()
	currentTrove:Add(function() trove:Remove(currentTrove) end)
	currentTrove:AttachToInstance(changer)
	currentTrove:Connect(changer.Touched, function(toucher: BasePart)
		if not utility.evaluateToucher(changer, toucher, configuration) then return end
		local buttonActivated: boolean = utility.checkConfig(changer, "Activated")
		if typeof(buttonActivated) == "boolean" and not buttonActivated then return end

		activateChanger()
	end)

	if utility.getConfig(changer, "SupportFlips", false) then currentTrove:Add(utility.onFlipped(changer, activateChanger)) end
end
