--[[
	File: GameController.lua
	Author(s): Rook Fait
	Created: 01/29/2024 @ 23:08:33
	Version: 0.0.1

	Description:
		Controls client-sided game behavior. If this game were to be multiplayer, the camera controls in this controller could be replaced by a local script.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)
local MountHealthbar = require(ReplicatedStorage.Shared.Modules.MountHealthbar)

--[ Root ]--
local GameController = Knit.CreateController({
	Name = "GameController",
})

--[ Exports & Types & Defaults ]--

--[ Services & Controllers ]--

local GameService

--[ Object References ]--

local LocalPlayer: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera

local Character: Model
local Humanoid: Humanoid
local RootPart: BasePart
local Waist: Motor6D
local WaistOverride: CFrame

--[ Constants ]--
local BASE_SPEED: number = StarterPlayer.CharacterWalkSpeed
local GUN_CAMERA_OFFSET: Vector3 = Vector3.xAxis * 2
local MENU_CAMERA_OFFSET: CFrame = CFrame.new(0, 0.5, 5)

--[ Local Functions ]--

--[[
	Creates BodyPosition that limits the players movement to the X axis. Although
	lthough BodyPosition is deprecated, it's much more straight forward than
	AlignPosition / VectorForce when it comes to implementing this behavior.
]]
local function CreateAxisLimiter(): BodyPosition
	local bodyPosition: BodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = Vector3.zAxis * RootPart.Position.Z
	bodyPosition.MaxForce = Vector3.zAxis * 999999
	return bodyPosition
end

--[[
	Handles logic for when a new local character is added.

	@param character Model
]]
local function CharacterAdded(character: Model)
	-- Use WaitForChild to ensure that critical character parts exist
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
	RootPart = Character:WaitForChild("HumanoidRootPart")
	Waist = Character:WaitForChild("UpperTorso"):WaitForChild("Waist")
	WaistOverride = Waist.C0

	-- End game once character has been added
	GameController:EndGame()

	-- Prevent character rotation
	Humanoid.AutoRotate = false

	-- Although BodyPosition is deprecated, it's much more straight forward than AlignPosition / VectorForce when it comes to prohibiting movement on one axis.
	local bodyPosition: BodyPosition = CreateAxisLimiter()
	bodyPosition.Parent = RootPart

	-- Create local healthbar
	MountHealthbar(RootPart, Humanoid)
end

--[[
	Handles logic for Enum.RenderPriority.Camera
]]
local function CameraStepped()
	-- Check if character and humanoid exist
	if not Character or not Humanoid then
		return
	end

	-- Reference player playing as variable
	local isPlaying: boolean = GameController:IsPlaying()

	-- Update camera
	Camera.CameraType = if isPlaying then Enum.CameraType.Attach else Enum.CameraType.Scriptable
	Humanoid.CameraOffset = if isPlaying then GUN_CAMERA_OFFSET else Vector3.zero

	-- Fix camera orientation not resetting on menu
	if not isPlaying then
		Camera.CFrame = CFrame.new(RootPart.Position) * MENU_CAMERA_OFFSET
	end

	-- Update body if waist exists
	if Waist then
		Waist.C0 = if isPlaying
			then Waist.C0:Lerp(WaistOverride * CFrame.Angles(Camera.CFrame.LookVector.Y, 0, 0), 0.35)
			else WaistOverride
	end
end

--[[
	Handles logic for Enum.RenderPriority.Input
]]
local function InputStepped()
	-- Reference player playing as variable
	local isPlaying: boolean = GameController:IsPlaying()

	-- Update mouse behavior based on playing
	UserInputService.MouseBehavior = if isPlaying then Enum.MouseBehavior.LockCenter else Enum.MouseBehavior.Default

	-- Update humanoid speed
	if Humanoid then
		Humanoid.WalkSpeed = if isPlaying then BASE_SPEED else 0
	end
end

--[ Public Functions ]--

--[[
	Returns boolean determining if the player is currently playing the game or not.

	@return boolean Boolean determining if the player is currently playing the game or not.
]]
function GameController:IsPlaying()
	return LocalPlayer:GetAttribute("IsPlaying")
end

--[[
	Starts game with the specified levelName.
]]
function GameController:StartGame(levelName: string)
	GameService.StartGame:Fire(levelName)
	LocalPlayer:SetAttribute("IsPlaying", true)
end

--[[
	Handles client-sided logic for ending gameplay.
]]
function GameController:EndGame()
	GameService.EndGame:Fire()
	LocalPlayer:SetAttribute("IsPlaying", false)
end

--[ Initializers ]--
function GameController:KnitStart()
	-- Get GameService once Knit has loaded
	GameService = Knit.GetService("GameService")

	-- Bind stepped functions
	RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, CameraStepped)
	RunService:BindToRenderStep("Input", Enum.RenderPriority.Input.Value, InputStepped)

	-- Observe character
	LocalPlayer.CharacterAdded:Connect(CharacterAdded)
	if LocalPlayer.Character then
		task.spawn(CharacterAdded, LocalPlayer.Character)
	end
end

--[ Return Controller ]--
return GameController
