--[[
	File: SpawnPad.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 01:18:21
	Version: 0.0.1

	Description:
		No description provided.

--]]

--[ Roblox Services ]--
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local Component = require(ReplicatedStorage.Packages.Component)
local Timer = require(ReplicatedStorage.Packages.Timer)

--[ Extensions ]--
local TroveExtension = require(ReplicatedStorage.Shared.Extensions.TroveExtension)

--[ Root ]--
local SpawnPad = Component.new({
	Tag = "SpawnPad",
	Ancestors = { workspace },
	Extensions = { TroveExtension },
})

--[ Object References ]--
local Assets: Folder = ReplicatedStorage.Assets
local FriendlyAssets: Folder = Assets.Friendlies
local FriendliesFolder: Folder = workspace.Friendlies

--[ Constants ]--
local SPAWNED_TAG: string = "SpawnedFriendly"
local DEFAULT_TYPE: string = "Cow"
local ROTATION_AMOUNT: number = 75
local MAX_FRIENDLIES: number = 5

--[ Local Functions ]--

--[[
	Returns random point within the specified part.

	@param part BasePart The part to get the point for.
	@return Vector3 The random point within the specified part.
]]
local function GetRandomPointInPart(part: BasePart): Vector3
	local halfX: number = part.Size.X / 2
	local halfZ: number = part.Size.Z / 2

	return part.Position + Vector3.new(math.random(-halfX, halfX), 0, math.random(-halfZ, halfZ))
end

--[[
	Returns boolean determining if the friendly spawn limit has been reached.

	@return boolean Boolean determining if the friendly spawn limit has been reached.
]]
local function IsFriendlyLimitReached(): boolean
	return #CollectionService:GetTagged(SPAWNED_TAG) >= MAX_FRIENDLIES
end

--[ Public Functions ]--

--[[
	Spawns entity at a random point within the pad.
]]
function SpawnPad:Spawn()
	-- Check if another entity can be spawned
	if IsFriendlyLimitReached() then
		return
	end

	-- Check if friendly template exists
	if not self.FriendlyAsset then
		return
	end

	-- Spawn entity at a random point
	local friendlyAsset: BasePart = self._spawnTrove:Clone(self.FriendlyAsset)
	local randomPoint: Vector3 = GetRandomPointInPart(self.Instance)
	local yOffset: Vector3 = Vector3.yAxis * (friendlyAsset.Size.Y / 2)

	-- Position friendly with random orientation
	friendlyAsset.CFrame = CFrame.new(randomPoint + yOffset)
		* CFrame.Angles(0, math.random(-ROTATION_AMOUNT, ROTATION_AMOUNT), 0)

	-- Add spawned tag to friendly asset
	friendlyAsset.Parent = FriendliesFolder
	friendlyAsset:AddTag(SPAWNED_TAG)
end

--[[
	Spawns in the maximum amount of friendlies at the pad.
]]
function SpawnPad:SpawnMaximum()
	for _ = 1, MAX_FRIENDLIES do
		-- Break if limit is reached
		if IsFriendlyLimitReached() then
			break
		end

		self:Spawn()
	end
end

--[[
	Despawns all spawned friendlies.
]]
function SpawnPad:DespawnAll()
	self._spawnTrove:Clean()
end

--[ Initializers ]--
function SpawnPad:Start()
	self._spawnTrove = self._trove:Extend()
	self.SpawnInterval = self.Instance:GetAttribute("SpawnInterval")
	self.FriendlyAsset = FriendlyAssets:FindFirstChild(self.Instance:GetAttribute("FriendlyType") or DEFAULT_TYPE)

	-- Interval-based spawning
	self._trove:Add(Timer.Simple(self.SpawnInterval, function()
		self:Spawn()
	end))
end

--[ Return Component ]--
return SpawnPad
