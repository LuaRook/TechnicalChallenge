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

--[ React Components ]--
local Menu = require(script.Parent.Menu)
local HUD = require(script.Parent.HUD)

--[ Return Component ]--
return function()
	-- Create state for HUD visibility
	local showHUD: boolean, setShowHUD: (newVisibility: boolean) -> () = React.useState(false)

	-- Handle visibility
	React.useEffect(function() end)

	-- Return app
	return React.createElement(React.Fragment, nil, {
		Menu = not showHUD and React.createElement(Menu), -- Render menu if HUD is disabled
		HUD = showHUD and React.createElement(HUD), -- Render HUD if enabled
	})
end
