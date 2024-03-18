--!strict

-->insert-corescript-warning<--

--[=[
@within utility
@prop tableUtil table

This is the TableUtil module that provides a lot of nice functions for working with tables.

Read more here: https://sleitnick.github.io/RbxUtil/api/TableUtil
]=]
return {
	tableUtil = require(script:FindFirstAncestor("Client").Packages.TableUtil),
}
