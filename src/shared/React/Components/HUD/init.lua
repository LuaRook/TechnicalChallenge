--[[
	File: init.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 20:42:14
	Version: 0.0.1

	Description:
		Initializes the HUD and creates HUD elements.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[ Dependencies ]--
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Knit = require(ReplicatedStorage.Packages.Knit)

--[ React Components ]--
local Container = require(script.Parent.Essential.Container)
local Score = require(script.Score)

--[ Services & Controllers ]--
local DataController = Knit.GetController("DataController")

--[ Object References ]--
local LocalPlayer: Player = Players.LocalPlayer

--[ Shorthand ]

local observeAttribute = Observers.observeAttribute

--[ Return Component ]--
return function()
	-- Create states for HUD
	local score, setScore = React.useState(0)
	local highScore, setHighScore = React.useState(0)

	-- Update values
	React.useEffect(function()
		observeAttribute(LocalPlayer, "Score", setScore) -- Update score
		DataController:OnValueChanged("HighScore", setHighScore) -- Update high score
	end)

	-- Create HUD container
	return React.createElement(Container, nil, {
		Score = React.createElement(Score, {
			Score = score,
			HighScore = highScore,
		}),
	})
end
