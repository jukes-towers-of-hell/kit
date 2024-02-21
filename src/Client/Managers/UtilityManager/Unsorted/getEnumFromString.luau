--!strict

return function(str: string | EnumItem, default: EnumItem?): any
	if typeof(str) == "EnumItem" then return str end
	-- ugly function, i hate having to check for enums :(
	-- please if any of you find a good way to make this better let me KNOW..
	local success: boolean, enum: EnumItem? = pcall(function()
		local splits: { string } = str:split(".")
		local enumType: any = if typeof(default) == "EnumItem" then default.EnumType else (Enum :: any)[splits[1]] -- i'm gonna go crazy
		return enumType[
			if (typeof(default) == "EnumItem" and tostring(default.EnumType) ~= splits[1]) -- WHY do i have to use tostring for this check???😭😭😭
				then splits[1]
				else splits[2]
		]
	end)

	return if success then enum else default
end
