--!strict

-->insert-corescript-warning<--

-- the purpose of this function is to set properties for parts that aren't gonna be used to boost performance a little

--[=[
	@within utility
	@tag shorthand

	Shorthand function to set properties for `BaseParts` that aren't gonna be used to boost performance a little, 
		I don't want to rewrite this every single time I want to use it.
		Mainly used in the Sequencers.

	This will apply the following properties:
	- Transparency 0
	- CanTouch false
	- CanCollide false
	- CanQuery false
	- IgnoreAll Tag
]=]

local function applyPartOptimizations(part: Instance?)
	if not (part and part:IsA("BasePart")) then return end
	part.Transparency = 0
	part.CanTouch = false
	part.CanCollide = false
	part.CanQuery = false
	part:AddTag("IgnoreAll")
end

return applyPartOptimizations
