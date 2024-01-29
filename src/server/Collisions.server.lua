--[[
	File: Collisions.server.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 02:10:27
	Version: 0.0.1

	Description:
		Disables collisions between players.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local Observers = require(ReplicatedStorage.Packages.Observers)

--[ Local Functions ]--

local function DescendantAdded(descendant: BasePart)
	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Player"
	end
end

--[ Logic ]--

Observers.observeCharacter(function(_, character: Model)
	-- Connect to descendant added
	local descendantAddedConn: RBXScriptConnection = character.DescendantAdded:Connect(DescendantAdded)
	for _, descendant: BasePart in character:GetDescendants() do
		task.spawn(DescendantAdded, descendant)
	end

	-- Disconnect connection on character removal
	return function()
		if descendantAddedConn then
			descendantAddedConn:Disconnect()
			descendantAddedConn = nil
		end
	end
end)
