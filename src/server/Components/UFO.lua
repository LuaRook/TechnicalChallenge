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

--[ Dependencies ]--
local Component = require(ReplicatedStorage.Packages.Component)
local LoadSound = require(ReplicatedStorage.Shared.Modules.LoadSound)
local LauncherComponent = require(script.Parent.Launcher)

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

--[ Classes & Services ]--

--[ Object References ]--

--[ Constants ]--

local DEFAULT_ORIGIN: Vector3 = Vector3.new(0, 25, -75)
local FRIENDLY_TAG: string = "SpawnedFriendly"
local ATTACK_COOLDOWN: number = 30

--[ Variables ]--

--[ Shorthands ]--

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

function UFO:_setParticlesEnabled(enabled: boolean)
	for _, particle: ParticleEmitter in self.Instance:GetDescendants() do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = enabled
		end
	end
end

--[ Public Functions ]--

--[[
	Returns boolean that determines if the UFO can attack or not.

	@return boolean Determines if the UFO can attack or not.
]]
function UFO:CanAttack(): boolean
	return not self.Instance:GetAttribute("Attacking")
		and (not self._lastAttack or (os.time() - self._lastAttack) >= ATTACK_COOLDOWN)
end

--[[
	Updates origin of the UFO.

	@param origin Vector3 The origin of the UFO.
]]
function UFO:SetOrigin(origin: Vector3)
	self.Origin = origin
	self.AlignPosition.Position = origin
end

--[[
	Forces the UFO to move to the specified origin.
]]
function UFO:MoveToOrigin()
	self.AlignPosition.Position = self.Origin
end

--[[
	Makes the UFO attack the specified player with the specified projectile type.

	@param player Player The player the UFO should attack.
	@param projectileType The type of projectile to shoot at the player.
]]
function UFO:AttackPlayer(player: Player, projectileType: string)
	-- Move UFO back to origin
	self:MoveToOrigin()

	-- Make UFO track player

	-- Fire launcher with projectile type
	if not self.Launcher then
		self.Instance:SetAttribute("Attacking", false)
		return
	end

	self.Launcher:ChangeCosmeticTemplate(projectileType)
	self.Instance:SetAttribute("Attacking", false)
end

--[[
	Makes the UFO attack/beam up a friendly. After the specified friendly has been collected, a random player will be attacked.

	@param target Friendly The friendly to attack/beam up.
]]
function UFO:AttackFriendly(target: Friendly)
	-- Set attacking attribute to true
	self.Instance:SetAttribute("Attacking", true)

	-- Move UFO to target
	local targetPosition: Vector3 = target.Position
	self.AlignPosition.Position = Vector3.new(targetPosition.X, self.Origin.Y, targetPosition.Z)

	-- Handle attack visual effects
	LoadSound("Laughing", self.Instance):Play()
	self:_setParticlesEnabled(true)

	-- Beam target up to UFO
	target.Anchored = false
	target:SetNetworkOwner(nil)
	target.Attachment.AlignPosition.Attachment1 = self.CenterAtt

	--Based on name of target, play relevant sound
	local targetSound: Sound? = LoadSound(target.Name, target)
	if targetSound then
		targetSound:Play()
	end

	-- Disable particles upon target entering UFO
	self.Instance.Touched:Wait()
	self:_setParticlesEnabled(false)

	-- Attack player and destroy target
	self:AttackPlayer(nil, target.Name)
	target:Destroy()
end

function UFO:HeartbeatUpdate()
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
	-- Incorporate composition through using launcher for attacks
	self._trove:AddPromise(LauncherComponent:WaitForInstance(self.Instance):andThen(function(launcherComponent)
		self.Launcher = launcherComponent
	end))
end

function UFO:Construct()
	-- Object references
	self.CenterAtt = self.Instance.CenterAtt
	self.AlignPosition = self.CenterAtt.AlignPosition
	-- self.AlignOrientation

	-- Setup UFO movement
	self.Instance:SetNetworkOwner(nil)
	self:SetOrigin(DEFAULT_ORIGIN)

	-- Play UFO idle sound
	LoadSound("UFOIdle", self.Instance):Play()
end

--[ Return Job ]--
return UFO
