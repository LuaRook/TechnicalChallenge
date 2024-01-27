local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local TroveExtension = {}

function TroveExtension.Constructing(component)
	component._trove = Trove.new()
end

function TroveExtension.Stopping(component)
	component._trove:Clean()
end

return TroveExtension