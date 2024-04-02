--!strict

-->insert-repository-warning<--

local Players = game:GetService("Players")
local localPlayer: Player = Players.LocalPlayer

local CollectionService = game:GetService("CollectionService")
local _T = require(game:GetService("ReplicatedStorage").ClientTypes)
export type RealValueBase = ValueBase & { Value: any }

local handler = {}

function handler.handle(scope: _T.Variables)
	local shared, trove, utility = scope.shared, scope.trove, scope.utility
	if shared.property_changers ~= nil then return shared.property_changers end

	local reference = {
		tagged = {} :: { [string]: { Instance } },
		changers = {} :: { [Instance]: () -> () },
	}

	local function tagFilter(instance: Instance)
		if not instance:IsDescendantOf(scope.clientObjects) then return false end
		return true
	end

	function reference.getTagged(tag: string)
		if tag == "" or tag == "None" then return {} end

		if reference.tagged[tag] ~= nil then return reference.tagged[tag] end
		local taggedObjects = {}
		reference.tagged[tag] = taggedObjects

		for _, taggedObject: Instance in utility.tableUtil.Filter(CollectionService:GetTagged(tag), tagFilter) do
			if table.find(taggedObjects, taggedObject) then continue end
			table.insert(taggedObjects, taggedObject)
		end

		trove:Connect(CollectionService:GetInstanceAddedSignal(tag), function(taggedObject: Instance)
			if not tagFilter(taggedObject) then return end
			if table.find(taggedObjects, taggedObject) then return end
			table.insert(taggedObjects, taggedObject)
		end)

		trove:Connect(CollectionService:GetInstanceRemovedSignal(tag), function(taggedObject: Instance)
			local inTable = table.find(taggedObjects, taggedObject)
			if not inTable then return end
			table.remove(taggedObjects, inTable)
		end)

		return taggedObjects
	end

	function reference.addChanger(changer: Instance, activator: () -> ())
		if reference.changers[changer] then return end
		reference.changers[changer] = activator
	end

	shared.property_changers = reference

	-- handle sequencer activators --
	scope.trove:Add(task.spawn(function()
		local startTime = os.clock()
		repeat
			task.wait()
		until shared.sequencer_cache ~= nil or (os.clock() - startTime) >= 1

		local sequencerCache = shared.sequencer_cache
		if not sequencerCache then return end
		sequencerCache.addActivator("PropertyChangers", {
			check = function(_, sequenceData)
				if not sequenceData.instance:IsA("BasePart") then return false end
				local isChanger = scope.utility.checkConfig(sequenceData.instance, "LoadFromRepository") == "PropertyChanger"
				if isChanger then utility.applyPartOptimizations(sequenceData.instance) end

				return isChanger
			end,

			activate = function(_, sequenceData, passedVariables: { [any]: any })
				local changer: any = reference.changers[sequenceData.instance]
				if not changer then return end
				task.spawn(changer, nil, passedVariables)
			end,
		})

		sequencerCache.addActivator("PropertyCheckers", {
			check = function(_, sequenceData)
				if not sequenceData.instance:IsA("BasePart") then return false end
				local isChanger = scope.utility.checkConfig(sequenceData.instance, "LoadFromRepository") == "PropertyChanger"
				if isChanger then utility.applyPartOptimizations(sequenceData.instance) end

				--return isChanger
			end,

			activate = function(_, sequenceData, passedVariables: { [any]: any })
				local changer: any = reference.changers[sequenceData.instance]
				if not changer then return end
				task.spawn(changer, nil, passedVariables)
			end,
		})
	end))

	return reference
end

handler.TWEENABLE_TYPES = { -- https://create.roblox.com/docs/reference/engine/classes/TweenService#Create
	--"boolean", -- you can tween booleans but i don't want to do that here !
	"number",
	"CFrame",
	"Rect",
	"Color3",
	"UDim",
	"UDim2",
	"Vector2",
	"Vector2int16",
	"Vector3",
}

local CONSTRUCTORS = require(script.Constructors)
local MATH_FUNCTIONS = require(script.MathFunctions)

