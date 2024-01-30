--[[
	File: Label.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 20:44:04
	Version: 0.0.1

	Description:
		Creates label element from the specified props.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

--[ Exports & Types & Defaults ]--
export type LabelProps = {
	Text: string,
	Font: Enum.Font?,
	TextColor3: Color3?,
	TextScaled: boolean?,
	RichText: boolean?,

	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

--[ Constants ]--
local DEFAULT_PROPS: LabelProps = {
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextScaled = true,
	RichText = true,

	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
}

--[ Return Component ]--
return function(props: LabelProps)
	return React.createElement("TextLabel", TableUtil.Reconcile(props, DEFAULT_PROPS))
end
