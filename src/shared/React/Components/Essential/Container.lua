--[[
	File: Container.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 20:52:16
	Version: 0.0.1

	Description:
		Creates container element for React Components.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

--[ Exports & Types & Defaults ]--
export type ContainerProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
}

--[ Constants ]--
local DEFAULT_PROPS: ContainerProps = {
	BackgroundTransparency = 1,

	AnchorPoint = Vector2.one * 0.5,
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0.5, 0.5),
}

--[ Return Component ]--
return function(props: ContainerProps)
	return React.createElement("Frame", TableUtil.Reconcile(props, DEFAULT_PROPS))
end
