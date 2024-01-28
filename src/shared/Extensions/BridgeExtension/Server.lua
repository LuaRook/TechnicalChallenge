local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Comm = require(ReplicatedStorage.Packages.Comm)

local SIGNAL_MARKER = newproxy(true)
getmetatable(SIGNAL_MARKER).__tostring = function()
	return "SIGNAL_MARKER"
end

local PROPERTY_MARKER = newproxy(true)
getmetatable(PROPERTY_MARKER).__tostring = function()
	return "PROPERTY_MARKER"
end

local Server = {}

function Server.CreateSignal()
	return SIGNAL_MARKER
end

function Server.CreateProperty(v)
	return { PROPERTY_MARKER, v }
end

function Server.Starting(component)
	if not component.Client then
		return
	end
	local outboundMiddleware = component.Middleware and component.Middleware.Outbound
	local inboundMiddleware = component.Middleware and component.Middleware.Inbound

	component.Client = TableUtil.Copy(component.Client)
	component._comm = Comm.ServerComm.new(component.Instance, component.Tag)
	for k, v in pairs(component.Client) do
		if type(v) == "function" then
			component._comm:BindFunction(k, function(player, ...)
				if component.Player ~= nil and player ~= component.Player then
					return
				end
				return component.Client[k](component.Client, player, ...)
			end)
		elseif tostring(v) == "SIGNAL_MARKER" then -- Allow Knit.CreateSignal()
			component.Client[k] = component._comm:CreateSignal(k, inboundMiddleware, outboundMiddleware)
		elseif type(v) == "table" and tostring(v[1]) == "PROPERTY_MARKER" then -- Same thing as Knit
			component.Client[k] = component._comm:CreateProperty(k, v[2], inboundMiddleware, outboundMiddleware)
		end
	end
	component.Client.Server = component
end

function Server.Stopped(component)
	if component._comm then
		component._comm:Destroy()
	end
end

return Server