--[[
	File: UFO.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 02:12:13
	Version: 0.0.1

	Description:
		Handles UFO logic. Easily the messiest script in terms of logic.
--]]

--[ Roblox Services ]--
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--[ Dependencies ]--
local Component = require(ReplicatedStorage.Packages.Component)
local LoadSound = require(ReplicatedStorage.Shared.Modules.LoadSound)
local LauncherComponent = require(script.Parent.Launcher)
local WaitForTargetPosition = require(ReplicatedStorage.Shared.Modules.WaitForTargetPosition)

--[ Extensions ]--
local TroveExtension = require(ReplicatedStorage.Shared.Extensions.TroveExtension)

--[ Root ]--
local UFO = Component.new({
	Tag = "UFO",
	Ancestors = { workspace },
	Extensions = { TroveExtension },
})

--[ Exports & Types & Defaults ]--

type Friendly = BasePart & {
	Attachment: Attachment & {
		AlignPosition: AlignPosition,
	},
}

--[ Constants ]--

local SCROLL_TWEEN_INFO: TweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
local DEFAULT_ORIGIN: Vector3 = Vector3.new(25, 25, -75)
local FRIENDLY_TAG: string = "SpawnedFriendly"
local ATTACK_CHARGE_TIME: number = 5
local ATTACK_COOLDOWN: number = 15

--[ Local Functions ]--

