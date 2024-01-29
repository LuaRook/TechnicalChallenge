--[ Types ]--
type Weapon = BasePart & {
	Grip: Attachment?,
}

--[ Export ]--

--[[
	Attaches weapon to players hand using a RigidConstraint. Returns boolean to indicate success.

	@param character Model The character to attach the weapon to.
	@param weapon Weapon The weapon to attach to the specified character.
	@return boolean Determines if the attachment was successful.
]]
return function(character: Model, weapon: Weapon): boolean
	-- Get grip attachments while also ensuring
	local gripAtt: Attachment? = weapon and weapon:FindFirstChild("Grip")
	local handGripAtt: Attachment? = character and character:FindFirstChild("RightGripAttachment", true)
	if not gripAtt or not handGripAtt then
		return false
	end

	-- Create rigid constraint
	local rigidConstraint: RigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = gripAtt
	rigidConstraint.Attachment1 = handGripAtt
	rigidConstraint.Parent = weapon

	-- Parent weapon to character
	weapon.Parent = character
	return true
end
