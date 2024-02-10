--!strict
-- by @synnwave
local physicsService: PhysicsService = game:GetService("PhysicsService")

type collisionGroup = {
	COLLIDES: { string },
	IGNORES: { string },
	DO_NOT_CREATE: boolean?,
}

local COLLISION_MAP: { [string]: collisionGroup } = {
	Default = {
		DO_NOT_CREATE = true,
		COLLIDES = { "DoNotCollideWithSelf" },
		IGNORES = { "NeverCollide" },
	},

	Player = {
		COLLIDES = { "DoNotCollideWithSelf" },
		IGNORES = { "NeverCollide", "OtherPlayers", "DoNotCollideWithPlayers" },
	},

	ClientObjects = {
		COLLIDES = { "DoNotCollideWithSelf" },
		IGNORES = { "NeverCollide", "OtherPlayers" },
	},

	OtherPlayers = {
		COLLIDES = {},
		IGNORES = { "NeverCollide" },
	},

	OnlyCollideWithPlayers = {
		COLLIDES = {},
		IGNORES = { "Default", "OtherPlayers", "DoNotCollideWithPlayers", "ClientObjects", "NeverCollide" },
	},

	DoNotCollideWithPlayers = {
		COLLIDES = {},
		IGNORES = { "NeverCollide", "OtherPlayers" },
	},

	DoNotCollideWithSelf = {
		COLLIDES = {},
		IGNORES = { "DoNotCollideWithSelf", "NeverCollide" },
	},

	OnlyCollideWithPlayers2 = {
		COLLIDES = {},
		IGNORES = {
			"Default",
			"DoNotCollideWithPlayers",
			"ClientObjects",
			"OtherPlayers",
			"OnlyCollideWithPlayers",
			"NeverCollide",
		},
	},

	NeverCollide = {
		COLLIDES = {},
		IGNORES = { "NeverCollide" },
	},

	FunItem = {
		COLLIDES = {},
		IGNORES = {
			"NeverCollide",
			"OtherPlayers",
			"Player",
			"ClientObjects",
			"OnlyCollideWithPlayers",
			"OnlyCollideWithPlayers2",
			"DoNotCollideWithPlayers",
			"DoNotCollideWithSelf",
		},
	},

	AlwaysCollide = {
		COLLIDES = {},
		IGNORES = { "OtherPlayers", "NeverCollide" }, -- guess it doesnt always collide
	},
}

local manager = {}
function manager:Init()
	-- first iteration: register collision groups from the map
	for groupName: string, collisionData: collisionGroup in COLLISION_MAP do
		if collisionData.DO_NOT_CREATE then continue end
		physicsService:RegisterCollisionGroup(groupName)
	end

	-- second iteration: set groups collidable
	for groupName: string, collisionData: collisionGroup in COLLISION_MAP do
		for _, collidesWith: string in collisionData.COLLIDES do
			physicsService:CollisionGroupSetCollidable(groupName, collidesWith, true)
		end

		for _, doesNotCollideWith: string in collisionData.IGNORES do
			physicsService:CollisionGroupSetCollidable(groupName, doesNotCollideWith, false)
		end
	end
end

return manager
