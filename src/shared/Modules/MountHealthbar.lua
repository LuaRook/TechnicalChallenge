--[[
	File: MountHealthbar.lua
	Author(s): Rook Fait
	Created: 01/30/2024 @ 01:37:07
	Version: 0.0.1

	Description:
		Handles mounting the HealthBar react component to the specified adornee. 
--]]

--[ Roblox Services ]--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[ Dependencies ]--
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local React = require(ReplicatedStorage.Packages.React)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

--[ Roact Components ]--
local HealthBar = require(ReplicatedStorage.Shared.React.Components.HealthBar)

--[[
	Handles mounting the HealthBar react component to the specified adornee.

	@param adornee PVInstance The part to mount the healthbar to.
	@param humanoid Humanoid The humanoid that the health bar should rely upon.
	@params props HealthBar.HealthbarProps? Optional properties for the healthbar, such as size or stud offset.
]]
return function(adornee: PVInstance, humanoid: Humanoid, props: HealthBar.HealthbarProps?)
	-- Ensure arguments are correct
	if not adornee then
		return warn(`Expected Instance for adornee; got type "{typeof(adornee)}" instead.`)
	end
	if not humanoid or not humanoid:IsA("Humanoid") then
		return warn(`Expected Humanoid for humanoid; got type "{typeof(humanoid)}" instead.`)
	end

	-- Remove humanoid from props
	if props and props.Humanoid then
		props.Humanoid = nil
	end

	-- Create root and mount healthbar
	local healthRoot: ReactRoblox.RootType = ReactRoblox.createRoot(Instance.new("Folder"))
	healthRoot:render(ReactRoblox.createPortal(
		React.createElement(
			HealthBar,
			TableUtil.Reconcile(props or {}, {
				Humanoid = humanoid,
			})
		),
		adornee
	))

	-- As HumanoidDestroyBehavior is enabled (and will soon be on by default), we can watch
	-- for humanoid destruction so we can unmount our root.
	humanoid.Destroying:Once(function()
		if healthRoot then
			healthRoot:unmount()
		end
	end)
end
