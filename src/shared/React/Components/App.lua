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
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Knit = require(ReplicatedStorage.Packages.Knit)

--[ React Components ]--
local Menu = require(script.Parent.Menu)
local HUD = require(script.Parent.HUD)

--[ Services & Controllers ]--
local SoundtrackController = Knit.GetController("SoundtrackController")

--[ Object References ]--
local LocalPlayer: Player = Players.LocalPlayer

--[ Shorthand ]--
local observeAttribute = Observers.observeAttribute

--[ Return Component ]--
return function()
	-- Create state for HUD visibility
	local showHUD: boolean, setShowHUD: (newVisibility: boolean) -> () = React.useState(false)

	-- Update soundtrack based on HUD visibility
	React.useEffect(function()
		SoundtrackController:PlayTrack(if showHUD then "Game" else "Menu")
	end, { showHUD })

	-- Update HUD visibility based on playing attribute
	React.useEffect(function()
		local attributeCleanup = observeAttribute(LocalPlayer, "IsPlaying", setShowHUD)

		return function()
			if attributeCleanup then
				attributeCleanup()
			end
		end
	end)

	-- Return app
	return React.createElement(React.Fragment, nil, {
		Menu = not showHUD and React.createElement(Menu), -- Render menu if HUD is disabled
		HUD = showHUD and React.createElement(HUD), -- Render HUD if enabled
	})
end
