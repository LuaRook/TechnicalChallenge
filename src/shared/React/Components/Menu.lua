--[[
	File: Menu.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 21:48:57
	Version: 0.0.1

	Description:
		Handles main menu logic.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)

--[ React Components ]--
local Container = require(script.Parent.Essential.Container)
local Button = require(script.Parent.Essential.Button)
local Label = require(script.Parent.Essential.Label)

--[ Return Component ]--
return function()
	return React.createElement(Container, nil, {
		-- Create title
		Title = React.createElement(Label, {
			Text = "FARM DEFENSE",
			Font = Enum.Font.GothamBold,

			AnchorPoint = Vector2.one * 0.5,
			Position = UDim2.fromScale(0.5, 0.45),
			Size = UDim2.fromScale(1, 0.1),
		}),

		-- Create play button (WIP)
		Play = React.createElement(Button, {
			Text = "Play",

			AnchorPoint = Vector2.one * 0.5,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.25, 0.1),

			[React.Event.Activated] = function()
				-- Add play method
			end,
		}),
	})
end
