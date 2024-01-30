--[[
	File: SoundtrackController.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 22:07:21
	Version: 0.0.1

	Description:
		Handles game soundtrack.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)

--[ Root ]--
local SoundtrackController = Knit.CreateController({
	Name = "SoundtrackController",
})

--[ Object References ]--
local MusicGroup: SoundGroup = SoundService.Master.Music

--[ Variables ]--
local TrackCache: { [string]: Sound } = {}

--[ Public Functions ]--

--[[
	Returns the track with the specified name.

	@param trackName string The name of the track to play.
	@return Sound? The returned track.
]]
function SoundtrackController:GetTrackFromName(trackName: string): Sound?
	-- Get track
	local track: Sound = TrackCache[trackName] or MusicGroup:FindFirstChild(trackName)

	-- If track doesn't exist, return warning
	if not track then
		return warn(`Track by the name of "{trackName}" doesn't exist!`)
	end

	-- If track isn't cached, cache track.
	if not TrackCache[trackName] then
		TrackCache[trackName] = track
	end

	-- Return track
	return track
end

--[[
	Stops all cached tracks.
]]
function SoundtrackController:StopPlayingTracks()
	for _, track: Sound in TrackCache do
		track:Stop()
	end
end

--[[
	Plays track with specified name.

	@param trackName string The name of the track to play.
]]
function SoundtrackController:PlayTrack(trackName: string)
	-- Stop playing tracks
	self:StopPlayingTracks()

	-- Attempt to get track from name
	local track: Sound? = self:GetTrackFromName(trackName)
	if not track then
		return
	end

	-- Play track
	track:Play()
end

--[ Return Controller ]--
return SoundtrackController
