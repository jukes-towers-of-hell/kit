"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[402],{95130:e=>{e.exports=JSON.parse('{"functions":[{"name":"checkConfig","desc":"This function is used to check for a specific `ValueBase` or `Attribute` in an Instance, based on the given `configName`. \\n\\tIf a `ValueBase` is found, it will return the `ValueBase`\'s value. If an `Attribute` is found, it will return the `Attribute`\'s value. \\n\\tIf no `ValueBase` or Attribute is found, it will return nil.","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"configName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"any\\r\\n"}],"function_type":"static","source":{"line":26,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"getConfigChangedSignal","desc":"This function is used to check for a specific `ValueBase` or `Attribute` in an Instance, then give it\'s ChangedSignal, based on the given `configName`. \\n\\tIf a `ValueBase` is found, it will return the `ValueBase`\'s ChangedSignal. If an `Attribute` is found, it will return the `Attribute`\'s ChangedSignal. \\n\\tIf no `ValueBase` or Attribute is found, it will return nil.","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"configName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"RBXScriptSignal?\\r\\n"}],"function_type":"static","source":{"line":44,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"hasTag","desc":"This function is used to check if an `Instance` has a tag with the provided `tagName` or if it has a `ValueBase`/`Attribute` with that `tagName`. \\n\\tIt does so by first checking if the `Instance` has the tag directly, and if not, \\n\\tit checks if there is a `ValueBase` or `Attribute` with the given `tagName`.","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"tagName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":64,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"isButtonActivatedPlatform","desc":"This function is used to check if the provided `Instance` is a ButtonActivatedPlatform.\\n\\tIt does so by first checking if the `Instance` is a `BasePart`, \\n\\tthen checking if the platform\'s name is ButtonActivatedPlatform or has the ButtonActivated tag. ","params":[{"name":"platform","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":76,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"isBalloon","desc":"This function is used to check if the provided `Instance` is a Balloon (or is within a Balloon).\\n\\tIt does so by checking if the name of the `Instance` is Balloon, and if not,\\n\\tit will instead check for the `Instance`\'s ancestors to see if it is within a Balloon. (You can disable this ancestor check by setting `doNotCheckAncestor` to `true`.)","params":[{"name":"parent","desc":"","lua_type":"Instance"},{"name":"doNotCheckAncestor","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":89,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"isTurret","desc":"This function is used to check if the provided `Instance` is a Turret (or is within a Turret).\\n\\tIt does so by checking if the name of the `Instance` is Bullet, and if not,\\n\\tit will instead check for the `Instance`\'s ancestors to see if it is within a Bullet. (You can disable this ancestor check by setting `doNotCheckAncestor` to `true`.)","params":[{"name":"parent","desc":"","lua_type":"Instance"},{"name":"doNotCheckAncestor","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":102,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"isPushbox","desc":"This function is used to check if the provided `Instance` is a Pushbox (or is within a Pushbox).\\n\\tIt does so by checking if the name of the `Instance` is Pushbox, and if not,\\n\\tit will instead check for the `Instance`\'s ancestors to see if it is within a Pushbox. (You can disable this ancestor check by setting `doNotCheckAncestor` to `true`.)","params":[{"name":"parent","desc":"","lua_type":"Instance"},{"name":"doNotCheckAncestor","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":115,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"isSequence","desc":"This function is used to check if the provided `Instance` is within a Sequencer sequence.\\n\\tIt does so by checking the `Instance`\'s ancestors to see if it is within a Sequencer.","params":[{"name":"parent","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":129,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"evaluateToucher","desc":"This function is used to validate the touching part. \\n\\tIt does so by doing the following checks: \\n- checking if the \\"SupportPlayers\\" configuration is toggled, and if the toucher is the local player\'s character.\\n- checking if the \\"SupportPushboxes\\" configuration is toggled, and if the toucher is a pushbox by using the [util.isPushbox](#isPushbox) function, and if the ColorSpecific configuration is toggled and the pushbox is the same color as the part.\\n- checking if the \\"SupportBalloons\\" configuration is toggled, and if the toucher is a balloon by using the [util.isBalloon](#isBalloon) function, and if the ColorSpecific configuration is toggled and the balloon is the same color as the part.\\n- checking if the \\"SupportTurrets\\" configuration is toggled, and if the toucher is a turret bullet by using the [util.isTurret](#isTurret) function, and if the ColorSpecific configuration is toggled and the turret bullet is the same color as the part.\\n\\n```lua\\n-- we\'re using troves here for garbage collection purposes\\nscope.trove:Add(part.Touched:Connect(function(toucher: BasePart)\\n\\tif not scope.utility.evaluateToucher(part, toucher, part) then return end\\n\\t-- run code!\\nend))\\n```\\n\\nYou can also disable certain checks by passing in a table, shown here:\\n```lua\\nlocal allowedChecks = {\\n\\tallowPlayer = true,\\n\\tallowPushbox = true,\\n\\tallowColorSpecific = false,\\n\\tallowBalloons = false,\\n\\tallowTurrets = false,\\n}\\n\\nif not scope.utility.evaluateToucher(part, toucher, part, allowedChecks) then return end\\n```","params":[{"name":"part","desc":"","lua_type":"BasePart"},{"name":"toucher","desc":"","lua_type":"BasePart"},{"name":"config","desc":"","lua_type":"Instance?"},{"name":"checkConfig","desc":"","lua_type":"typeof(defaultChecks)?"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","source":{"line":173,"path":"src/Client/Managers/UtilityManager/Checks.luau"}},{"name":"roundColor","desc":"Rounds the components of a Color3 to prevent any potential floating point issues.\\nMainly used by [Buttons](../docs/clientobjects/Buttons).","params":[{"name":"color","desc":"","lua_type":"Color3"}],"returns":[{"desc":"","lua_type":"Color3\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":19,"path":"src/Client/Managers/UtilityManager/Color Utility.luau"}},{"name":"subtractHSV","desc":"Subtracts the value of a Color3 by the given `subtract` number. \\nUseful for text stroke colors.","params":[{"name":"color","desc":"","lua_type":"Color3"},{"name":"subtract","desc":"default: 0.5","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"Color3\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":31,"path":"src/Client/Managers/UtilityManager/Color Utility.luau"}},{"name":"getInstanceProperty","desc":"Safely gets a property of an instance. \\nWill return `nil` if the property does not exist, or if any errors occur.","params":[{"name":"instance","desc":"","lua_type":"any"},{"name":"property","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"any"},{"desc":"","lua_type":"boolean"}],"function_type":"static","tags":["shorthand"],"source":{"line":23,"path":"src/Client/Managers/UtilityManager/SafeUtility.luau"}},{"name":"setInstanceProperty","desc":"Safely sets a property of an instance.","params":[{"name":"instance","desc":"","lua_type":"any"},{"name":"property","desc":"","lua_type":"string"},{"name":"value","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":35,"path":"src/Client/Managers/UtilityManager/SafeUtility.luau"}},{"name":"assureValueType","desc":"Checks if `value` and `default` are of the same type. \\nIf not, it will return the `default` value.","params":[{"name":"value","desc":"","lua_type":"unknown"},{"name":"default","desc":"","lua_type":"defaultType"}],"returns":[{"desc":"","lua_type":"defaultType\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":46,"path":"src/Client/Managers/UtilityManager/SafeUtility.luau"}},{"name":"getConfig","desc":"Shorthand for `utility.assureValueType(utility.checkConfig(instance, configName), default)`","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"configName","desc":"","lua_type":"string"},{"name":"default","desc":"","lua_type":"defaultType"}],"returns":[{"desc":"","lua_type":"defaultType"}],"function_type":"static","tags":["shorthand"],"source":{"line":58,"path":"src/Client/Managers/UtilityManager/SafeUtility.luau"}},{"name":"applyPartOptimizations","desc":"Shorthand function to set properties for `BaseParts` that aren\'t gonna be used to boost performance a little, \\n\\tI don\'t want to rewrite this every single time I want to use it.\\n\\tMainly used in the Sequencers.\\n\\nThis will apply the following properties:\\n- Transparency 0\\n- CanTouch false\\n- CanCollide false\\n- CanQuery false\\n- IgnoreAll Tag","params":[{"name":"part","desc":"","lua_type":"Instance?"}],"returns":[],"function_type":"static","tags":["shorthand"],"source":{"line":22,"path":"src/Client/Managers/UtilityManager/Unsorted/applyPartOptimizations.luau"}},{"name":"generateUID","desc":"Shorthand for [HttpService:GenerateGUID()](https://create.roblox.com/docs/reference/engine/classes/HttpService#GenerateGUID). \\n```lua\\nscope.utility.generateUID(false, true)\\n\\t--\x3e 4BA80F4637244B4BBA957E28B9443DE9\\n```","params":[{"name":"curlyBraces","desc":"","lua_type":"boolean?"},{"name":"removeSplit","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"string\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":17,"path":"src/Client/Managers/UtilityManager/Unsorted/generateUID.luau"}},{"name":"getEnumFromString","desc":"","params":[{"name":"str","desc":"","lua_type":"string | EnumItem"},{"name":"default","desc":"","lua_type":"EnumItem"}],"returns":[{"desc":"","lua_type":"any\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":11,"path":"src/Client/Managers/UtilityManager/Unsorted/getEnumFromString.luau"}},{"name":"onFlipped","desc":"This function allows you to bind a callback function once the player flips using the given `part`.\\n```lua\\nif scope.utility.hasTag(part, \\"CanFlip\\") then -- check if the player can even flip\\n\\t-- we\'re using troves here for garbage collection purposes\\n\\tscope.trove:Add(scope.utility.onFlipped(part, function()\\n\\t\\t-- run code here!\\n\\tend))\\nend\\n```","params":[{"name":"part","desc":"","lua_type":"BasePart"},{"name":"callback","desc":"The given function that will run once the player flips.","lua_type":"() -> ()"}],"returns":[{"desc":"Cleanup function; add this to your Trove!","lua_type":"() -> ()"}],"function_type":"static","source":{"line":26,"path":"src/Client/Managers/UtilityManager/Unsorted/onFlipped.luau"}},{"name":"playSoundFromPart","desc":"Plays the given `sound` at the given `parent`.\\nAutomatically cleans up after the sound has finished.","params":[{"name":"sound","desc":"","lua_type":"string | Sound"},{"name":"parent","desc":"Where the sound will play, can be any instance. Default will be `script` (which will play the sound globally).","lua_type":"Instance?"},{"name":"searchFrom","desc":"Where to look for the sound object if the the given `sound` is a string.","lua_type":"Instance?"}],"returns":[],"function_type":"static","source":{"line":16,"path":"src/Client/Managers/UtilityManager/Unsorted/playSoundFromPart.luau"}},{"name":"tween","desc":"Simple tween function that handles garbage collection properly.\\n\\n```lua\\nscope.utility.tween(part, 0.5, {\\n\\tColor = Color3.fromRGB(255, 0, 0)\\n})\\n```","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"time","desc":"","lua_type":"number"},{"name":"goal","desc":"","lua_type":"{ [string]: any }"},{"name":"easingStyle","desc":"[EasingStyle](https://create.roblox.com/docs/reference/engine/enums/EasingStyle)","lua_type":"Enum.EasingStyle?"},{"name":"easingDirection","desc":"[EasingDirection](https://create.roblox.com/docs/reference/engine/enums/EasingDirection)","lua_type":"Enum.EasingDirection?"},{"name":"...","desc":"","lua_type":"any\\r\\n"}],"returns":[{"desc":"","lua_type":"Tween\\r\\n"}],"function_type":"static","source":{"line":20,"path":"src/Client/Managers/UtilityManager/Unsorted/tween.luau"}},{"name":"WaitForDescendant","desc":"Waits until the provided `descendantName` is found within the provided `instance`.\\n\\nShorthand of `instance:FindFirstChild(descendantName, true)`","params":[{"name":"instance","desc":"","lua_type":"Instance"},{"name":"descendantName","desc":"the descendant to look for","lua_type":"string"},{"name":"timeout","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"Instance?\\r\\n"}],"function_type":"static","tags":["shorthand"],"source":{"line":17,"path":"src/Client/Managers/UtilityManager/Unsorted/WaitForDescendant.luau"}}],"properties":[{"name":"tableUtil","desc":"This is the TableUtil module that provides a lot of nice functions for working with tables.\\n\\nRead more here: https://sleitnick.github.io/RbxUtil/api/TableUtil","lua_type":"table","source":{"line":13,"path":"src/Client/Managers/UtilityManager/TableUtil.luau"}}],"types":[],"name":"utility","desc":"A table of utility functions that can be used to speed up the process of writing repository scripts for client objects.","realm":["Client"],"source":{"line":11,"path":"src/Client/Managers/UtilityManager/init.luau"}}')}}]);