--[[
	File: LauncherClient.lua
	Author(s): Rook Fait
	Created: 01/27/2024 @ 16:23:55
	Version: 0.0.1

	Description:
		Handles all client-side launcher logic. In addition, this component allows for code to be recycled for all Launchers.
		As a result, we don't need a seperate component for the egg launcher if we ever wanted to add a new launcher.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

--[ Dependencies ]--
local Component = require(ReplicatedStorage.Packages.Component)
local LoadAnimation = require(ReplicatedStorage.Shared.Modules.LoadAnimation)

--[ Extensions ]--
local BridgeExtension = require(ReplicatedStorage.Shared.Extensions.BridgeExtension)
local TroveExtension = require(ReplicatedStorage.Shared.Extensions.TroveExtension)
local OwnershipExtension = require(ReplicatedStorage.Shared.Extensions.OwnershipExtension)

--[ Root ]--
local LauncherClient = Component.new({
	Tag = "Launcher",
	Ancestors = { workspace },
	Extensions = { BridgeExtension, OwnershipExtension, TroveExtension }, -- If this was a multiplayer game, I'd add an ownership extension to listen to an ``OwnerId`` attribute.
})

--[ Object References ]--

local BoundsFolder: Folder = workspace.Map.Bounds
local Camera: Camera = workspace.CurrentCamera
local RayParams: RaycastParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

--[ Constants ]--

local CAST_DISTANCE: number = 1000

--[ Local Functions ]--

--[[
	Replicates the (depricated) behavior of ``mouse.Hit.Position``.

	@return Vector3 The current position of the mouse.
]]
local function GetMousePosition(localCharacter: Model): Vector3
	-- Update parameters for mouse raycast
	RayParams.FilterDescendantsInstances = { localCharacter, BoundsFolder }

	-- Raycast from mouse origin
	local mousePosition: Vector2 = UserInputService:GetMouseLocation()
	local mouseRay: Ray = Camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastResult: RaycastResult? =
		workspace:Raycast(mouseRay.Origin, mouseRay.Direction * CAST_DISTANCE, RayParams)

	-- Return mouse position
	return if raycastResult then raycastResult.Position else mouseRay.Origin + (mouseRay.Direction * CAST_DISTANCE)
end

--[ Public Functions ]--

--[ Initializers ]--
function LauncherClient:Start()
	self.Animator = self.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
	self.IdleTrack = LoadAnimation(self.Animator, "LauncherIdle")

	-- Play holding animation
	if self.IdleTrack then
		self.IdleTrack:Play(0.25)
	end

	-- Convert property to remote
	self.Server.CanFire:Observe(function(canFire: boolean)
		self.Instance:SetAttribute("CanFire", canFire)
	end)

	-- Bind shooting action
	ContextActionService:BindAction("Fire", function(_: string, inputState: Enum.UserInputState)
		-- Pass all input that isn't of a beginning state.
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		-- Check on client if player can fire launcher
		if not self.Instance:GetAttribute("CanFire") then
			return Enum.ContextActionResult.Pass
		end

		-- Determine mouse position and relay to server
		local mousePosition: Vector3 = GetMousePosition(self.Character)
		self.Server.Fire:Fire(mousePosition)
	end, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)

	-- Stop animation and unbind action upon trove being cleaned / component stopping.
	self._trove:Add(function()
		-- Stop track
		if self.IdleTrack then
			self.IdleTrack:Stop(0.25)
		end

		-- Unbind action
		ContextActionService:UnbindAction("Shoot")
	end)
end

--[ Return Component ]--
return LauncherClient
