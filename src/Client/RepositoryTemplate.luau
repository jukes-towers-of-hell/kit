--!strict

local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Template = {}
Template.LoadOnStart = true -- Will determine if the script will run upon entering the tower.
function Template.new(scope: _T.Variables)
	--[[
		THINGS YOU NEED TO KNOW:
		- All code must be in this function
		- It is recommended put scope variables into their own variables for readability
			Example: ```lua
			local parent = scope.parent
			local clientObjects = scope.clientObjects
			local trove = scope.trove
			local communicators = scope.communicators
			```
		- All connections/threads/instances need be added to the Trove 
			An example of this would be: ```lua
			trove:Connect(runService.RenderStepped, function() end)
			trove:Add(task.spawn(function() end))
			trove:Add(instance)
			```
		- It is advised to use strict typing mode (--!strict on the top of your script) to make sure there aren't any silly mistakes when writing your code.
		- Do not use script.Parent, as it will not work. Instead use: scope.parent
		- if LoadOnStart is turned on, scope.parent will not exist, and instead you will need to use scope.clientObjects which will always exist.
		- If working with Custom Client Objects, please make a folder named "RepositoryScripts" in Workspace.Kit and place any of your new repository scripts there.
	]]
end

return Template
