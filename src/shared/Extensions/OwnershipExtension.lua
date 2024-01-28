--[[
	File: OwnershipExtension.lua
	Author(s): Rook Fait
	Created: 01/27/2024 @ 18:57:29
	Version: 0.0.1

	Description:
		Handles player ownership of components. 
		
		In a real situation, I'd add a connection for when the player leaves the game; however, this is unnecessary
		as components (Launcher / ClientLauncher) using this extension will be parented to the character, ensuring cleanup.
		The connection method would only be necessary when the object isn't parented to the character.
--]]

--[ Roblox Services ]--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--[ Root ]--
local OwnershipExtension = {}

--[ Constants ]--
local IS_CLIENT: boolean = RunService:IsClient()

--[ Object References ]--
local LocalPlayer: Player = IS_CLIENT and Players.LocalPlayer

--[ Local Functions ]--
local function GetOwnerFromId(ownerId: number)
	return Players:GetPlayerByUserId(ownerId)
end

--[ Extension Functions ]--

if IS_CLIENT then
	function OwnershipExtension.ShouldConstruct(component)
		local ownerId: number = component.Instance:GetAttribute("OwnerId")
		return ownerId ~= nil and ownerId == LocalPlayer.UserId
	end
end

function OwnershipExtension.Constructing(component)
	-- Store reference to owner ID
	local ownerId: number = component.Instance:GetAttribute("OwnerId")

	-- If constructing on client, it's garaunteed that the LocalPlayer is the owner because of the client-sided ShouldConstruct check.
	component.Player = if IS_CLIENT then LocalPlayer else GetOwnerFromId(ownerId)

	-- If owner exists, store reference to character in component.
	if component.Player then
		component.Character = component.Player.Character or component.Player.CharacterAdded:Wait()
	end
end

--[ Export ]--
return OwnershipExtension
