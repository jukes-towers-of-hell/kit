# Buttons

## ![](../../static/rbx_vanilla_icons/Configuration.png) ButtonConfigurations ![](../../static/rbx_vanilla_icons/Configuration.png)

---

### ![](../../static/rbx_vanilla_icons/NumberValue.png)![](../../static/rbx_vanilla_icons/Vector3Value.png)![](../../static/rbx_vanilla_icons/CFrameValue.png) ButtonPressOffset

Determines the offset (in studs) that the ButtonPart moves when pressed. This offset is relative to the ButtonPart's orientation.

- A number type will offset the ButtonPart on the negative Y axis.
- A Vector3 and CFrame type will offset the ButtonPart move on all axes (with CFrame also supporting an orientation offset).

Default value: 0.75

Types:

- number
- Vector3
- CFrame

---

### ![](../../static/rbx_vanilla_icons/StringValue.png) PressedMaterial

The material of the button when pressed.

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

The number of decimal places shown on the button's [timer](#-timer) (if enabled).

Default value: 0

Types:

- number

---

### ![](../../static/rbx_vanilla_icons/StringValue.png) TimerText

Overwrites the button timer with custom text. Any backticks (`) are replaced with the button timer.

Types:

- string

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) HideGUI

Hides the button timer (both on-screen and on the ButtonPart).

Default value: false

Types:

- boolean

---

## ![](../../static/rbx_vanilla_icons/BasePart.png) ButtonActivatedPlatform ![](../../static/rbx_vanilla_icons/BasePart.png)

---

### ![](../../static/rbx_vanilla_icons/NumberValue.png) SetTransparency

The button platform's transparency when activated.
Can also be added to descendants of button platforms (which have their transparency changed by buttons).

Default value: 0

Types:

- number

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) FullHide

Makes button platform transparency 1 instead of 0.6 when not activated. **Does not affect** its descendants.
Can also be added to descendants of button platforms (which have their transparency changed by buttons).

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) Invert

Inverts a button platform's state, making it active by default. Also affects all of its descendants (which are altered by buttons).

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) ColorOverride

Overrides the color of the button platform, making it affected by buttons of the configuration's color instead of the platform's color.

Types:

- Color3

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) IgnoreCanCollide

Makes a button platform's state not affect its collision.

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) IgnoreTransparency

Makes a button platform's state not affect its transparency. **Does not affect** the platform's descendants.

Types:

- tag

---

### ![](../../static/rbx_vanilla_icons/BoolValue.png) IgnoreAll

A combination of [IgnoreCanCollide](#-ignorecancollide) and [IgnoreTransparency](#-ignoretransparency).

Types:

- tag

---

help x3
