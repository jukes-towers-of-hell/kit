# Buttons

## ![](../../static/rbx_vanilla_icons/Configuration.png) ButtonConfigurations ![](../../static/rbx_vanilla_icons/Configuration.png)

---

### ![](../../static/rbx_vanilla_icons/NumberValue.png)![](../../static/rbx_vanilla_icons/Vector3Value.png)![](../../static/rbx_vanilla_icons/CFrameValue.png) ButtonPressOffset

This configuration determines the offset (in studs) that the button moves once it is pressed.

- If a number, determines the offset in the negative Y axis relative to the button
- If a Vector3, determines the offset on all axes relative to the button.
- If a CFrame, determines the offset and orientation on all axes relative to the button.

Default value: 0.75

Types:

- number
- Vector3
- CFrame

---

### ![](../../static/rbx_vanilla_icons/StringValue.png) PressedMaterial

The material of the button once it is pressed.

Default value: Neon

Types:

- EnumItem
- string

---

### ![](../../static/rbx_vanilla_icons/NumberValue.png) Timer

How many seconds the button will stay pressed.
Only works if the value is above 0.

Default value: 0

Types:

- number

---

### ![](../../static/rbx_vanilla_icons/NumberValue.png) DecimalPlaces

The number of decimal places shown on the button's timer. Only works when [Timer](#-timer) is active.

Default value: 0

Types:

- number

---

### ![](../../static/rbx_vanilla_icons/StringValue.png) TimerText

The custom text for the button's timer. Any backticks (`) will be replaced with the button timer. Leaving this blank will show the button's timer.

Types:

- string

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) HideGUI

Whether the button timer (both on-screen and on the button) will be visible.

Types:

- boolean

---

## ![](../../static/rbx_vanilla_icons/BasePart.png) ButtonActivatedPlatform ![](../../static/rbx_vanilla_icons/BasePart.png)

---

### ![](../../static/rbx_vanilla_icons/NumberValue.png) SetTransparency

This configuration determines the button platform's transparency when activated. Also works for individual descendants of the button platform.

Default value: 0

Types:

- number

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) FullHide

This configuration makes button platforms fully transparent when not activated. Also works for individual descendants of the button platform.

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) Invert

This configuration inverts a button platform's default state, making it activated by default. This also affects all of its descendants (which can be altered by buttons).

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) ColorOverride

This configuration overrides the color of the button platform, making it affected by buttons of the configuration's color instead of the platform's color.

Types:

- Color3

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) IgnoreCanCollide

This configuration makes a button platform's CanCollide property not affected by its state.
Only works if the instance is a BasePart.

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) IgnoreTransparency

This configuration makes a button platform's Transparency property not affected by its state. This does not apply to the platform's descendants.

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) IgnoreAll

A combination of IgnoreCanCollide and IgnoreTransparency.

Types:

- tag

---

help x2
