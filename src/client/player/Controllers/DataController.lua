--[[
	File: DataController.lua
	Author(s): Rook Fait
	Created: 01/26/2024 @ 01:47:36
	Version: 0.0.1

	Description:
		No description provided.

--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local Knit = require(ReplicatedStorage.Packages.Knit)
local ReplicaService = require(ReplicatedStorage.Packages.ReplicaService)

--[ Root ]--
local DataController = Knit.CreateController({
	Name = "DataController",
})

--[ Exports & Types & Defaults ]--
type Path = string | { string }
type Dictionary = { [string]: any }
type Profile = {
	Data: Dictionary,
}

--[ Variables ]--
local DataReplica

--[ Public Functions ]--

--[[
	Garauntees the players data replica. As such, it's safe to do operations such as ``self:GetReplica().Data``.
]]
function DataController:GetReplica(): Profile
	while not DataReplica do
		task.wait()
	end

	return DataReplica
end

--[[
	Returns the local players data.

	@return Dictionary
]]
function DataController:GetData(): Dictionary
	return self:GetReplica().Data
end

--[[
	Returns data for the given key.

	@param key string The data key to get.
	@return any
]]
function DataController:GetValue(key: string): any
	return self:GetData()[key]
end

--[[
	Registers callback when the value at the specified key changes.

	@param key string The data key to listen to changes for.
	@param callback function The callback to be called whenever the value changes.
]]
function DataController:OnValueChanged(key: string, callback: (newValue: any, oldValue: any) -> ())
	-- Defer callback with initial value. Nests callback within task.defer to prevent desync.
	task.defer(function()
		callback(self:GetValue(key))
	end)

	-- Setup replica listener
	return self:GetReplica():ListenToChange(key, callback)
end

--[ Initializers ]--
function DataController:KnitStart()
	ReplicaService.ReplicaOfClassCreated("PlayerData", function(replica)
		DataReplica = replica
	end)

	ReplicaService.RequestData()
end

--[ Return Controller ]--
return DataController
