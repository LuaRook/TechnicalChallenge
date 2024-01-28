--[ Await Game Loaded ]--

if not game:IsLoaded() then
	game.Loaded:Wait()
end

--[ Roblox Services ]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)

--[ Object References ]--

local Controllers: Folder = script.Parent.Controllers
local Components: Folder = script.Parent.Components

--[ Boostrapper ]--

Loader.LoadDescendants(Controllers, Loader.MatchesName("Controller$"))
Knit.Start():andThen(function()
	-- Load components once Knit has started
	Loader.LoadChildren(Components)
end)
