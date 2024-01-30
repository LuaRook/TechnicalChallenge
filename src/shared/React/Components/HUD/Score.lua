--[[
	File: Score.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 21:09:22
	Version: 0.0.1

	Description:
		No description provided.

--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)

--[ React Components ]--
local Label = require(script.Parent.Parent.Essential.Label)

--[ Exports & Types & Defaults ]--
type ScoreProps = {
	Score: number,
	HighScore: number,
}

--[ Return Component ]--
return function(props: ScoreProps)
	return React.createElement(Label, {
		-- Update score text. Displayed on one line to make it easier to read visually.
		Text = `<b>Score:</b> {props.Score} - <b>High Score:</b> {props.HighScore}`,

		-- Create element at top of screen
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromScale(1, 0.02),
	})
end
