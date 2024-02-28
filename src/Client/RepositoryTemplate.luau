local _T = require(game:GetService("ReplicatedStorage").ClientTypes)

local Template = {}
Template.LoadOnStart = false -- Will determine if the script will run upon entering the tower.
function Template.new(scope: _T.Variables)
	--[[
		THINGS YOU NEED TO KNOW:
		- All code must be in this function
		- All connections/threads/instances need be added to the Trove 
			An example of this would be: ```lua
			scope.trove:Connect(runService.RenderStepped, function() end)
			scope.trove:Add(task.spawn(function() end)) 
			scope.trove:Add(instance)
			-- tip: make shorthand functions for these !
			```
		- It is recommended to use strict typing mode (--!strict on the top of your script) to make sure there aren't any silly mistakes when writing your code.
		- Do not use script.Parent, as it will not work. Instead use: scope.parent
		- if LoadOnStart is turned on, scope.parent will not exist, and instead you will need to use scope.clientObjects which will always exist.
		- If working with Custom Client Objects, Pushbox Scripts, Turret Scripts:
			please make a folder named "RepositoryScripts" in Workspace.Kit and place any of your new repository scripts there.
		- Feel free to remove the _T variable if you don't like it lol, it's only here for autocompletion purposes

		Once you've read all of this please remove this comment block !!
	]]
end

return Template
