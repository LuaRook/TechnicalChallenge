local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()
local Client = require(script.Client)
local Server = require(script.Server)

return if IS_SERVER then Server else Client