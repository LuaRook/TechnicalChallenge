--[[
	File: GameService.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 20:13:33
	Version: 0.0.1

	Description:
		Handles gameplay logic such as level selection and spawning.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)
local Observers = require(ReplicatedStorage.Packages.Observers)
local RigFriendly = require(script.Parent.Parent.Modules.RigFriendly)
local AttachWeapon = require(script.Parent.Parent.Modules.AttachWeapon)

--[ Services ]--
local DataService

--[ Root ]--
local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {},
})

--[ Exports & Types & Defaults ]--
type EnemyData = {
	Type: string, -- The enemy type
	Origin: Vector3?, -- The origin of the enemy
}
type LevelData = {
	Enemies: { EnemyData },
	Friendlies: { string },
}

--[ Object References ]--
local Assets: Folder = ReplicatedStorage.Assets
local EnemyAssets: Folder = Assets.Enemies
local FriendlyAssets: Folder = Assets.Friendlies
local LauncherAssets: Folder = Assets.Launchers

local EnemyFolder: Folder = workspace.Enemies
local FriendlyFolder: Folder = workspace.Friendlies
local LevelConfigs: Folder = script:WaitForChild("Levels")

--[ Constants ]--
local SPAWNED_TAG: string = "SpawnedFriendly"
local ROTATION_AMOUNT: number = 75
local MAX_FRIENDLIES: number = 5

--[ Shorthand ]--
local observeCharacter = Observers.observeCharacter

--[ Local Functions ]--

--[[
	Returns boolean determining if the friendly spawn limit has been reached.

	@return boolean Boolean determining if the friendly spawn limit has been reached.
]]
local function IsFriendlyLimitReached(): boolean
	return #CollectionService:GetTagged(SPAWNED_TAG) >= MAX_FRIENDLIES
end

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

function GameService:_getRandomFriendlyType(): string
	-- Check if current level exists
	if not self.CurrentLevel then
		return
	end

	-- If length of friendlies is zero, return first index.
	local validFriendlies: { string } = self.CurrentLevel.Friendlies
	if validFriendlies == 1 then
		return validFriendlies
	end

	-- Return random friendly
	return validFriendlies[math.random(1, #validFriendlies)]
end

--[ Public Functions ]--

--[[
	Spawns enemy of the specified type at the specified origin.

	@param enemyType string The type of enemy to spawn.
	@param origin Vector3 The origin of the spawned enemy.
]]
function GameService:SpawnEnemy(enemyType: string, origin: Vector3?)
	local enemyTemplate: BasePart? = EnemyAssets:FindFirstChild(enemyType)
	if not enemyTemplate then
		return
	end

	local clonedEnemy: BasePart = enemyTemplate:Clone()
	clonedEnemy:SetAttribute("Origin", origin)
	clonedEnemy.Parent = EnemyFolder
end

--[[
	Spawns friendly at a random spawning pad.

	@param spawnBounds BasePart The bounds for the friendly to spawn within.
]]
function GameService:SpawnFriendly(spawnBounds: BasePart)
	-- Check if another entity can be spawned
	if IsFriendlyLimitReached() or not self:IsGameActive() then
		return
	end

	-- Attempt to get friendly type
	local friendlyType: string = self:_getRandomFriendlyType()
	local friendlyTemplate: BasePart? = FriendlyAssets:FindFirstChild(friendlyType)
	if not friendlyTemplate then
		return
	end

	-- Spawn entity at a random point
	local friendlyClone: BasePart = friendlyTemplate:Clone()
	local randomPoint: Vector3 = GetRandomPointInPart(spawnBounds)
	local yOffset: Vector3 = Vector3.yAxis * (friendlyClone.Size.Y / 2)

	-- Position friendly with random orientation
	friendlyClone.CFrame = CFrame.new(randomPoint + yOffset)
		* CFrame.Angles(0, math.random(-ROTATION_AMOUNT, ROTATION_AMOUNT), 0)

	-- Add spawned tag to friendly asset
	friendlyClone.Parent = FriendlyFolder
	friendlyClone:AddTag(SPAWNED_TAG)

	-- Rig friendly model so it can be beamed up
	RigFriendly(friendlyClone)
end

--[[
	Returns boolean that determines if the game is active or not.

	@return boolean Boolean that determines if the game is active or not.
]]
function GameService:IsGameActive(): boolean
	return self.GameActive
end

--[[
	Starts game with the specified level.

	@param levelName string The name of the level to load.
]]
function GameService:StartGame(levelName: string)
	-- Prevent another game from being started during an active game
	if self:IsGameActive() then
		return warn("Cannot start game during an active game!")
	end

	-- Get level module from name
	local dataModule: ModuleScript? = LevelConfigs:FindFirstChild(levelName)
	if not dataModule then
		return
	end

	-- Require module and get level data
	local levelData: LevelData = require(dataModule)

	-- Spawn enemies
	for _, enemy: EnemyData in levelData.Enemies do
		self:SpawnEnemy(enemy.Type, enemy.Origin)
	end

	self.GameActive = true
	self.CurrentLevel = levelData
end

--[[
	Ends game by removing both enemies and spawned friendlies.
]]
function GameService:EndGame()
	self.GameActive = false
	self.CurrentLevel = nil

	EnemyFolder:ClearAllChildren()
	FriendlyFolder:ClearAllChildren()
end

--[ Initializers ]--
function GameService:KnitStart()
	-- Get DataService within KnitStart to prevent race condition
	DataService = Knit.GetService("DataService")

	self:StartGame("Basic")

	-- Give players launchers
	observeCharacter(function(player: Player, character: Model)
		local playerData = DataService:GetPlayerData(player)

		-- Attempt to get player launcher type
		local launcherTemplate: BasePart? = LauncherAssets:FindFirstChild(playerData.Launcher)
		if not launcherTemplate then
			return
		end

		-- Attach launcher to player
		local launcherClone: BasePart = launcherTemplate:Clone()
		launcherClone:SetAttribute("OwnerId", player.UserId)
		AttachWeapon(character, launcherClone)
	end)
end

--[ Return Service ]--
return GameService