handler.TYPE_HANDLERS = {
	function(scope: _T.Variables, currentValue: any, targetValue: any, propertyName: string, valueInstance: Instance?, _, instance) -- Instance
		local utility = scope.utility

		local useCurrentObject = valueInstance and utility.hasTag(valueInstance, "UseCurrentInstance")
		if useCurrentObject then targetValue = instance end
		if valueInstance then
			local realValue = valueInstance:GetAttribute("RealValue")
			if realValue ~= nil then targetValue = realValue end
		end

		if not (typeof(targetValue) == "Instance" and typeof(currentValue) ~= "Instance") then return targetValue end

		local currentInstance: Instance = if useCurrentObject
			then instance
			else valueInstance and valueInstance:IsA("ObjectValue") and valueInstance.Value
		if valueInstance and currentInstance then -- choose property/attribute from instance
			local returnedProperty
			local chosenValue = utility.checkConfig(valueInstance, "GetProperty")
			local chosenAttribute = utility.checkConfig(valueInstance, "GetAttribute")
			if typeof(chosenValue) == "string" then
				returnedProperty = utility.getInstanceProperty(currentInstance, chosenValue)
			elseif typeof(chosenAttribute) == "string" then
				returnedProperty = currentInstance:GetAttribute(chosenAttribute)
			end

			if typeof(currentValue) == "string" then
				returnedProperty = tostring(returnedProperty)
			elseif typeof(currentValue) == "number" then
				returnedProperty = tonumber(returnedProperty)
			end

			return returnedProperty
		end

		return utility.getInstanceProperty(targetValue, propertyName)
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, _: Instance?) -- EnumItem
		if not (typeof(currentValue) == "EnumItem" and (typeof(targetValue) == "string" or typeof(targetValue) == "EnumItem")) then
			return targetValue
		end
		return scope.utility.getEnumFromString(targetValue, currentValue)
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, propertyName: string, valueInstance: Instance?) -- string
		if not ((typeof(currentValue) == "string" or propertyName == "Component") and typeof(targetValue) == "string") then
			return targetValue
		end

		local utility = scope.utility
		local modifiedString = targetValue:gsub("{USERNAME}", localPlayer.Name):gsub("{DISPLAY_NAME}", localPlayer.DisplayName)

		if valueInstance then
			if utility.hasTag(valueInstance, "Concatenate") then modifiedString = (currentValue .. targetValue) end
			if utility.hasTag(valueInstance, "ConcatenateBefore") then modifiedString = (targetValue .. currentValue) end
		end

		return modifiedString
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, propertyName: string, valueInstance: Instance?) -- get components from datatype
		local utility = scope.utility
		if not valueInstance then return targetValue end

		if
			(typeof(targetValue) == "number" or propertyName == "Component")
			and (typeof(currentValue) == "Vector3" or typeof(currentValue) == "CFrame")
		then
			local modifiedVector = targetValue
			if utility.hasTag(valueInstance, "X") then modifiedVector = currentValue.X end
			if utility.hasTag(valueInstance, "Y") then modifiedVector = currentValue.Y end
			if utility.hasTag(valueInstance, "Z") then modifiedVector = currentValue.Z end

			return modifiedVector
		end
		if (propertyName == "Component") and (typeof(targetValue) == "Vector3" or typeof(targetValue) == "CFrame") then
			local modifiedVector: any = targetValue
			if utility.hasTag(valueInstance, "X") then modifiedVector = targetValue.X end
			if utility.hasTag(valueInstance, "Y") then modifiedVector = targetValue.Y end
			if utility.hasTag(valueInstance, "Z") then modifiedVector = targetValue.Z end

			return modifiedVector
		end

		if (typeof(targetValue) == "number" or propertyName == "Component") and (typeof(currentValue) == "Color3") then
			local finalValue = targetValue
			if utility.hasTag(valueInstance, "R") then finalValue = math.floor((currentValue.R * 255) + 0.5) end
			if utility.hasTag(valueInstance, "G") then finalValue = math.floor((currentValue.G * 255) + 0.5) end
			if utility.hasTag(valueInstance, "B") then finalValue = math.floor((currentValue.B * 255) + 0.5) end

			return finalValue
		end

		return targetValue
	end,

	function(_: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- number
		if targetValue == "{TIME}" then targetValue = os.clock() end
		if targetValue == "{HUGE}" then targetValue = math.huge end
		if targetValue == "{PI}" then targetValue = math.pi end
		if typeof(targetValue) == "NumberRange" then
			local type = if valueInstance then valueInstance:GetAttribute("NumberRangeType") else "Random"
			if type == "Random" then
				targetValue = Random.new():NextInteger(targetValue.Min, targetValue.Max)
			elseif type == "RandomNumber" then
				targetValue = Random.new():NextNumber(targetValue.Min, targetValue.Max)
			elseif type == "Clamp" then
				targetValue = math.clamp(currentValue, targetValue.Min, targetValue.Max)
			end
		end

		return targetValue
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, propertyName: string, valueInstance: Instance?) -- number
		if not ((typeof(currentValue) == "number" or propertyName == "Component") and typeof(targetValue) == "number") then
			return targetValue
		end
		if not valueInstance then return targetValue end

		local modifiedNumber = targetValue
		for tagName, func in MATH_FUNCTIONS do
			if scope.utility.hasTag(valueInstance, tagName) then modifiedNumber = func(currentValue, targetValue) end
		end

		return modifiedNumber
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- CFrame
		local utility = scope.utility
		if not valueInstance then return targetValue end

		if typeof(currentValue) == "CFrame" and typeof(targetValue) == "CFrame" then
			local modifiedCFrame = targetValue
			if utility.hasTag(valueInstance, "Rotation") then modifiedCFrame = currentValue.Rotation end
			if utility.hasTag(valueInstance, "Multiply") then modifiedCFrame = currentValue * targetValue end
			if utility.hasTag(valueInstance, "Inverse") then modifiedCFrame = currentValue:Inverse() end
			if utility.hasTag(valueInstance, "ToWorldSpace") then modifiedCFrame = currentValue:ToWorldSpace(targetValue) end
			if utility.hasTag(valueInstance, "ToObjectSpace") then modifiedCFrame = currentValue:ToObjectSpace(targetValue) end

			return modifiedCFrame
		end

		if typeof(currentValue) == "Vector3" and typeof(targetValue) == "CFrame" then
			local modifiedCFrame = targetValue
			if utility.hasTag(valueInstance, "Add") then modifiedCFrame = targetValue + currentValue end
			if utility.hasTag(valueInstance, "Subtract") then modifiedCFrame = targetValue - currentValue end
			return modifiedCFrame
		end

		if typeof(currentValue) == "CFrame" and typeof(targetValue) == "Vector3" then
			local modifiedCFrame = targetValue
			if utility.hasTag(valueInstance, "LookVector") then modifiedCFrame = currentValue.LookVector end
			if utility.hasTag(valueInstance, "RightVector") then modifiedCFrame = currentValue.RightVector end
			if utility.hasTag(valueInstance, "UpVector") then modifiedCFrame = currentValue.UpVector end
			if utility.hasTag(valueInstance, "XVector") then modifiedCFrame = currentValue.XVector end
			if utility.hasTag(valueInstance, "YVector") then modifiedCFrame = currentValue.YVector end
			if utility.hasTag(valueInstance, "ZVector") then modifiedCFrame = currentValue.ZVector end
			return modifiedCFrame
		end

		return targetValue
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- Vector3
		local utility = scope.utility
		if not valueInstance then return targetValue end

		if typeof(currentValue) == "Vector3" and typeof(targetValue) == "Vector3" then
			local modifiedVector: any = targetValue
			if utility.hasTag(valueInstance, "Add") then modifiedVector = currentValue + targetValue end
			if utility.hasTag(valueInstance, "Subtract") then modifiedVector = currentValue - targetValue end
			if utility.hasTag(valueInstance, "Multiply") then modifiedVector = currentValue * targetValue end
			if utility.hasTag(valueInstance, "Divide") then modifiedVector = currentValue / targetValue end
			if utility.hasTag(valueInstance, "Abs") then modifiedVector = modifiedVector:Abs() end
			if utility.hasTag(valueInstance, "Ceil") then modifiedVector = modifiedVector:Ceil() end
			if utility.hasTag(valueInstance, "Floor") then modifiedVector = modifiedVector:Floor() end
			if utility.hasTag(valueInstance, "Sign") then modifiedVector = modifiedVector:Sign() end
			if utility.hasTag(valueInstance, "Cross") then modifiedVector = currentValue:Cross(targetValue) end
			if utility.hasTag(valueInstance, "Dot") then modifiedVector = currentValue:Dot(targetValue) end
			return modifiedVector
		end

		if typeof(currentValue) == "Vector3" and typeof(targetValue) == "number" then
			local modifiedVector = currentValue
			if utility.hasTag(valueInstance, "Multiply") then modifiedVector = currentValue * targetValue end
			if utility.hasTag(valueInstance, "Divide") then modifiedVector = currentValue / targetValue end
			return modifiedVector
		end

		return targetValue
	end,

	function(
		scope: _T.Variables,
		currentValue: any,
		targetValue: any,
		propertyName: string,
		valueInstance: Instance?,
		componentData,
		instance
	) -- Create datatype from components
		if componentData == true then return targetValue end
		if not valueInstance then return targetValue end

		local components: Instance? = if valueInstance:IsA("Configuration")
			then valueInstance
			else valueInstance:FindFirstChild("Components")
		if not components then return targetValue end

		local constructor = CONSTRUCTORS[components:GetAttribute("Constructor") or typeof(currentValue)]
		if not constructor then return targetValue end

		local componentValues = {}
		for _, value in components:GetChildren() do
			if not (value:IsA("ValueBase") or value:IsA("Configuration")) then continue end

			local sort = (tonumber(value.Name) or tonumber(value.Name:split("|")[1]))
			if not sort then continue end

			local finalValue = if value:IsA("ValueBase") then (value :: any).Value else nil
			table.insert(componentValues, { sort = sort, value = finalValue, instance = value })
		end

		table.sort(componentValues, function(a, b) return a.sort < b.sort end)

		local finalComponentValues = {}
		for sort: number, value in componentValues do
			local finalValue = value.value
			for _, valueHandler in handler.TYPE_HANDLERS do
				finalValue = valueHandler(
					scope,
					nil,
					finalValue,
					"Component",
					value.instance,
					{ constructor = constructor, arg = sort },
					instance
				)
			end

			finalComponentValues[sort] = finalValue
		end

		local finalValue = constructor(table.unpack(finalComponentValues))
		for _, valueHandler in handler.TYPE_HANDLERS do
			finalValue = valueHandler(scope, currentValue, finalValue, propertyName, components, true, instance)
		end

		return finalValue
	end,
}

handler.FUNCTION_TYPES = { -- Preset functions
	Destroy = function(scope: _T.Variables, instance: Instance, arg: any)
		local utility = scope.utility
		if utility.isSequence(instance) then return end
		instance:Destroy()
	end,

	Clone = function() error("Instance:Clone() is blacklisted", 0) end,
	clone = function() error("Instance:clone() is blacklisted", 0) end,
}

return handler
