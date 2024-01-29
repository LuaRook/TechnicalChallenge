--[[
	File: SpawnPad.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 01:18:21
	Version: 0.0.1

	Description:
		Handles spawning logic for friendlies.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local Component = require(ReplicatedStorage.Packages.Component)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Knit = require(ReplicatedStorage.Packages.Knit)

--[ Extensions ]--
local TroveExtension = require(ReplicatedStorage.Shared.Extensions.TroveExtension)

--[ Services ]--
-- This is safe to do as our boostrapper loads components after knit has started
local GameService = Knit.GetService("GameService")

--[ Root ]--
local SpawnPad = Component.new({
	Tag = "SpawnPad",
	Ancestors = { workspace },
	Extensions = { TroveExtension },
})

--[ Initializers ]--
function SpawnPad:Start()
	self.SpawnInterval = self.Instance:GetAttribute("SpawnInterval")

	-- Interval-based spawning
	self._trove:Add(Timer.Simple(self.SpawnInterval, function()
		GameService:SpawnFriendly(self.Instance)
	end))
end

--[ Return Component ]--
return SpawnPad
