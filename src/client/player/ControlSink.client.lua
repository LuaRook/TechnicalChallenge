--[[
	File: ControlSink.client.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 00:44:20
	Version: 0.0.1

	Description:
		Disables forwards and backwards movement for players.
--]]

--[ Roblox Services ]--
local ContextActionService = game:GetService("ContextActionService")

--[ Constants ]--
local SINK_ACTIONS: { Enum.PlayerActions } = {
	Enum.PlayerActions.CharacterForward,
	Enum.PlayerActions.CharacterBackward,
	Enum.PlayerActions.CharacterJump,
}

--[ Local Functions ]--
local function sinkInput()
	return Enum.ContextActionResult.Sink
end

--[ Logic ]--
ContextActionService:BindActionAtPriority(
	"SinkControl",
	sinkInput,
	false,
	Enum.ContextActionPriority.High.Value,
	unpack(SINK_ACTIONS)
)
