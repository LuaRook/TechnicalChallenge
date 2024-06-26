--[ Roblox Services ]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--

local Knit = require(ReplicatedStorage.Packages.Knit)
local Loader = require(ReplicatedStorage.Packages.Loader)

--[ Object References ]--

local Services: Folder = script.Parent.Services
local Components: Folder = script.Parent.Components

--[ Boostrapper ]--

Loader.LoadDescendants(Services, Loader.MatchesName("Service$"))
Knit.Start():andThen(function()
	-- Load components once Knit has started
	Loader.LoadChildren(Components)
end)
