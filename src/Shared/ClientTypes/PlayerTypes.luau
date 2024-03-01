--!strict
--# selene: allow(unused_variable)
-- ^ ???????????????????

-->insert-corescript-warning<--

local starterPlayer = game:GetService("StarterPlayer")
local starterGui = game:GetService("StarterGui")

export type CharacterChildren = {
	Humanoid: Humanoid & {
		Animator: Animator,
	},
	Shirt: Shirt,
	Pants: Pants,
	["Body Colors"]: BodyColors,
	["Shirt Graphic"]: ShirtGraphic,
	HumanoidRootPart: Part & {
		Climbing: Sound,
		Died: Sound,
		FreeFalling: Sound,
		GettingUp: Sound,
		Jumping: Sound,
		Landing: Sound,
		Running: Sound,
		Splash: Sound,
		Swimming: Sound,
		RootAttachment: Attachment,
		RootJoint: Motor6D,
	},
	Head: Part & {
		FaceCenterAttachment: Attachment,
		FaceFrontAttachment: Attachment,
		HairAttachment: Attachment,
		HatAttachment: Attachment,
		face: Decal,
		Mesh: SpecialMesh,
	},
	Torso: Part & {
		BodyBackAttachment: Attachment,
		BodyFrontAttachment: Attachment,
		LeftCollarAttachment: Attachment,
		NeckAttachment: Attachment,
		RightCollarAttachment: Attachment,
		WaistBackAttachment: Attachment,
		WaistCenterAttachment: Attachment,
		WaistFrontAttachment: Attachment,
		Neck: Motor6D,
		["Left Hip"]: Motor6D,
		["Left Shoulder"]: Motor6D,
		["Right Hip"]: Motor6D,
		["Right Shoulder"]: Motor6D,
		roblox: Decal,
	},
	["Left Arm"]: Part & {
		LeftGripAttachment: Attachment,
		LeftShoulderAttachment: Attachment,
	},
	["Left Leg"]: Part & {
		LeftFootAttachment: Attachment,
	},
	["Right Arm"]: Part & {
		RightGripAttachment: Attachment,
		RightShoulderAttachment: Attachment,
	},
	["Right Leg"]: Part & {
		RightFootAttachment: Attachment,
	},
} & typeof(starterPlayer.StarterCharacterScripts)

export type Character = Model & Instance & CharacterChildren
export type PlayerType = Player & {
	Character: Character?,
	PlayerGui: PlayerGui & {
		BubbleChat: ScreenGui,
		Chat: ScreenGui,
		Freecam: ScreenGui,
	} & typeof(starterGui),

	PlayerScripts: PlayerScripts & {
		BubbleChat: LocalScript,
		ChatScript: LocalScript,
		PlayerScriptsLoader: LocalScript,
		RbxCharacterSounds: LocalScript,
	} & typeof(starterPlayer.StarterPlayerScripts),
}

return nil
