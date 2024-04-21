# Buttons

## ![](../../static/rbx_vanilla_icons/Configuration.png) ButtonConfigurations ![](../../static/rbx_vanilla_icons/Configuration.png)
---
### ![](../../static/rbx_vanilla_icons/NumberValue.png)![](../../static/rbx_vanilla_icons/Vector3Value.png)![](../../static/rbx_vanilla_icons/CFrameValue.png) ButtonPressOffset

The offset of the button once it is pressed.

Default value: 0.75

Types:
* number
* Vector3
* CFrame

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) PressedMaterial

The material of the button once it is pressed.

Default value: Neon

Types:
* EnumItem
* string

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) Timer

How many seconds the button will stay pressed.
Only works if the value is above 0.

Default value: 0

Types:
* number

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) DecimalPlaces

The number of decimal places shown on the button's timer. Only works when [Timer](#-timer) is active.

Default value: 0

Types:
* number
* integer

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) TimerText

The custom text for the button's timer. `temporary special character` will be replaced with the timer value.

Types:
* string

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) HideGUI

Whether the button timer will be visible.

Types:
* boolean

---




## ![](../../static/rbx_vanilla_icons/BasePart.png) ButtonActivatedPlatform ![](../../static/rbx_vanilla_icons/BasePart.png)

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) SetTransparency

The transparency of the instance when it is enabled.

Default value: 0

Types:
* number

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) FullHide

Hides the instance when it is disabled.

Types:
* tag

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) Invert

Makes the instance enabled by default and disabled on button press.

Types:
* tag

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) ColorOverride

Overrides the button color that will activate the instance.

Types:
* Color3

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) IgnoreCanCollide

Prevents the instance's CanCollide property from being changed by buttons.
Only works if the instance is a BasePart.

Types:
* tag

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) IgnoreTransparency

Prevents the instance's Transparency property from being changed by buttons.

Types:
* tag

---
### ![](../../static/rbx_vanilla_icons/StringValue.png) IgnoreAll

A combination of IgnoreCanCollide and IgnoreTransparency.

Types:
* tag

---

help x2

