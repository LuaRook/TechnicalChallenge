local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local TroveExtension = {}

-- Create trove when component is constructing.
function TroveExtension.Constructing(component)
	component._trove = Trove.new()
end

-- Clean trove when component is stopping.
function TroveExtension.Stopping(component)
	-- Destroy is shorthand for Clean, so call Clean directly.
	component._trove:Clean()
end

return TroveExtension