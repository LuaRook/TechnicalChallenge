--[[
	File: ReactMounter.client.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 02:17:50
	Version: 0.0.1

	Description:
		Mounts roact UI.
--]]

--[ Await Game Loaded ]--

if not game:IsLoaded() then
	game.Loaded:Wait()
end

--[ Roblox Services ]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

--[ Dependencies ]--
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local React = require(ReplicatedStorage.Packages.React)
local Knit = require(ReplicatedStorage.Packages.Knit)

--[ React Components ]--
local App

--[ Object References ]--

local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create root UI
local AppUI: ScreenGui = Instance.new("ScreenGui")
AppUI.Name = "Game"
AppUI.ResetOnSpawn = false
AppUI.IgnoreGuiInset = true
AppUI.Parent = PlayerGui

--[ Mounter ]--

-- Disable core UI
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

-- Mount React UI once Knit has started
Knit.OnStart():andThen(function()
	-- Require React app once Knit starts
	App = require(ReplicatedStorage.Shared.React.Components.App)

	-- Render React app
	local Root = ReactRoblox.createRoot(AppUI)
	Root:render(React.createElement(App))
end)
