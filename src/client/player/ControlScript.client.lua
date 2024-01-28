--[[
	File: ControlScript.client.lua
	Author(s): Rook Fait
	Created: 01/27/2024 @ 22:45:11
	Version: 0.0.1

	Description:
		Handles player controls and overrides the base ControlScript.
--]]

--[ Roblox Services ]--
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--[ Object References ]--

local LocalPlayer: Player = Players.LocalPlayer
local Humanoid: Humanoid?

--[ Variables ]--

local LeftValue: number, RightValue: number = 0, 0

--[ Local Functions ]--

local function moveLeft(_: string, inputState: Enum.UserInputState)
	if inputState == Enum.UserInputState.Begin then
		LeftValue = 1
	elseif inputState == Enum.UserInputState.End then
		LeftValue = 0
	end
end

local function moveRight(_: string, inputState: Enum.UserInputState)
	if inputState == Enum.UserInputState.Begin then
		RightValue = 1
	elseif inputState == Enum.UserInputState.End then
		RightValue = 0
	end
end

local function onUpdate()
	-- Ignore control updates if humanoid doesn't exist
	if not Humanoid then
		return
	end

	-- Move humanoid based on move direction
	local moveDirection: number = RightValue - LeftValue
	Humanoid:Move(Vector3.xAxis * moveDirection, false)
end

local function characterAdded(character: Model)
	-- Set humanoid variable to character humanoid
	Humanoid = character:WaitForChild("Humanoid")

	-- Disable autorotate to prevent player rotation
	Humanoid.AutoRotate = false
end

--[ Logic ]--

-- Bind control-related logic
ContextActionService:BindAction("Left", moveLeft, false, Enum.KeyCode.A, Enum.KeyCode.DPadLeft)
ContextActionService:BindAction("Right", moveRight, false, Enum.KeyCode.D, Enum.KeyCode.DPadRight)
RunService:BindToRenderStep("Control", Enum.RenderPriority.Input.Value, onUpdate)

-- Handle character logic
LocalPlayer.CharacterAdded:Connect(characterAdded)
if LocalPlayer.Character then
	characterAdded(LocalPlayer.Character)
end