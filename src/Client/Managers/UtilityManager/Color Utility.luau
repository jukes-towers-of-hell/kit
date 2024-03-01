--!strict

-->insert-corescript-warning<--

-- Color Utility --
-- Functions for color operations, such as:
-- rounding a color (for buttons, pushboxes, etc)
-- subtracting the value of a color (to make text strokes)

local util = {}

--[=[
@within utility
@tag shorthand
]=]
function util.roundColor(color: Color3): Color3
	return Color3.fromRGB(math.floor((color.R * 255) + 0.5), math.floor((color.G * 255) + 0.5), math.floor((color.B * 255) + 0.5))
end

--[=[
@within utility
@tag shorthand
]=]
function util.subtractHSV(color: Color3, subtract: number?): Color3
	local hue, saturation, value = color:ToHSV()
	return Color3.fromHSV(hue, saturation, math.clamp(value - (subtract or 0.5), 0, 1))
end

return util
