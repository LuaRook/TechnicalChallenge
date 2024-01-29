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
local Players = game:GetService("Players")

--[ Dependencies ]--

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

--[ Object References ]--

local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create root UI
local RootUI: ScreenGui = Instance.new("ScreenGui")
RootUI.Name = "Game"
RootUI.ResetOnSpawn = false
RootUI.IgnoreGuiInset = true
RootUI.Parent = PlayerGui

--[ Mounter ]--

local Root = ReactRoblox.createRoot(RootUI)
Root:render(React.createElement("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
}))
