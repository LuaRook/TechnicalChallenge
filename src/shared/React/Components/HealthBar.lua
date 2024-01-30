--[[
	File: HealthBar.lua
	Author(s): Rook Fait
	Created: 01/30/2024 @ 00:05:58
	Version: 0.0.1

	Description:
		No description provided.

--]]
--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local React = require(ReplicatedStorage.Packages.React)

--[ React Components ]--
local Container = require(script.Parent.Essential.Container)
local Label = require(script.Parent.Essential.Label)

--[ Exports & Types & Defaults ]--
export type HealthbarProps = {
	Humanoid: Humanoid,

	StudsOffset: Vector3?,
	Size: UDim2?,
}

--[ Constants ]--
local BAR_SIZE: UDim2 = UDim2.fromScale(4, 0.25)
local STUDS_OFFSET: Vector3 = Vector3.yAxis * 3

--[ Local Functions ]--

local function GetHealthBarColor(health: number, maxHealth: number): Color3
	return Color3.fromHSV(((health / maxHealth) * 120) / 359, 1, 1)
end

--[ Return Component ]--
return function(props: HealthbarProps)
	local humanoid: Humanoid = props.Humanoid
	local maxHealth: number = humanoid.MaxHealth
	local health: number, setHealth: (newHealth: number) -> () = React.useState(maxHealth)

	-- Update health
	React.useEffect(function()
		local healthChangedConn: RBXScriptConnection = humanoid.HealthChanged:Connect(function()
			setHealth(humanoid.Health)
		end)

		-- Cleanup functions
		return function()
			if healthChangedConn then
				healthChangedConn:Disconnect()
				healthChangedConn = nil
			end
		end
	end)

	return React.createElement(
		"BillboardGui",
		{
			StudsOffset = props.StudsOffset or STUDS_OFFSET,
			Size = props.Size or BAR_SIZE,
		},
		React.createElement(Container, {
			BackgroundTransparency = 0.9,
		}, {
			HealthLabel = React.createElement(Label, {
				Text = `{health} / {maxHealth}`,

				Size = UDim2.fromScale(1, 1),
			}),

			Fill = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(health / maxHealth, 1),

				BackgroundColor3 = GetHealthBarColor(health, maxHealth),
				BorderSizePixel = 0,
				ZIndex = -1,
			}),
		})
	)
end
