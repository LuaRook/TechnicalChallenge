--[[
	File: DataService.lua
	Author(s): Rook Fait
	Created: 01/26/2024 @ 01:26:54
	Version: 0.0.1

	Description:
		DataService responsible for handling player data.
--]]

--[ Roblox Services ]--
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)
local ReplicaService = require(ReplicatedStorage.Packages.ReplicaService)
local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
local DefaultProfile = require(script.DefaultProfile)

--[ Root ]--
local DataService = Knit.CreateService({
	Name = "DataService",
})

--[ Exports & Types & Defaults ]--
type Dictionary = { [string]: any }
type Profile = {
	Data: Dictionary,
}

--[ Object References ]--
local ProfileStore = ProfileService.GetProfileStore("PlayerSaveDataV3", DefaultProfile)
local DataToken = ReplicaService.NewClassToken("PlayerData")

--[ Variables ]--

local PlayerReplicas: { [Player]: Profile } = {}
local PlayerProfiles: { [Player]: Profile } = {}

--[ Local Functions ]--

local function PlayerAdded(player: Player)
	-- Get player profile based on if in studio or not
	local profileKey: string = `Player_{player.UserId}`
	local profile = if RunService:IsStudio()
		then ProfileStore.Mock:LoadProfileAsync(profileKey)
		else ProfileStore:LoadProfileAsync(profileKey)

	-- Kick player if profile doesn't exist
	if not profile then
		return player:Kick("Unable to load your data. This might have been caused due to an issue with Roblox.")
	end

	-- Bind profile to user
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		-- Destroy replica
		if PlayerReplicas[player] then
			PlayerReplicas[player]:Destroy()
		end

		-- Remove references to profile and replica
		PlayerReplicas[player] = nil
		PlayerProfiles[player] = nil

		player:Kick("Your profile has been released!")
	end)

	-- Cache profile if player is still ingame. Otherwise, release profile.
	if player:IsDescendantOf(Players) then
		PlayerProfiles[player] = profile
		PlayerReplicas[player] = ReplicaService.NewReplica({
			ClassToken = DataToken,
			Tags = { Player = player },
			Data = profile.Data,
			Replication = { [player] = true },
		})
	else
		profile:Release()
	end
end

--[ Public Functions ]--

--[[
	Fetches profile for specified player.

	@param player Player The player to get the profile for.
	@return Profile?
]]
function DataService:GetPlayerReplica(player: Player): Profile?
	-- Wait until profile exists or player isn't apart of game hierarchy.
	while player.Parent and not self.Replicas[player] do
		task.wait()
	end

	-- Return possible profile. Could return nil if player leaves game before profile is cached.
	return self.Replicas[player]
end

--[[
	Fetches data for specified player.

	@param player Player The player to get data for.
	@return Dictionary?
]]
function DataService:GetPlayerData(player: Player): Dictionary?
	-- Fetch data replica from player
	local dataReplica: Profile? = self:GetPlayerReplica(player)
	if not dataReplica then
		return nil
	end

	-- Return profile data
	return dataReplica.Data
end

--[ Initializers ]--
function DataService:KnitStart()
	-- Connect to PlayerAdded
	for _, player: Player in pairs(Players:GetPlayers()) do
		task.defer(PlayerAdded, player)
	end
	Players.PlayerAdded:Connect(PlayerAdded)

	-- Release player profile
	Players.PlayerRemoving:Connect(function(player: Player)
		-- Release profile
		if PlayerProfiles[player] then
			PlayerProfiles[player]:Release()
		end

		-- Remove references
		PlayerReplicas[player] = nil
	end)
end

--[ Return Job ]--
return DataService
