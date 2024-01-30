--[ Roblox Services ]--

local SoundService = game:GetService("SoundService")

--[ Export ]--

--[[
	Loads sound in SoundService with specified name. 

	@param soundName string The name of the sound to load.
	@param parent Instance? Optional parent argument for cloning sounds into parents.
	@return boolean Determines if the attachment was successful.
]]
return function(soundName: string, parent: Instance?): Sound?
	-- Check arguments. If statements are used over assert to ensure errors don't stop execution.
	if typeof(soundName) ~= "string" then
		return warn(`Expected string for soundName; got {typeof(soundName)} instead.`)
	end

	-- Check for existing sound if parent is valid
	local isParentValid: boolean = typeof(parent) == "Instance"
	if isParentValid then
		local existingSound: Sound? = parent:FindFirstChild(soundName, true)
		if existingSound then
			return existingSound
		end
	end

	-- Check for existing sound or sound in SoundService
	local sound: Sound? = SoundService:FindFirstChild(soundName, true)
	if not sound then
		return warn(`Couldn't find sound by name "{soundName}" in SoundService!`)
	end

	-- If sound exists and parent isn't valid, return sound.
	if sound and not isParentValid then
		return sound
	end

	-- Parent and return sound
	local soundClone: Sound = sound:Clone()
	soundClone.Parent = parent
	return soundClone
end
