--[[
	File: CameraScript.client.lua
	Author(s): Rook Fait
	Created: 01/27/2024 @ 00:48:32
	Version: 0.0.1

	Description:
		Positions camera behind player. Heavily reliant on current StarterPlayer properties.
--]]

--[ Await Game Loaded ]--
if not game:IsLoaded() then
	game.Loaded:Wait()
end

--[ Roblox Services ]--
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--[ Object References ]--
local Character: Model = script.Parent
local RootPart: BasePart = Character.PrimaryPart
local Waist: Motor6D = Character.UpperTorso.Waist
local Humanoid: Humanoid = Character.Humanoid

local Camera: Camera = workspace.CurrentCamera

--[ Constants ]--
local WAIST_OVERRIDE: CFrame = Waist.C0
local CAMERA_OFFSET: CFrame = Vector3.xAxis * 2

--[ Local Functions ]--
local function onUpdate()
	-- Update camera
	Camera.CameraType = Enum.CameraType.Attach
	Humanoid.CameraOffset = CAMERA_OFFSET
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	-- Update body
	Waist.C0 = Waist.C0:Lerp(WAIST_OVERRIDE * CFrame.Angles(Camera.CFrame.LookVector.Y, 0, 0), 0.35)
end

--[ Logic ]--

-- Roblox will automatically unbind the camera updater when the character is reset.
RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onUpdate)

-- Prevent character rotation
Humanoid.AutoRotate = false

-- Although BodyPosition is deprecated, it's much more straight forward than AlignPosition / VectorForce when it comes to prohibiting movement on one axis.
local bodyPosition: BodyPosition = Instance.new("BodyPosition")
bodyPosition.Position = Vector3.zAxis * RootPart.Position.Z
bodyPosition.MaxForce = Vector3.zAxis * 9999
bodyPosition.Parent = RootPart