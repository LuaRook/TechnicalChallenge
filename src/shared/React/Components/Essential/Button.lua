--[[
	File: Button.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 22:20:45
	Version: 0.0.1

	Description:
		No description provided.

--]]
--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

--[ Exports & Types & Defaults ]--
export type ButtonProps = {
	Text: string,
	Font: Enum.Font?,
	TextColor3: Color3?,
	TextScaled: boolean?,
	RichText: boolean?,

	BackgroundColor3: Color3?,
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

--[ Constants ]--
local DEFAULT_PROPS: ButtonProps = {
	Font = Enum.Font.Gotham,
	TextColor3 = Color3.fromRGB(0, 0, 0),
	TextScaled = true,
	RichText = true,

	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	Size = UDim2.fromScale(1, 1),
}

--[ Return Component ]--
return function(props: ButtonProps)
	return React.createElement("TextButton", TableUtil.Reconcile(props, DEFAULT_PROPS), {
		-- Create corner for added depth
		Corner = React.createElement("UICorner", nil),
	})
end
