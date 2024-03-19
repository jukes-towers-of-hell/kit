--# selene: allow(roblox_suspicious_udim2_new)

-->insert-repository-warning<--

return {
	CFrame = { allow = { 0, Vector3.new() }, constructor = CFrame },
	Vector2 = { constructor = Vector2 },
	Vector3 = { constructor = Vector3 },
	Color3 = { constructor = Color3 },
	UDim = { constructor = UDim },
	UDim2 = { allow = { 0, UDim.new() }, constructor = UDim2 },
	PhysicalProperties = { constructor = PhysicalProperties },
	NumberRange = { constructor = NumberRange },
	NumberSequence = {
		allow = { 0, NumberSequenceKeypoint.new(0, 0) },
		constructor = NumberSequence,
	},
	NumberSequenceKeypoint = { constructor = NumberSequenceKeypoint },
	ColorSequence = {
		allow = { Color3.new(), "ColorSequenceKeypoint" },
		constructor = ColorSequence,
	},
	ColorSequenceKeypoint = {
		allow = { Color3.new(), 0 },
		constructor = ColorSequenceKeypoint,
	},
	Font = { allow = { "string", Enum.Font }, constructor = Font },
	BrickColor = { allow = { "string", 0 }, constructor = BrickColor },
}
