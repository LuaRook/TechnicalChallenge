--[[
	File: GameService.lua
	Author(s): Rook Fait
	Created: 01/28/2024 @ 20:13:33
	Version: 0.0.1

	Description:
		Handles gameplay logic.
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)

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
}

--[ Object References ]--

local Assets: Folder = ReplicatedStorage.Assets
local EnemyAssets: Folder = Assets.Enemies
local EnemyFolder: Folder = workspace.Enemies
local FriendlyFolder: Folder = workspace.Friendlies

local LevelConfigs: Folder = script:WaitForChild("Levels")

--[ Shorthands ]--

--[ Local Functions ]--

--[ Public Functions ]--

--[[
	Spawns enemy of the specified type at the specified origin.
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
	Starts game 
]]
function GameService:StartGame(levelName: string)
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
end

--[[
	Ends game by removing both enemies and spawned friendlies.
]]
function GameService:EndGame()
	EnemyFolder:ClearAllChildren()
	FriendlyFolder:ClearAllChildren()
end

--[ Initializers ]--
function GameService:KnitStart()
	self:StartGame("Basic")
end

--[ Return Service ]--
return GameService
