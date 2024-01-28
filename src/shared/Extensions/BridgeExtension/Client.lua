local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local Client = {}

function Client.ShouldConstruct(component)
	local ownerId = component.Instance:GetAttribute("OwnerId")
	return ownerId == nil or Players.LocalPlayer.UserId == ownerId
end

function Client.Starting(component)
	local inboundMiddleware = component.Middleware and component.Middleware.Inbound
	local outboundMiddleware = component.Middleware and component.Middleware.Outbound
	component.Server = Comm.ClientComm
		.new(component.Instance, component.UsePromises, component.Tag)
		:BuildObject(inboundMiddleware, outboundMiddleware)
end

return Client