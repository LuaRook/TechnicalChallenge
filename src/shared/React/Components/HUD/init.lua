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

--[ Exports & Types & Defaults ]--
type SetScoreFn = (newScore: number) -> ()

--[ Object References ]--
local LocalPlayer: Player = Players.LocalPlayer

--[ Shorthand ]
local observeAttribute = Observers.observeAttribute

--[ Return Component ]--
return function()
	-- Create states for HUD
	local score: number, setScore: SetScoreFn = React.useState(0)
	local highScore: number, setHighScore: SetScoreFn = React.useState(0)

	-- Update values
	React.useEffect(function()
		-- Update values
		local attributeCleanup = observeAttribute(LocalPlayer, "Score", setScore) -- Update score
		local highScoreConnection = DataController:OnValueChanged("HighScore", setHighScore) -- Update high score

		-- Cleanup connections
		return function()
			if attributeCleanup then
				attributeCleanup()
			end
			if highScoreConnection then
				highScoreConnection:Disconnect()
				highScoreConnection = nil
			end
		end
	end)

	-- Create HUD container
	return React.createElement(Container, nil, {
		Score = React.createElement(Score, {
			Score = score,
			HighScore = highScore,
		}),
	})
end
