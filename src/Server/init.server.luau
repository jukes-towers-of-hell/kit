--!strict

-->insert-corescript-warning<--

local StarterPlayer = game:GetService("StarterPlayer")
StarterPlayer.AutoJumpEnabled = false
StarterPlayer.CharacterUseJumpPower = true
game:GetService("StarterGui").ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

require(script.CollisionGroupManager):Init()
require(script.DamageEventManager):Init()
require(script.DeliverClientObjectsManager):Init()
