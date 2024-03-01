--!strict

-->insert-corescript-warning<--

-- the purpose of this function is to set properties for parts that aren't gonna be used to boost performance a little
return function(part: Instance?)
	if not (part and part:IsA("BasePart")) then return end
	part.Transparency = 0
	part.CanTouch = false
	part.CanCollide = false
	part.CanQuery = false
	part:AddTag("IgnoreAll")
end
