-- The Nemesis | R15
-- Studio: ReplicatedStorage.TheNemesis.Config  (ModuleScript)

local Config = {}

Config.Tag = "TheNemesis"
Config.Scale = 1

-- Boss muncul sendiri saat Play, plus pad morph.
Config.SpawnBoss = true
Config.SpawnPad = true

Config.Colors = {
	Skin = Color3.fromRGB(198, 156, 138),
	SkinDeep = Color3.fromRGB(154, 102, 94),
	Raw = Color3.fromRGB(176, 62, 58),
	Flesh = Color3.fromRGB(146, 40, 46),
	FleshDeep = Color3.fromRGB(108, 26, 34),
	FleshHi = Color3.fromRGB(194, 86, 82),
	Tentacle = Color3.fromRGB(138, 30, 42),
	TentacleDark = Color3.fromRGB(92, 18, 30),
	Horn = Color3.fromRGB(118, 22, 32),
	Pod = Color3.fromRGB(104, 118, 74),
	PodDark = Color3.fromRGB(58, 70, 46),
	Tube = Color3.fromRGB(126, 140, 82),
	Coat = Color3.fromRGB(16, 16, 18),
	CoatEdge = Color3.fromRGB(28, 28, 32),
	Pants = Color3.fromRGB(12, 12, 14),
	Boot = Color3.fromRGB(10, 10, 12),
	Metal = Color3.fromRGB(78, 80, 88),
	MetalDark = Color3.fromRGB(24, 24, 28),
	Thread = Color3.fromRGB(14, 12, 12),
	Wound = Color3.fromRGB(120, 36, 42),
	Teeth = Color3.fromRGB(236, 226, 200),
	Eye = Color3.fromRGB(120, 6, 10),
	EyeGlow = Color3.fromRGB(255, 40, 36),
	Mouth = Color3.fromRGB(36, 6, 10),
	Wood = Color3.fromRGB(96, 66, 40),
	Olive = Color3.fromRGB(82, 90, 54),
	Rust = Color3.fromRGB(128, 78, 46),
	Cloth = Color3.fromRGB(146, 28, 36),
	Smoke = Color3.fromRGB(70, 16, 18),
}

-- Kalau rahang menutup saat raung, balik jadi -1.
Config.JawSign = 1

Config.Boss = {
	Health = 900,
	WalkSpeed = 10,
	ChaseSpeed = 15.5,
	Aggro = 80,
	Leash = 160,
	MeleeRange = 8,
	RocketMin = 11,
	RocketMax = 52,
	TouchDamage = 12,
	Title = "THE NEMESIS",
}

Config.Player = {
	Health = 320,
	WalkSpeed = 15,
	JumpPower = 50,
}

Config.Combat = {
	MeleeDamage = 28,
	MeleeKnock = 36,
	MeleeRange = 7.2,
	SlamTime = 0.95,
	SlamHit = 0.42,
	RocketDamage = 42,
	RocketRadius = 8,
	RocketKnock = 48,
	RocketSpeed = 130,
	RocketLife = 2.4,
	RocketCooldown = 1.35,
	RoarTime = 1.7,
	RoarCooldown = 8,
	RoarDamage = 10,
	RoarRadius = 16,
	RoarKnock = 52,
	MeleeCooldown = 1.15,
}

Config.Sounds = {
	Roar = "rbxasset://sounds/uuhhh.mp3",
	Swing = "rbxasset://sounds/swordslash.wav",
	Hit = "rbxasset://sounds/hit.wav",
	Rocket = "rbxasset://sounds/Rocket shot.wav",
	Boom = "rbxasset://sounds/collide.wav",
	Stomp = "rbxasset://sounds/collide.wav",
	Growl = "rbxasset://sounds/uuhhh.mp3",
}

-- Tentakel diartkan agar menyerupai model sheet (punggung + bahu kanan + tanduk kiri).
-- offset belum diskalakan. curl per segmen dalam radian (sumbu X lokal).
Config.Tentacles = {
	{
		name = "TentBack1",
		parent = "UpperTorso",
		offset = CFrame.new(0.05, 0.55, 0.58) * CFrame.Angles(math.rad(-62), math.rad(18), math.rad(8)),
		segments = 8,
		thickness = 0.36,
		length = 0.48,
		sway = 0.34,
		speed = 1.25,
		phase = 0.1,
		color = "Tentacle",
		tip = "TentacleDark",
		curl = { 0.42, 0.38, 0.28, 0.12, -0.08, -0.22, -0.28, -0.18 },
	},
	{
		name = "TentBack2",
		parent = "UpperTorso",
		offset = CFrame.new(-0.32, 0.48, 0.56) * CFrame.Angles(math.rad(-70), math.rad(-28), math.rad(-12)),
		segments = 7,
		thickness = 0.3,
		length = 0.5,
		sway = 0.4,
		speed = 1.45,
		phase = 1.1,
		color = "Tentacle",
		tip = "FleshDeep",
		curl = { 0.5, 0.36, 0.22, 0.05, -0.18, -0.3, -0.16 },
	},
	{
		name = "TentBack3",
		parent = "UpperTorso",
		offset = CFrame.new(0.42, 0.42, 0.5) * CFrame.Angles(math.rad(-48), math.rad(36), math.rad(16)),
		segments = 7,
		thickness = 0.32,
		length = 0.46,
		sway = 0.36,
		speed = 1.15,
		phase = 2.2,
		color = "Flesh",
		tip = "TentacleDark",
		curl = { 0.3, 0.34, 0.4, 0.22, 0.05, -0.12, -0.2 },
	},
	{
		name = "TentBack4",
		parent = "UpperTorso",
		offset = CFrame.new(-0.08, 0.25, 0.6) * CFrame.Angles(math.rad(-80), math.rad(8), math.rad(-6)),
		segments = 6,
		thickness = 0.26,
		length = 0.44,
		sway = 0.42,
		speed = 1.6,
		phase = 0.6,
		color = "TentacleDark",
		tip = "FleshHi",
		curl = { 0.55, 0.4, 0.15, -0.1, -0.28, -0.2 },
	},
	{
		name = "TentShoulder",
		parent = "RightUpperArm",
		offset = CFrame.new(0.25, 0.35, -0.05) * CFrame.Angles(math.rad(-20), math.rad(10), math.rad(-30)),
		segments = 6,
		thickness = 0.28,
		length = 0.4,
		sway = 0.3,
		speed = 1.35,
		phase = 0.4,
		color = "FleshHi",
		tip = "Tentacle",
		curl = { -0.2, -0.35, -0.4, -0.25, -0.1, 0.05 },
	},
	{
		name = "TentHornL",
		parent = "UpperTorso",
		offset = CFrame.new(-1.15, 0.72, -0.05) * CFrame.Angles(math.rad(20), math.rad(-20), math.rad(55)),
		segments = 5,
		thickness = 0.22,
		length = 0.42,
		sway = 0.1,
		speed = 0.8,
		phase = 2.4,
		color = "Horn",
		tip = "TentacleDark",
		curl = { -0.15, -0.45, -0.55, -0.35, -0.15 },
	},
}

return Config
