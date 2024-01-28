--[[
	File: Rig.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 02:25:26
	Version: 0.0.1

	Description:
		Rigs friendly to be beamable by UFOs. The developer must sti
--]]

--[ Export ]--

--[[
	Rigs friendly to be beamable by UFOs. The developer must sti
]]
return function(friendly: BasePart)
	local attachment: Attachment = Instance.new("Attachment")
	attachment.Parent = friendly

	local alignPosition: AlignPosition = Instance.new("AlignPosition")
	alignPosition.ApplyAtCenterOfMass = true
	alignPosition.Responsiveness = 5
	alignPosition.Attachment0 = attachment
	alignPosition.Attachment1 = attachment
	alignPosition.Parent = attachment
end