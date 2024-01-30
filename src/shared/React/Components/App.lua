--[[
	File: App.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 20:37:54
	Version: 0.0.1

	Description:
		No description provided.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)
local Knit = require(ReplicatedStorage.Packages.Knit)

--[ React Components ]--
local Menu = require(script.Parent.Menu)
local HUD = require(script.Parent.HUD)

--[ Services & Controllers ]--
local SoundtrackController = Knit.GetController("SoundtrackController")

--[ Object References ]--

local LocalPlayer: Player = Players.LocalPlayer

--[ Return Component ]--
return function()
	-- Create state for HUD visibility
	local showHUD: boolean, setShowHUD: (newVisibility: boolean) -> () = React.useState(false)

	-- Update logic for HUD visibility
	React.useEffect(function()
		-- Update soundtrack based on HUD visibility
		SoundtrackController:PlayTrack(if showHUD then "Game" else "Menu")

		-- Set attribute for player on menu
		LocalPlayer:SetAttribute("OnMenu", not showHUD)
	end, { showHUD })

	-- Return app
	return React.createElement(React.Fragment, nil, {
		-- Render menu if HUD is disabled
		Menu = not showHUD and React.createElement(Menu, {
			SetHUDVisible = setShowHUD,
		}),

		-- Render HUD if enabled
		HUD = showHUD and React.createElement(HUD),
	})
end
