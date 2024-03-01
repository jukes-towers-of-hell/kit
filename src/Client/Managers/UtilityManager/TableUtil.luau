--!strict

-->insert-corescript-warning<--

--[=[
@within utility
@prop tableUtil table

This is the TableUtil module that provides a lot of nice utilities for working with tables.

Docs: https://sleitnick.github.io/RbxUtil/api/TableUtil
]=]
return {
	tableUtil = require(script:FindFirstAncestor("Client").Packages.TableUtil),
}
