--[[
	File: Launcher.lua
	Author(s): Rook Fait
	Created: 01/27/2024 @ 16:24:32
	Version: 0.0.1

	Description:
		Handles all server-side launcher logic. In addition, this component allows for code to be recycled for all launchers.
		As a result, we don't need a seperate component for the egg launcher if we ever wanted to add a new launcher.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local Component = require(ReplicatedStorage.Packages.Component)
local FastcastRedux = require(ReplicatedStorage.Packages.FastcastRedux)
local LoadSound = require(ReplicatedStorage.Shared.Modules.LoadSound)

--[ Extensions ]--
local BridgeExtension = require(ReplicatedStorage.Shared.Extensions.BridgeExtension)
local TroveExtension = require(ReplicatedStorage.Shared.Extensions.TroveExtension)
local OwnershipExtension = require(ReplicatedStorage.Shared.Extensions.OwnershipExtension)

--[ Root ]--
local Launcher = Component.new({
	Tag = "Launcher",
	Ancestors = { workspace },
	Extensions = { BridgeExtension, OwnershipExtension, TroveExtension },
})

Launcher.Client = {
	CanFire = BridgeExtension.CreateProperty(true),
	Fire = BridgeExtension.CreateSignal(),
}

--[ Object References ]--

local BoundsFolder: Folder = workspace.Map.Bounds
local Assets: Folder = ReplicatedStorage.Assets
local ProjectileAssets: Folder = Assets.Projectiles
local ProjectilesFolder: Folder = workspace.Projectiles
local EggProjectile: BasePart = ProjectileAssets.Egg

--[ Constants ]--

local CACHE_SIZE: number = 25
local DEFAULT_DAMAGE: number = 15
local DEFAULT_SPEED: number = 500
local DEFAULT_RPM: number = 900

--[ Local Functions ]--

local function NewCasterBehavior(castParams: RaycastParams, provider)
	local behavior = FastcastRedux.newBehavior()
	behavior.Acceleration = Vector3.yAxis * -workspace.Gravity
	behavior.RaycastParams = castParams
	behavior.CosmeticBulletProvider = provider
	return behavior
end

function Launcher:_handleRayHit()
	self._trove:Connect(self._caster.RayHit, function(_, result, _, cosmeticBullet: BasePart)
		local impactSound: Sound? = LoadSound(cosmeticBullet:GetAttribute("Sound"), cosmeticBullet)
		if impactSound then
			impactSound:Play()
		end

		local impactParticle: ParticleEmitter? = cosmeticBullet:FindFirstChild("ImpactParticle", true)
		if impactParticle then
			impactParticle:Emit(30)
		end

		-- Attempt to get character and humanoid
		local hitModel: Model? = result.Instance:FindFirstAncestorOfClass("Model")
		local humanoid: Humanoid? = hitModel and hitModel:FindFirstChildOfClass("Humanoid")

		-- Damage humanoid if health is above 0
		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(self.Damage)
		end
	end)
end

function Launcher:_handleLengthChanged()
	self._trove:Connect(
		self._caster.LengthChanged,
		function(_, lastPoint, dir, displacement, _, cosmeticBullet: BasePart)
			cosmeticBullet.Position = lastPoint + (dir * displacement)
		end
	)
end

function Launcher:_handleCastTerminating()
	self._trove:Connect(self._caster.CastTerminating, function(cast)
		-- Make cosmetic bullet exist for half a second for effects
		local cosmeticBullet: BasePart? = cast.RayInfo.CosmeticBulletObject
		if cosmeticBullet then
			cosmeticBullet.Transparency = 1

			local trail: Trail? = cosmeticBullet:FindFirstChildOfClass("Trail")
			if trail then
				trail.Enabled = false
			end

			task.delay(0.5, function()
				self._provider:ReturnPart(cosmeticBullet)
			end)
		end
	end)
end

--[ Public Functions ]--

function Launcher:Fire(mousePosition: Vector3)
	-- Check if weapon can be fired
	if not self.Client.CanFire:GetFor(self.Player) or not self.Humanoid or self.Humanoid.Health <= 0 then
		return
	end

	-- Cast projectile
	local muzzlePosition: Vector3 = self.MuzzleAttachment.WorldPosition
	local mouseDirection: Vector3 = (mousePosition - muzzlePosition).Unit
	local castedProjectile = self._caster:Fire(muzzlePosition, mouseDirection, DEFAULT_SPEED, self._behavior)

	-- Handle cosmetic effects
	local cosmeticBullet: BasePart = castedProjectile.RayInfo.CosmeticBulletObject
	local trail: Trail? = cosmeticBullet:FindFirstChildOfClass("Trail")
	if trail then
		trail.Enabled = true
	end

	-- Play firing sound
	if self.FiringSound then
		self.FiringSound:Play()
	end

	-- Handle firing debounce
	self.Client.CanFire:SetFor(self.Player, false)
	task.delay(self.RPM, function()
		self.Client.CanFire:SetFor(self.Player, true)
	end)
end

--[ Initializers ]--
function Launcher:Construct()
	-- Setup configuration
	self.CosmeticTemplate = ProjectileAssets:FindFirstChild(self.Instance:GetAttribute("CosmeticName")) or EggProjectile -- Default to egg if projectile doesn't exist
	self.Damage = self.Instance:GetAttribute("Damage") or DEFAULT_DAMAGE
	self.Speed = self.Instance:GetAttribute("Speed") or DEFAULT_SPEED
	self.RPM = 60 / (self.Instance:GetAttribute("RPM") or DEFAULT_RPM)

	-- Object references
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.MuzzleAttachment = self.Instance:WaitForChild("Muzzle")
	self.FiringSound = LoadSound(self.Instance:GetAttribute("Sound"), self.MuzzleAttachment)

	-- Create params for caster behavior
	self.RaycastParams = RaycastParams.new()
	self.RaycastParams.FilterDescendantsInstances = { self.Character, BoundsFolder, ProjectilesFolder }
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
end

function Launcher:Start()
	-- Setup fastcast
	self._caster = FastcastRedux.new()
	self._provider =
		self._trove:Add(FastcastRedux.PartCache.new(self.CosmeticTemplate, CACHE_SIZE, ProjectilesFolder), "Dispose")
	self._behavior = NewCasterBehavior(self.RaycastParams, self._provider)

	-- Setup FastCast connections
	self:_handleRayHit()
	self:_handleLengthChanged()
	self:_handleCastTerminating()

	-- Use signal instead of client method to save networking resources as client methods return a result.
	-- BridgeExtension handles ownership-related sanity checks.
	self._trove:Connect(self.Client.Fire, function(_: Player, mousePosition: Vector3)
		self:Fire(mousePosition)
	end)
end

--[ Return Job ]--
return Launcher
