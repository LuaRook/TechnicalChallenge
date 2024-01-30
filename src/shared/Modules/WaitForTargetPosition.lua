--[[
	File: WaitForTargetPosition.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 22:53:49
	Version: 0.0.1

	Description:
		Given a target and goal position, yield until target is within proximity of goal.
--]]

--[ Constants ]--

local PROXIMITY: number = 0.5

--[ Export ]--

--[[
	Given a target and goal position, yield until target is within proximity of goal.

	@param target PVInstance The target instance.
	@param goalPosition Vector3 The goal position for the target.
	@return boolean
]]
return function(target: PVInstance, goalPosition: Vector3): boolean
	-- Yield until target reaches goal or doesn't exist
	while target and target.Parent and (target.Position - goalPosition).Magnitude > PROXIMITY do
		task.wait()
	end

	return true
end
