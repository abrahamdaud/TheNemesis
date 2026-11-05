-- The Nemesis | R15
-- Studio: ReplicatedStorage.TheNemesis.RigBuilder  (ModuleScript)
-- Tubuh blok R15. Pose bind = berdiri, lengan sedikit terbuka.
-- Motor6D.C0 dihitung dari posisi part, jadi sendi tidak berantakan.

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)

local RigBuilder = {}

local function limb(model, name, size, cf, color)
	local p = Util.part({
		name = name,
		size = size,
		cframe = cf,
		color = color,
		material = Enum.Material.SmoothPlastic,
		parent = model,
		castShadow = true,
		canQuery = true,
	})
	return p
end

function RigBuilder.build(options)
	options = options or {}
	local kind = options.kind or "boss"
	local stats = kind == "player" and Config.Player or Config.Boss
	local C = Config.Colors

	local model = Instance.new("Model")
	model.Name = options.name or "TheNemesis"

	local cosmetics = Instance.new("Folder")
	cosmetics.Name = "Cosmetics"
	cosmetics.Parent = model

	local gear = Instance.new("Folder")
	gear.Name = "Gear"
	gear.Parent = model

	local templates = Instance.new("Folder")
	templates.Name = "Templates"
	templates.Parent = model

	-- Angka dalam stud sebelum Scale. HRP di origin.
	-- Kaki bawah kira-kira Y = -3.15, kepala atas kira-kira Y = 3.2.
	local S = Util.scale
	local function p(x, y, z)
		return Vector3.new(x * S, y * S, z * S)
	end
	local function cf(x, y, z, rx, ry, rz)
		return CFrame.new(p(x, y, z)) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
	end

	local hrp = limb(model, "HumanoidRootPart", Util.v3(2, 2, 1), CFrame.new(), C.Coat)
	hrp.Transparency = 1
	hrp.CastShadow = false
	hrp.CanQuery = false
	hrp.RootPriority = 1

	local lower = limb(model, "LowerTorso", Util.v3(2.05, 0.85, 1.15), cf(0, -0.05, 0), C.SkinDeep)
	local upper = limb(model, "UpperTorso", Util.v3(2.35, 1.65, 1.25), cf(0, 1.12, 0), C.Raw)
	local head = limb(model, "Head", Util.v3(1.28, 1.38, 1.32), cf(0, 2.5, 0), C.Skin)

	local function arm(side)
		local sign = side == "Right" and 1 or -1
		local splay = math.rad(11) * sign
		local shoulder = cf(sign * 1.52, 1.22, 0, 0, 0, splay)
		local upperArm = limb(model, side .. "UpperArm", Util.v3(0.98, 1.3, 0.98), shoulder, side == "Right" and C.Flesh or C.SkinDeep)
		local lowerCf = shoulder * CFrame.new(0, -Util.scale * (0.65 + 0.58 - 0.1), 0)
		local lowerArm = limb(model, side .. "LowerArm", Util.v3(0.9, 1.16, 0.9), lowerCf, C.SkinDeep)
		local handCf = lowerCf * CFrame.new(0, -Util.scale * (0.58 + 0.22 - 0.06), 0)
		local hand = limb(model, side .. "Hand", Util.v3(0.8, 0.44, 0.84), handCf, C.Skin)
		return upperArm, lowerArm, hand
	end

	local lua, lla, lh = arm("Left")
	local rua, rla, rh = arm("Right")

	local function leg(side)
		local sign = side == "Right" and 1 or -1
		local hip = cf(sign * 0.52, -0.78, 0)
		local upperLeg = limb(model, side .. "UpperLeg", Util.v3(1.02, 1.42, 1.02), hip, C.Pants)
		local lowerCf = hip * CFrame.new(0, -Util.scale * (0.71 + 0.68 - 0.1), 0)
		local lowerLeg = limb(model, side .. "LowerLeg", Util.v3(0.92, 1.36, 0.92), lowerCf, C.Pants)
		local footCf = lowerCf * CFrame.new(0, -Util.scale * (0.68 + 0.22 - 0.06), -0.12 * S)
		local foot = limb(model, side .. "Foot", Util.v3(1.05, 0.48, 1.6), footCf, C.Boot)
		return upperLeg, lowerLeg, foot
	end

	local lul, lll, lf = leg("Left")
	local rul, rll, rf = leg("Right")

	local motors = {
		Root = Util.motor("Root", hrp, lower),
		Waist = Util.motor("Waist", lower, upper),
		Neck = Util.motor("Neck", upper, head),
		LeftShoulder = Util.motor("LeftShoulder", upper, lua),
		LeftElbow = Util.motor("LeftElbow", lua, lla),
		LeftWrist = Util.motor("LeftWrist", lla, lh),
		RightShoulder = Util.motor("RightShoulder", upper, rua),
		RightElbow = Util.motor("RightElbow", rua, rla),
		RightWrist = Util.motor("RightWrist", rla, rh),
		LeftHip = Util.motor("LeftHip", lower, lul),
		LeftKnee = Util.motor("LeftKnee", lul, lll),
		LeftAnkle = Util.motor("LeftAnkle", lll, lf),
		RightHip = Util.motor("RightHip", lower, rul),
		RightKnee = Util.motor("RightKnee", rul, rll),
		RightAnkle = Util.motor("RightAnkle", rll, rf),
	}

	-- Attachment aksesori standar R15 (supaya nanti bisa ditukar MeshPart UGC).
	Util.attach(head, "HatAttachment", CFrame.new(0, head.Size.Y / 2, 0))
	Util.attach(head, "HairAttachment", CFrame.new(0, head.Size.Y / 2, 0))
	Util.attach(head, "FaceFrontAttachment", CFrame.new(0, 0, -head.Size.Z / 2))
	Util.attach(head, "FaceCenterAttachment", CFrame.new(0, 0, 0))
	Util.attach(upper, "NeckAttachment", CFrame.new(0, upper.Size.Y / 2, 0))
	Util.attach(upper, "BodyFrontAttachment", CFrame.new(0, 0, -upper.Size.Z / 2))
	Util.attach(upper, "BodyBackAttachment", CFrame.new(0, 0.1 * S, upper.Size.Z / 2))
	Util.attach(upper, "LeftCollarAttachment", CFrame.new(-upper.Size.X / 2, upper.Size.Y * 0.35, 0))
	Util.attach(upper, "RightCollarAttachment", CFrame.new(upper.Size.X / 2, upper.Size.Y * 0.35, 0))
	Util.attach(upper, "LeftShoulderAttachment", CFrame.new(-upper.Size.X / 2, upper.Size.Y * 0.25, 0))
	Util.attach(upper, "RightShoulderAttachment", CFrame.new(upper.Size.X / 2, upper.Size.Y * 0.25, 0))
	Util.attach(lower, "WaistCenterAttachment", CFrame.new(0, 0, 0))
	Util.attach(lower, "WaistFrontAttachment", CFrame.new(0, 0, -lower.Size.Z / 2))
	Util.attach(lower, "WaistBackAttachment", CFrame.new(0, 0, lower.Size.Z / 2))
	Util.attach(lh, "LeftGripAttachment", CFrame.new(0, -lh.Size.Y / 2, 0))
	Util.attach(rh, "RightGripAttachment", CFrame.new(0, -rh.Size.Y / 2, 0))
	Util.attach(lf, "LeftFootAttachment", CFrame.new(0, -lf.Size.Y / 2, 0))
	Util.attach(rf, "RightFootAttachment", CFrame.new(0, -rf.Size.Y / 2, 0))

	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.AutomaticScalingEnabled = false
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = true
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.MaxHealth = stats.Health
	humanoid.Health = stats.Health
	humanoid.WalkSpeed = stats.WalkSpeed
	humanoid.JumpPower = stats.JumpPower or 45
	humanoid.UseJumpPower = true
	humanoid.MaxSlopeAngle = 50
	humanoid.NameDisplayDistance = 0
	humanoid.Parent = model

	local animator = Instance.new("Animator")
	animator.Parent = humanoid

	if kind == "player" then
		humanoid.CameraOffset = Vector3.new(0, 0.55 * S, 0)
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.DisplayWhenDamaged
		humanoid.NameDisplayDistance = 100
	end

	model.PrimaryPart = hrp

	local parts = {
		HumanoidRootPart = hrp,
		LowerTorso = lower,
		UpperTorso = upper,
		Head = head,
		LeftUpperArm = lua,
		LeftLowerArm = lla,
		LeftHand = lh,
		RightUpperArm = rua,
		RightLowerArm = rla,
		RightHand = rh,
		LeftUpperLeg = lul,
		LeftLowerLeg = lll,
		LeftFoot = lf,
		RightUpperLeg = rul,
		RightLowerLeg = rll,
		RightFoot = rf,
	}

	return {
		model = model,
		parts = parts,
		motors = motors,
		humanoid = humanoid,
		kind = kind,
		cosmetics = cosmetics,
		gear = gear,
		templates = templates,
	}
end

return RigBuilder
