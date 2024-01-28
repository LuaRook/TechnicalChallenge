--[[
	File: FetchAnimation.lua
	Author(s): Rook Fait
	Created: 01/27/2024 @ 17:11:10
	Version: 0.0.1

	Description:
		Returns loaded animation from the specified name for the specified animator.

--]]

--[ Constants ]--

-- Maps animation names to their respective IDs.
local ANIMATION_MAP: { [string]: string } = {
	LauncherIdle = "rbxassetid://16141428088",
}

--[ Variables ]--

-- Caches animation instances.
local AnimationCache: { [string]: Animation } = {}

--[ Export ]--

--[[
	Returns loaded animation from the specified name for the specified animator.

	@param animator Animator The Animator to load the animation for.
	@param animationName string The name of the animation to load.
	@return AnimationTrack? The loaded animation.
]]
return function(animator: Animator, animationName: string): AnimationTrack?
	-- Check if animator exists
	assert(
		typeof(animator) == "Instance" and animator:IsA("Animator"),
		`Expected animator; got {typeof(animator)} instead.`
	)

	-- Check if animation with the specified name exists.
	local animationId: string? = ANIMATION_MAP[animationName]
	if not animationId then
		return
	end

	-- Check cache for animation
	local animation: Animation? = AnimationCache[animationName]

	-- Create animation if ID exists.
	if not animation then
		animation = Instance.new("Animation")
		animation.AnimationId = animationId
		AnimationCache[animationName] = animation
	end

	-- Return loaded AnimationTrack
	return animator:LoadAnimation(animation)
end
