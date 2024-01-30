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
local Players = game:GetService("Players")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)
local RigFriendly = require(script.Parent.Parent.Modules.RigFriendly)
local AttachWeapon = require(script.Parent.Parent.Modules.AttachWeapon)
local LauncherComponent = require(script.Parent.Parent.Components.Launcher)

--[ Services ]--
local DataService

--[ Root ]--
local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {},

	-- Create trove for cleaning up connections after game ends
	_gameTrove = Trove.new(),
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

type EnemyParams = {
	Origin: Vector3?,
	Health: number?,
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
local SCORE_INCREMENT: number = 10
local MAX_FRIENDLIES: number = 5

--[ Shorthand ]--
local observeCharacter = Observers.observeCharacter

--[ Local Functions ]--

local function SaveHighScore(player: Player)
	-- Check if player data exists
	local playerData = DataService:GetPlayerData(player)
	if not playerData then
		return
	end

	-- Save current score if score is higher than saved high score
	local currentScore: number = GameService:GetScore(player)
	if playerData.HighScore < currentScore then
		playerData.HighScore = currentScore
	end

	-- Remove score attribute from player
	player:SetAttribute("Score", nil)
end

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
	Gets the score for the specified player.

	@param player Player The player to get the score from.
]]
function GameService:GetScore(player: Player)
	return player:GetAttribute("Score")
end

--[[
	Increments score for the specified player.

	@param player Player The player to increase score for.
	@param incrementBy number The amount to increment the players score by.
]]
function GameService:IncrementScore(player: Player, incrementBy: number)
	local existingScore: number = self:GetScore(player) or 0
	return player:SetAttribute("Score", existingScore + incrementBy)
end

--[[
	Spawns enemy of the specified type at the specified origin.

	@param enemyType string The type of enemy to spawn.
	@param enemyParams EnemyParams Parameters for the spawned entity.
]]
function GameService:SpawnEnemy(enemyType: string, enemyParams: EnemyParams): BasePart
	local enemyTemplate: BasePart? = EnemyAssets:FindFirstChild(enemyType)
	if not enemyTemplate then
		return
	end

	local clonedEnemy: BasePart = enemyTemplate:Clone()
	if enemyParams.Origin then
		clonedEnemy:SetAttribute("Origin", enemyParams.Origin)
	end

	-- Handle enemy humanoiod
	local enemyHumanoid: Humanoid? = clonedEnemy:FindFirstChildOfClass("Humanoid")
	if enemyHumanoid then
		-- Update humanoid health
		local maxHealth: number = enemyParams.Health or enemyHumanoid.MaxHealth
		enemyHumanoid.MaxHealth = maxHealth
		enemyHumanoid.Health = maxHealth

		-- Destroy enemy humanoid on death and create new enemy
		-- Use HealthChanged as .Died doesn't fire for parts with humanoids
		self._gameTrove:Connect(enemyHumanoid.HealthChanged, function()
			-- Check if humanoid is still alive
			if enemyHumanoid.Health > 0 then
				return
			end

			-- Destroy enemy and spawn new & stronger enemy
			clonedEnemy:Destroy()
			self:SpawnEnemy(enemyType, {
				Origin = enemyParams.Origin,
				Health = maxHealth * 2, -- Multiply previous health by two to make next enemy tougher
			})
		end)
	end

	clonedEnemy.Parent = EnemyFolder
	return clonedEnemy
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
		self:SpawnEnemy(enemy.Type, {
			Origin = enemy.Origin,
		})
	end

	self.GameActive = true
	self.CurrentLevel = levelData

	-- Add cleanup task to cleanup variables and map
	self._gameTrove:Add(function()
		-- Reset game variables
		self.GameActive = false
		self.CurrentLevel = nil

		-- Clear map
		EnemyFolder:ClearAllChildren()
		FriendlyFolder:ClearAllChildren()
	end)
end

--[[
	Handles logic for ending game.
]]
function GameService:EndGame()
	-- Clean game trove
	self._gameTrove:Clean()

	-- Respawn all player and save high scores
	for _, player: Player in Players:GetPlayers() do
		-- Save high score
		task.spawn(SaveHighScore, player)

		-- Respawn player
		player:LoadCharacter()
	end
end

--[[
	Provides easy-to-use API for any external services/handlers to add tasks to the game trove.

	@param task any The task to add to the game trove.
	@return any
]]
function GameService:AddCleanupTask(task: any): any
	-- Check if game is active
	if not self:IsGameActive() then
		return warn("Cannot add cleanup task when game is inactive!")
	end

	return self._gameTrove:Add(task)
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

		-- Handle score incrementation in
		local hitConnection: RBXScriptConnection?
		local promise = LauncherComponent:WaitForInstance(launcherClone):andThen(function(launcherComponent)
			hitConnection = launcherComponent.TargetHit:Connect(function(target)
				-- Check if target has humanoid
				local humanoid: Humanoid? = target and target:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					return
				end

				-- Increment score of player
				self:IncrementScore(player, SCORE_INCREMENT)
			end)
		end)

		return function()
			-- Disconnect hit connection if it exists
			if hitConnection then
				hitConnection:Disconnect()
				hitConnection = nil
			end

			-- Cancel promise if character is destroyed early
			if promise then
				promise:cancel()
			end
		end
	end)
end

--[ Return Service ]--
return GameService
