--# selene: allow(roblox_suspicious_udim2_new)

-->insert-repository-warning<--

return {
	CFrame = CFrame.new,
	Vector2 = Vector2.new,
	Vector3 = Vector3.new,
	Color3 = Color3.new,
	Color3RGB = Color3.fromRGB,
	Color3HSV = Color3.fromHSV,
	Color3HEX = Color3.fromHex,
	UDim = UDim.new,
	UDim2 = UDim2.new,
	PhysicalProperties = PhysicalProperties.new,
	NumberRange = NumberRange.new,
	NumberSequence = function(...) return NumberSequence.new({ ... }) end,
	NumberSequenceKeypoint = NumberSequenceKeypoint.new,
	ColorSequence = function(...) return ColorSequence.new({ ... }) end,
	ColorSequenceKeypoint = ColorSequenceKeypoint.new,
	BrickColor = BrickColor.new,
}
