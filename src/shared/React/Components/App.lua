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

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)
local HUD = require(script.Parent.HUD)

--[ Return Component ]--
return function()
	return React.createElement(React.Fragment, nil, {
		HUD = React.createElement(HUD), -- Create HUD
	})
end