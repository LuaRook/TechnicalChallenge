--[ Roblox Services ]--

local SoundService = game:GetService("SoundService")

--[ Export ]--

--[[
	Loads sound in SoundService with specified name.

	@return boolean Determines if the attachment was successful.
]]
return function(soundName: string, parent: Instance): Sound?
	-- Check arguments
	assert(typeof(soundName) == "string", `Expected string for soundName; got {typeof(soundName)} instead.`)
	assert(typeof(parent) == "Instance", `Expected Instance for parent; got {typeof(parent)} instead.`)

	-- Check for existing sound
	local existingSound: Sound? = parent:FindFirstChild(soundName, true)
	if existingSound then
		return existingSound
	end

	-- Check for existing sound or sound in SoundService
	local sound: Sound? = SoundService:FindFirstChild(soundName, true)
	if not sound then
		return nil
	end

	-- Parent and return sound
	local soundClone: Sound = sound:Clone()
	soundClone.Parent = parent
	return soundClone
end
