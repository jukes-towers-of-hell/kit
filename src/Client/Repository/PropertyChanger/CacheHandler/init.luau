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

			activate = function(_, sequenceData)
				local changer = reference.changers[sequenceData.instance]
				if not changer then return end
				task.spawn(changer)
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

local mathFunctions = require(script.MathFunctions)

local function getProperty(scope: _T.Variables, valueInstance: ObjectValue, currentValue: any)
	if not valueInstance.Value then return currentValue end
	local utility = scope.utility
	local returnedProperty
	local chosenValue = utility.checkConfig(valueInstance, "GetProperty")
	local chosenAttribute = utility.checkConfig(valueInstance, "GetAttribute")
	if typeof(chosenValue) == "string" then
		returnedProperty = utility.getInstanceProperty(valueInstance.Value, chosenValue)
	elseif typeof(chosenAttribute) == "string" then
		returnedProperty = valueInstance.Value:GetAttribute(chosenAttribute)
	end

	if typeof(currentValue) == "string" then
		returnedProperty = tostring(returnedProperty)
	elseif typeof(currentValue) == "number" then
		returnedProperty = tonumber(returnedProperty)
	end

	return returnedProperty
end

handler.TYPE_HANDLERS = {
	function(scope: _T.Variables, currentValue: any, targetValue: any, propertyName: string, valueInstance: Instance?) -- Instance
		if not (typeof(targetValue) == "Instance" and typeof(currentValue) ~= "Instance") then return targetValue end
		if valueInstance and valueInstance:IsA("ObjectValue") and valueInstance.Value then -- choose property/attribute from instance
			return getProperty(scope, valueInstance, currentValue)
		end

		return scope.utility.getInstanceProperty(targetValue, propertyName)
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, _: Instance?) -- EnumItem
		if not (typeof(currentValue) == "EnumItem" and (typeof(targetValue) == "string" or typeof(targetValue) == "EnumItem")) then
			return targetValue
		end
		return scope.utility.getEnumFromString(targetValue, currentValue)
	end,

	function(_: _T.Variables, currentValue: any, targetValue: any, _: string, _: Instance?) --PhysicalProperties
		if not (typeof(currentValue) == "PhysicalProperties" and typeof(targetValue) == "string") then return targetValue end
		local components = {}
		for component in string.gmatch(targetValue, "%d+") do
			local numberValue = tonumber(component or "")
			if not numberValue then continue end
			table.insert(components, numberValue)
		end

		return PhysicalProperties.new(table.unpack(components))
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- string
		if not (typeof(currentValue) == "string" and typeof(targetValue) == "string") then return targetValue end

		local utility = scope.utility
		local modifiedString = targetValue:gsub("{USERNAME}", localPlayer.Name):gsub("{DISPLAY_NAME}", localPlayer.DisplayName)

		if valueInstance then
			if utility.hasTag(valueInstance, "Concatenate") then modifiedString = (currentValue .. targetValue) end
			if utility.hasTag(valueInstance, "ConcatenateBefore") then modifiedString = (targetValue .. currentValue) end
		end

		return modifiedString
	end,

	function(_: _T.Variables, currentValue: any, targetValue: any, _: string, _: Instance?) -- number
		if typeof(currentValue) == "number" and typeof(targetValue) == "string" then
			if targetValue == "{TIME}" then targetValue = os.clock() end
			if targetValue == "{HUGE}" then targetValue = math.huge end
			if targetValue == "{PI}" then targetValue = math.pi end
		end

		if typeof(currentValue) == "number" and typeof(targetValue) == "NumberRange" then
			targetValue = Random.new():NextInteger(targetValue.Min, targetValue.Max)
		end

		return targetValue
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- number
		if not (typeof(currentValue) == "number" and typeof(targetValue) == "number") then return targetValue end
		if not valueInstance then return targetValue end

		local utility = scope.utility
		local modifiedNumber = targetValue
		for tagName, func in mathFunctions do
			if utility.hasTag(valueInstance, tagName) then modifiedNumber = func(currentValue, targetValue) end
		end

		return modifiedNumber
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- CFrame
		local utility = scope.utility
		if not valueInstance then return targetValue end

		if typeof(currentValue) == "CFrame" and typeof(targetValue) == "CFrame" then
			local modifiedCFrame = targetValue
			if utility.hasTag(valueInstance, "Multiply") then modifiedCFrame = currentValue * targetValue end

			return modifiedCFrame
		end

		if typeof(currentValue) == "CFrame" and typeof(targetValue) == "Vector3" then
			local modifiedCFrame = currentValue
			if utility.hasTag(valueInstance, "Add") then modifiedCFrame = currentValue + targetValue end
			if utility.hasTag(valueInstance, "Subtract") then modifiedCFrame = currentValue - targetValue end
			return modifiedCFrame
		end

		return targetValue
	end,

	function(scope: _T.Variables, currentValue: any, targetValue: any, _: string, valueInstance: Instance?) -- Vector3
		local utility = scope.utility
		if not valueInstance then return targetValue end

		if typeof(currentValue) == "Vector3" and typeof(targetValue) == "Vector3" then
			local modifiedCFrame = targetValue
			if utility.hasTag(valueInstance, "Add") then modifiedCFrame = currentValue + targetValue end
			if utility.hasTag(valueInstance, "Subtract") then modifiedCFrame = currentValue - targetValue end
			if utility.hasTag(valueInstance, "Multiply") then modifiedCFrame = currentValue * targetValue end
			if utility.hasTag(valueInstance, "Divide") then modifiedCFrame = currentValue / targetValue end

			return modifiedCFrame
		end

		if typeof(currentValue) == "Vector3" and typeof(targetValue) == "number" then
			local modifiedCFrame = currentValue
			if utility.hasTag(valueInstance, "Multiply") then modifiedCFrame = currentValue * targetValue end
			if utility.hasTag(valueInstance, "Divide") then modifiedCFrame = currentValue / targetValue end
			return modifiedCFrame
		end

		return targetValue
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
