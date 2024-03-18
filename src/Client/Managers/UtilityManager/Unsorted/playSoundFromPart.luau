--!strict

-->insert-corescript-warning<--

local debris: Debris = game:GetService("Debris")

--[=[
	@within utility
	@param sound string | Sound
	@param parent Instance? -- Where the sound will play, can be any instance. Default will be `script` (which will play the sound globally).
	@param searchFrom Instance? -- Where to look for the sound object if the the given `sound` is a string. 

	Plays the given `sound` at the given `parent`.
	Automatically cleans up after the sound has finished.
]=]
local function playSoundFromPart(sound: string | Sound, parent: Instance?, searchFrom: Instance?)
	local soundToPlay: Instance?
	if typeof(sound) == "string" and typeof(searchFrom) == "Instance" then
		-- I really wish there was a way to check which script called this function so that i wouldn't have to use searchFrom every time i call it
		-- sadly getfenv disables some important optimizations :(
		soundToPlay = searchFrom:FindFirstChild(sound)
	elseif typeof(sound) == "Instance" then
		soundToPlay = sound
	end

	if typeof(soundToPlay) == "Instance" and soundToPlay:IsA("Sound") then
		local clonedSound = soundToPlay:Clone()
		clonedSound.Name = "\0" -- rename to a blank string so it doesn't get cloned by anything
		clonedSound.Parent = parent or script
		clonedSound:Play()
		debris:AddItem(clonedSound, clonedSound.TimeLength + 0.25)
	end
end

return playSoundFromPart