--[[
	Returns a random friendly currently ingame.

	@return BasePart? The friendly selected.
]]
local function GetRandomFriendly(): BasePart?
	local spawnedFriendlies: { BasePart } = CollectionService:GetTagged(FRIENDLY_TAG)

	-- Guard against no spawned friendlies
	if #spawnedFriendlies == 0 then
		return nil
	end

	return spawnedFriendlies[math.random(1, #spawnedFriendlies)]
end

--[[
	Returns a random player. As this is a singleplayer experience, the returned
	player will always be the only player ingame. Randomization is only used here
	to futureproof for multiplayer integration.

	@return player Random player currently ingame.
]]
local function GetRandomPlayer(): Player
	local players: { Player } = Players:GetPlayers()
	return players[math.random(1, #players)]
end

function UFO:_setParticlesEnabled(enabled: boolean)
	for _, particle: ParticleEmitter in self.Instance:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = enabled
		end
	end
end

function UFO:_createScrollTween(): Tween
	-- Assuming that Origin.X is not zero, create vector that will move UFO to other side of map.
	local scrollOffset: Vector3 = Vector3.new(-self.Origin.X, self.Origin.Y, self.Origin.Z)

	-- Return repeating tween
	return self._trove:Add(TweenService:Create(self.AlignPosition, SCROLL_TWEEN_INFO, {
		Position = scrollOffset,
	}))
end

--[[
	Checks if any other UFO is attacking.

	@return boolean Boolean determining if any other UFOs are attacking.
]]
function UFO:_areOthersAttacking(): boolean
	for _, ufo in UFO:GetAll() do
		if ufo.Instance:GetAttribute("Attacking") then
			return true
		end
	end

	return false
end

--[ Public Functions ]--

--[[
	Returns boolean that determines if the UFO can attack or not.

	@return boolean Determines if the UFO can attack or not.
]]
function UFO:CanAttack(): boolean
	return not self.Instance:GetAttribute("Attacking")
		and (not self._lastAttack or (os.time() - self._lastAttack) >= ATTACK_COOLDOWN)
		and self.Launcher ~= nil
		and not self:_areOthersAttacking()
end

--[[
	Moves the UFO back to its origin and starts scrolling.
]]
function UFO:StartScrolling()
	self:MoveToOrigin()
	self._scrollTween:Play()
end

--[[
	Stops the UFO from scrolling.
]]
function UFO:StopScrolling()
	self._scrollTween:Cancel()
	self:MoveToOrigin()
end

--[[
	Updates origin of the UFO.

	@param origin Vector3 The origin of the UFO.
]]
function UFO:SetOrigin(origin: Vector3)
	-- Update origin variable and current position
	self.Origin = origin
	self.AlignPosition.Position = origin

	-- Remove previous scrolling tween
	if self._scrollTween then
		self._trove:Remove(self._scrollTween)
	end

	-- Create new scrolling tween and start
	self._scrollTween = self:_createScrollTween()
	self._scrollTween:Play()
end

--[[
	Forces the UFO to move to the specified origin.
]]
function UFO:MoveToOrigin()
	self.AlignPosition.Position = self.Origin
end

--[[
	Stops the UFO from targetting and resumes UFO scrolling.
]]
function UFO:StopTargeting()
	self.Target = nil
	self:StartScrolling()
end

--[[
	Makes the UFO attack the specified target with the specified friendly type.

	@param target Player The player the UFO should attack.
	@param friendlyType string The type of friendly to shoot at the player.
]]
function UFO:AttackPlayer(target: Player, friendlyType: string)
	-- Move UFO back to origin
	self:MoveToOrigin()

	-- Attempt to get target root
	local targetCharacter: Model? = target.Character
	local targetRoot: BasePart? = targetCharacter and targetCharacter.PrimaryPart
	if not targetRoot then
		return self:StartScrolling()
	end

	-- Track player for charge time
	self.Target = targetRoot
	task.wait(ATTACK_CHARGE_TIME)

	-- Fire launcher with friendly type
	self.Launcher:ChangeCosmeticTemplate(friendlyType)
	self.Launcher:Fire(self.Target.Position)

	-- Disable attacking
	self.Instance:SetAttribute("Attacking", false)
	self:StopTargeting()
end

--[[
	Makes the UFO attack/beam up a friendly. After the specified friendly has been collected, a random player will be attacked.

	@param target Friendly The friendly to attack/beam up.
]]
function UFO:AttackFriendly(target: Friendly)
	-- Attempt to get target AlignPosition
	local targetAligner: AlignPosition? = target:FindFirstChild("AlignPosition", true)
	if not targetAligner then
		return
	end

	-- Store target/friendly type
	local friendlyType: string = target.Name

	-- Set attacking attribute to true
	self.Instance:SetAttribute("Attacking", true)
	self:StopScrolling()

	-- Move UFO to target
	local targetPosition: Vector3 = target.Position
	local goalPosition: Vector3 = Vector3.new(targetPosition.X, self.Origin.Y, targetPosition.Z)
	self.AlignPosition.Position = goalPosition

	-- Wait for UFO to reach goal position
	WaitForTargetPosition(self.AlignPosition, goalPosition)

	-- Beam target up to UFO
	target.Anchored = false
	target:SetNetworkOwner(nil)
	targetAligner.Attachment1 = self.CenterAtt

	-- Handle visual effects for attacking target
	LoadSound("Laughing", self.Instance):Play()
	self:_setParticlesEnabled(true)

	--Based on name of target, play relevant sound
	local targetSound: Sound? = LoadSound(target.Name, target)
	if targetSound then
		targetSound:Play()
	end

	-- Disable particles upon target entering UFO
	-- Use WaitForTargetPosition over .Touched:Wait() as it covers the target not existing anymore and ignores collisions from eggs
	WaitForTargetPosition(target, self.AlignPosition.Position)
	self:_setParticlesEnabled(false)

	-- Destroy target if target still exists
	if target then
		target:Destroy()
	end

	-- Attack random player with captured friendly
	local randomPlayer: Player = GetRandomPlayer()
	self:AttackPlayer(randomPlayer, friendlyType)
end

function UFO:HeartbeatUpdate()
	-- Handle target tracking logic
	local target: BasePart? = self.Target
	self.AlignOrientation.CFrame = CFrame.Angles(math.rad(if target then -90 else 0), 0, 0)
	if target then
		local ufoPosition: Vector3 = self.AlignPosition.Position
		self.AlignPosition.Position = Vector3.new(target.Position.X, ufoPosition.Y, ufoPosition.Z)
	end

	-- Check if the UFO can attack or not
	if not self:CanAttack() then
		return
	end

	-- Store last attack time
	self._lastAttack = os.time()

	-- Choose random target and attack
	local randomTarget: Friendly = GetRandomFriendly()
	if randomTarget then
		self:AttackFriendly(randomTarget)
	end
end

--[ Initializers ]--
function UFO:Start()
	-- Set inital UFO origin
	if not self.Origin then
		self:SetOrigin(self.Instance:GetAttribute("Origin") or DEFAULT_ORIGIN)
	end

	-- Starts UFO scrolling
	self:StartScrolling()

	-- Incorporate composition through using launcher for attacks
	self._trove:AddPromise(LauncherComponent:WaitForInstance(self.Instance):andThen(function(launcherComponent)
		self.Launcher = launcherComponent
	end))
end

function UFO:Construct()
	-- Object references
	self.CenterAtt = self.Instance.CenterAtt
	self.AlignPosition = self.CenterAtt.AlignPosition
	self.AlignOrientation = self.CenterAtt.AlignOrientation

	-- Setup UFO movement
	self.Instance.Anchored = false
	self.Instance:SetNetworkOwner(nil)

	-- Define last attack as construction time to prevent immediate attacks
	self._lastAttack = os.time()

	-- Play UFO idle sound
	LoadSound("UFOIdle", self.Instance):Play()
end

--[ Return Component ]--
return UFO
