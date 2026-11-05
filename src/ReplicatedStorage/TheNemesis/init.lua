-- The Nemesis | R15
-- Studio: ReplicatedStorage.TheNemesis  (ModuleScript)
-- Anak-anaknya: Config, Util, RigBuilder, Visuals, Gear (semua ModuleScript)

local CollectionService = game:GetService("CollectionService")

local Config = require(script.Config)
local Util = require(script.Util)
local RigBuilder = require(script.RigBuilder)
local Visuals = require(script.Visuals)
local Gear = require(script.Gear)

local Nemesis = {}
Nemesis.Config = Config

function Nemesis.create(options)
	options = options or {}
	local ctx = RigBuilder.build(options)
	Visuals.decorate(ctx)
	Gear.attach(ctx)

	local model = ctx.model
	local hrp = ctx.parts.HumanoidRootPart
	local lowest = Util.lowestY(ctx.soles or {})
	if lowest == math.huge then
		local foot = ctx.parts.LeftFoot
		lowest = foot.Position.Y - foot.Size.Y / 2
	end
	local hipHeight = math.max(1, (hrp.Position.Y - hrp.Size.Y / 2) - lowest) + 0.14 * Util.scale
	ctx.humanoid.HipHeight = hipHeight
	model:SetAttribute("HipStand", hipHeight + hrp.Size.Y / 2)
	model:SetAttribute("IsNemesis", true)
	model:SetAttribute("Kind", ctx.kind)
	model:SetAttribute("Boss", ctx.kind == "boss")
	CollectionService:AddTag(model, Config.Tag)
	return model
end

function Nemesis.unlock(model, serverOwn)
	local templates = model:FindFirstChild("Templates")
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			if templates and d:IsDescendantOf(templates) then
				d.Anchored = true
				d.CanCollide = false
			else
				d.Anchored = false
			end
		end
	end

	local hrp = model:FindFirstChild("HumanoidRootPart")
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	if hum then
		hum.AutomaticScalingEnabled = false
		if hrp then
			hum.HipHeight = (model:GetAttribute("HipStand") or 3) - hrp.Size.Y / 2
		end
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end
	if serverOwn and hrp then
		task.defer(function()
			pcall(function()
				if hrp.Parent and hrp:CanSetNetworkOwnership() then
					hrp:SetNetworkOwner(nil)
				end
			end)
		end)
	end
end

function Nemesis.setGunDrawn(model, drawn)
	Gear.setDrawn(model, drawn)
end

return Nemesis
