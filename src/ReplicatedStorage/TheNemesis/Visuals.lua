-- The Nemesis | R15
-- Studio: ReplicatedStorage.TheNemesis.Visuals  (ModuleScript)
-- Detail visual dari model sheet: kepala jahitan, coat compang, mutasi bahu kanan,
-- tentakel punggung, tanduk kiri, boots, canister hijau di dada.

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)

local Visuals = {}

local function decorate(ctx)
	local model = ctx.model
	local P = ctx.parts
	local folder = ctx.cosmetics
	local C = Config.Colors
	local S = Util.scale
	local soles = {}

	local function bit(props)
		props.parent = props.parent or folder
		props.massless = true
		props.canQuery = false
		if props.castShadow == nil then
			props.castShadow = false
		end
		local p = Util.part(props)
		return p
	end

	local function stick(host, props)
		local p = bit(props)
		Util.weld(host, p)
		return p
	end

	local function buckle(host, cf, width)
		width = width or 0.34
		local frame = stick(host, {
			name = "Buckle",
			size = Util.v3(width, 0.28, 0.08),
			cframe = cf,
			color = C.Metal,
			material = Enum.Material.Metal,
			reflectance = 0.35,
		})
		stick(host, {
			name = "BucklePin",
			size = Util.v3(0.06, 0.18, 0.1),
			cframe = cf * CFrame.new(0, 0, -0.02 * S),
			color = C.MetalDark,
			material = Enum.Material.Metal,
		})
		return frame
	end

	local function strap(host, cf, size)
		return stick(host, {
			name = "Strap",
			size = size,
			cframe = cf,
			color = C.Coat,
			material = Enum.Material.SmoothPlastic,
		})
	end

	-- Jahitan: batang luka + benang silang.
	local function stitches(host, baseCf, count, span, threadLen)
		stick(host, {
			name = "Wound",
			size = Util.v3(0.07, span, 0.05),
			cframe = baseCf,
			color = C.Wound,
			reflectance = 0.08,
		})
		for i = 0, count - 1 do
			local t = (i / math.max(1, count - 1) - 0.5) * span
			stick(host, {
				name = "Thread",
				size = Util.v3(threadLen or 0.22, 0.035, 0.045),
				cframe = baseCf * CFrame.new(0, t * S, -0.03 * S) * CFrame.Angles(0, 0, math.rad(i % 2 == 0 and 28 or -28)),
				color = C.Thread,
			})
		end
	end

	----------------------------------------------------------------
	-- KEPALA
	----------------------------------------------------------------
	local head = P.Head
	stitches(head, head.CFrame * CFrame.new(0, 0.18 * S, -0.58 * S) * CFrame.Angles(math.rad(-18), 0, math.rad(3)), 7, 1.15, 0.26)
	stitches(head, head.CFrame * CFrame.new(0.28 * S, 0.22 * S, -0.42 * S) * CFrame.Angles(math.rad(-10), math.rad(18), math.rad(70)), 3, 0.42, 0.16)

	-- Soket mata cekung + pupil merah kecil.
	for _, side in { -1, 1 } do
		local socketCf = head.CFrame * CFrame.new(side * 0.26 * S, 0.06 * S, -0.6 * S)
		stick(head, {
			name = "Socket",
			size = Util.v3(0.28, 0.16, 0.08),
			cframe = socketCf,
			color = C.Mouth,
		})
		local pupil = stick(head, {
			name = side < 0 and "EyePupilL" or "EyePupilR",
			size = Util.v3(0.1, 0.07, 0.05),
			cframe = socketCf * CFrame.new(0, -0.01 * S, -0.04 * S),
			color = C.EyeGlow,
			material = Enum.Material.Neon,
		})
		local light = Instance.new("PointLight")
		light.Color = C.Eye
		light.Brightness = 0.45
		light.Range = 5
		light.Shadows = false
		light.Parent = pupil

		-- Alis marah.
		stick(head, {
			name = "Brow",
			size = Util.v3(0.32, 0.07, 0.08),
			cframe = head.CFrame * CFrame.new(side * 0.28 * S, 0.2 * S, -0.58 * S) * CFrame.Angles(0, 0, math.rad(-18 * side)),
			color = C.SkinDeep,
		})
	end

	-- Mulut terbuka. Rahang bisa bergerak.
	local mouth = stick(head, {
		name = "Mouth",
		size = Util.v3(0.62, 0.28, 0.22),
		cframe = head.CFrame * CFrame.new(0, -0.28 * S, -0.5 * S),
		color = C.Mouth,
	})

	local jawCf = head.CFrame * CFrame.new(0, -0.42 * S, -0.42 * S) * CFrame.Angles(math.rad(18), 0, 0)
	local jaw = bit({
		name = "Jaw",
		size = Util.v3(0.66, 0.22, 0.42),
		cframe = jawCf,
		color = C.Skin,
		castShadow = true,
	})
	Util.motor("Jaw", head, jaw)

	local function toothRow(host, base, count, lengths, flip)
		for i = 1, count do
			local x = ((i - 0.5) / count - 0.5) * 0.5
			local len = lengths[((i - 1) % #lengths) + 1]
			local y = (flip and 1 or -1) * (0.02 + len / 2)
			stick(host, {
				name = "Tooth",
				size = Util.v3(0.055, len, 0.06),
				cframe = base * CFrame.new(x * S, y * S, -0.08 * S) * CFrame.Angles(math.rad(flip and -8 or 8), 0, 0),
				color = (len > 0.2) and C.Teeth or Color3.fromRGB(220, 206, 176),
				material = Enum.Material.SmoothPlastic,
				reflectance = 0.12,
			})
		end
	end

	toothRow(head, head.CFrame * CFrame.new(0, -0.16 * S, -0.52 * S), 8, { 0.12, 0.18, 0.16, 0.24, 0.24, 0.16, 0.18, 0.12 }, false)
	toothRow(jaw, jaw.CFrame, 7, { 0.1, 0.16, 0.2, 0.14, 0.2, 0.16, 0.1 }, true)

	-- Gusi.
	stick(head, {
		name = "Gums",
		size = Util.v3(0.5, 0.08, 0.1),
		cframe = head.CFrame * CFrame.new(0, -0.14 * S, -0.56 * S),
		color = C.Raw,
	})

	-- Leher daging terbuka di bawah rahang.
	stick(P.UpperTorso, {
		name = "NeckFlesh",
		size = Util.v3(0.9, 0.55, 0.9),
		cframe = P.UpperTorso.CFrame * CFrame.new(0, 0.72 * S, -0.05 * S),
		color = C.Raw,
		reflectance = 0.06,
		castShadow = true,
	})

	local breathHost = Util.attach(head, "Breath", CFrame.new(0, -0.32 * S, -0.72 * S))
	local breath = Instance.new("ParticleEmitter")
	breath.Name = "Breath"
	breath.Texture = "rbxasset://textures/particles/smoke_main.dds"
	breath.Rate = 3
	breath.Lifetime = NumberRange.new(0.35, 0.7)
	breath.Speed = NumberRange.new(0.3, 0.8)
	breath.SpreadAngle = Vector2.new(12, 12)
	breath.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(1, 0.45),
	})
	breath.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})
	breath.Color = ColorSequence.new(C.Smoke)
	breath.LightEmission = 0.15
	breath.Parent = breathHost

	----------------------------------------------------------------
	-- COAT, CELANA, HARNESS
	----------------------------------------------------------------
	local upper = P.UpperTorso
	local lower = P.LowerTorso

	-- Dada terbuka (daging) sebelum coat menutupi sisi.
	stick(upper, {
		name = "ChestFlesh",
		size = Util.v3(1.15, 0.7, 0.35),
		cframe = upper.CFrame * CFrame.new(0.05 * S, 0.28 * S, -0.58 * S),
		color = C.Raw,
		reflectance = 0.05,
		castShadow = true,
	})

	-- Canister zaitun di dada, seperti di model sheet.
	local canCf = upper.CFrame * CFrame.new(0.28 * S, -0.05 * S, -0.82 * S) * CFrame.Angles(0, 0, math.rad(18))
	local canister = stick(upper, {
		name = "Canister",
		size = Util.v3(0.78, 0.36, 0.36),
		cframe = canCf,
		color = C.Pod,
		material = Enum.Material.SmoothPlastic,
		reflectance = 0.08,
		castShadow = true,
		shape = Enum.PartType.Cylinder,
	})
	stick(upper, {
		name = "CanBand",
		size = Util.v3(0.12, 0.4, 0.4),
		cframe = canCf * CFrame.new(-0.18 * S, 0, 0),
		color = C.MetalDark,
		material = Enum.Material.Metal,
		shape = Enum.PartType.Cylinder,
	})
	stick(upper, {
		name = "CanCore",
		size = Util.v3(0.2, 0.22, 0.22),
		cframe = canCf * CFrame.new(0.22 * S, 0, 0),
		color = C.PodDark,
		shape = Enum.PartType.Ball,
	})

	-- Kerah tinggi, terbuka di depan.
	for _, side in { -1, 1 } do
		stick(upper, {
			name = "Collar",
			size = Util.v3(0.7, 0.7, 0.16),
			cframe = upper.CFrame * CFrame.new(side * 0.48 * S, 0.72 * S, -0.15 * S) * CFrame.Angles(math.rad(-12), math.rad(18 * side), math.rad(8 * side)),
			color = C.Coat,
			castShadow = true,
		})
	end
	stick(upper, {
		name = "CollarBack",
		size = Util.v3(1.5, 0.62, 0.16),
		cframe = upper.CFrame * CFrame.new(0, 0.78 * S, 0.52 * S) * CFrame.Angles(math.rad(14), 0, 0),
		color = C.Coat,
		castShadow = true,
	})

	-- Panel coat bergoyang. Engsel di pinggang, kain turun.
	local function coatPanel(name, jointLocal, size, tiltX, tiltZ)
		local joint = lower.CFrame * Util.scf(jointLocal)
		local panelCf = joint * CFrame.new(0, -size.Y / 2 + 0.05 * S, 0) * CFrame.Angles(tiltX or 0, 0, tiltZ or 0)
		local panel = bit({
			name = name,
			size = size,
			cframe = panelCf,
			color = C.Coat,
			castShadow = true,
			reflectance = 0.04,
		})
		local motor = Util.motor(name, lower, panel)
		motor:SetAttribute("Kind", "Coat")
		motor:SetAttribute("Sway", 0.07)
		motor:SetAttribute("Phase", string.len(name) * 0.4)

		-- Hem compang-camping.
		local notches = math.max(2, math.floor(size.X / (0.45 * S)))
		for i = 1, notches do
			local x = (i - (notches + 1) / 2) * (size.X / notches)
			local drop = (0.28 + (i % 3) * 0.16) * S
			local jag = bit({
				name = "Jag",
				size = Vector3.new(size.X / notches * 0.92, drop, size.Z * 0.92),
				cframe = panel.CFrame * CFrame.new(x, -size.Y / 2 - drop / 2 + 0.04 * S, 0) * CFrame.Angles(0, 0, math.rad((i % 2 == 0 and 8 or -8))),
				color = C.Coat,
				castShadow = true,
			})
			Util.weld(panel, jag)
		end
		return panel
	end

	coatPanel("CoatFrontL", CFrame.new(-0.48, -0.15, -0.62), Util.v3(0.85, 1.55, 0.1), math.rad(6), math.rad(4))
	coatPanel("CoatFrontR", CFrame.new(0.5, -0.15, -0.62), Util.v3(0.85, 1.55, 0.1), math.rad(6), math.rad(-4))
	coatPanel("CoatBack", CFrame.new(0, -0.2, 0.66), Util.v3(2.15, 1.85, 0.1), math.rad(-4), 0)
	coatPanel("CoatSideL", CFrame.new(-1.12, -0.15, 0.02), Util.v3(0.1, 1.6, 1.05), 0, math.rad(2))
	coatPanel("CoatSideR", CFrame.new(1.12, -0.15, 0.02), Util.v3(0.1, 1.55, 1.05), 0, math.rad(-2))

	-- Jahitan tengah punggung dan depan.
	stitches(upper, upper.CFrame * CFrame.new(0, -0.1 * S, 0.64 * S), 8, 1.3, 0.2)
	stitches(lower, lower.CFrame * CFrame.new(0, -0.15 * S, -0.6 * S) * CFrame.Angles(0, math.rad(180), 0), 5, 0.7, 0.18)

	-- Sabuk pinggang + gesper (aksesoris callout).
	stick(lower, {
		name = "Belt",
		size = Util.v3(2.25, 0.22, 1.35),
		cframe = lower.CFrame * CFrame.new(0, 0.05 * S, 0),
		color = C.CoatEdge,
		castShadow = true,
	})
	buckle(lower, lower.CFrame * CFrame.new(0, 0.05 * S, -0.7 * S), 0.42)

	-- Harness dada.
	strap(upper, upper.CFrame * CFrame.new(0, 0.15 * S, -0.66 * S), Util.v3(1.7, 0.12, 0.06))
	strap(upper, upper.CFrame * CFrame.new(0.15 * S, 0.15 * S, -0.64 * S) * CFrame.Angles(0, 0, math.rad(42)), Util.v3(1.5, 0.1, 0.05))
	strap(upper, upper.CFrame * CFrame.new(-0.15 * S, 0.05 * S, -0.64 * S) * CFrame.Angles(0, 0, math.rad(-38)), Util.v3(1.35, 0.1, 0.05))
	buckle(upper, upper.CFrame * CFrame.new(-0.35 * S, -0.15 * S, -0.7 * S), 0.3)
	buckle(upper, upper.CFrame * CFrame.new(0.55 * S, 0.25 * S, -0.7 * S), 0.28)

	-- Tali diagonal pundak kiri ke pinggang (aksesoris strap).
	strap(upper, upper.CFrame * CFrame.new(-0.15 * S, 0.1 * S, -0.5 * S) * CFrame.Angles(0, math.rad(20), math.rad(48)), Util.v3(2.1, 0.12, 0.05))

	----------------------------------------------------------------
	-- LENGAN: sleeve kiri utuh, kanan mutasi, kedua lengan ada strap
	----------------------------------------------------------------
	local function gauntlet(lowerArm, hand, sideSign)
		stick(lowerArm, {
			name = "Gauntlet",
			size = lowerArm.Size * Vector3.new(1.12, 0.92, 1.12),
			cframe = lowerArm.CFrame,
			color = C.Coat,
			castShadow = true,
		})
		strap(lowerArm, lowerArm.CFrame * CFrame.new(0, 0.28 * S, 0), Util.v3(1.05, 0.12, 1.05))
		strap(lowerArm, lowerArm.CFrame * CFrame.new(0, -0.22 * S, 0), Util.v3(1.02, 0.14, 1.02))
		buckle(lowerArm, lowerArm.CFrame * CFrame.new(sideSign * 0.42 * S, 0.28 * S, -0.28 * S), 0.26)
		buckle(lowerArm, lowerArm.CFrame * CFrame.new(sideSign * 0.4 * S, -0.22 * S, -0.28 * S), 0.26)

		-- Sarung tangan tanpa jari.
		stick(hand, {
			name = "Glove",
			size = Util.v3(0.86, 0.28, 0.9),
			cframe = hand.CFrame * CFrame.new(0, 0.06 * S, 0),
			color = C.Coat,
			castShadow = true,
		})

		-- Empat jari + ibu jari, ujung daging.
		local fingerLen = { 0.2, 0.26, 0.24, 0.18 }
		for i = 1, 4 do
			local x = (i - 2.5) * 0.16
			stick(hand, {
				name = "Finger",
				size = Util.v3(0.13, fingerLen[i], 0.14),
				cframe = hand.CFrame * CFrame.new(x * S, -(0.22 + fingerLen[i] / 2) * S, -0.02 * S),
				color = C.Skin,
				castShadow = true,
			})
		end
		stick(hand, {
			name = "Thumb",
			size = Util.v3(0.14, 0.2, 0.14),
			cframe = hand.CFrame * CFrame.new(sideSign * 0.32 * S, -0.12 * S, -0.12 * S) * CFrame.Angles(math.rad(20), 0, math.rad(-35 * sideSign)),
			color = C.Skin,
			castShadow = true,
		})
	end

	-- Lengan kiri: sleeve penuh.
	stick(P.LeftUpperArm, {
		name = "SleeveL",
		size = P.LeftUpperArm.Size * Vector3.new(1.14, 0.96, 1.14),
		cframe = P.LeftUpperArm.CFrame,
		color = C.Coat,
		castShadow = true,
	})
	strap(P.LeftUpperArm, P.LeftUpperArm.CFrame * CFrame.new(0, 0.2 * S, 0), Util.v3(1.12, 0.12, 1.12))
	buckle(P.LeftUpperArm, P.LeftUpperArm.CFrame * CFrame.new(-0.48 * S, 0.2 * S, -0.2 * S), 0.26)
	gauntlet(P.LeftLowerArm, P.LeftHand, -1)

	-- Lengan kanan bawah tetap berstrap (mutasi hanya di bahu/lengan atas).
	gauntlet(P.RightLowerArm, P.RightHand, 1)
	strap(P.RightLowerArm, P.RightLowerArm.CFrame * CFrame.new(0, 0.42 * S, 0), Util.v3(1.08, 0.16, 1.08))

	----------------------------------------------------------------
	-- MUTASI BAHU KANAN
	----------------------------------------------------------------
	local arm = P.RightUpperArm
	local blobs = {
		{ Vector3.new(0.15, 0.32, 0.05), Vector3.new(1.2, 1.05, 1.1), "Flesh" },
		{ Vector3.new(0.42, 0.12, -0.12), Vector3.new(0.85, 0.72, 0.78), "FleshHi" },
		{ Vector3.new(0.28, -0.05, 0.32), Vector3.new(0.7, 0.62, 0.66), "FleshDeep" },
		{ Vector3.new(-0.05, 0.2, -0.28), Vector3.new(0.62, 0.55, 0.58), "Raw" },
		{ Vector3.new(0.55, 0.38, 0.18), Vector3.new(0.48, 0.4, 0.42), "Flesh" },
		{ Vector3.new(0.1, 0.48, 0.2), Vector3.new(0.4, 0.36, 0.5), "FleshDeep" },
	}
	for index, blob in blobs do
		stick(arm, {
			name = "FleshBlob",
			size = Util.v3(blob[2].X, blob[2].Y, blob[2].Z),
			cframe = arm.CFrame * CFrame.new(blob[1].X * S, blob[1].Y * S, blob[1].Z * S),
			color = C[blob[3]],
			shape = Enum.PartType.Ball,
			reflectance = 0.07,
			castShadow = index <= 2,
		})
	end

	-- Kantong hijau di mutasi + selang.
	local pod = stick(arm, {
		name = "HeartPod",
		size = Util.v3(0.42, 0.5, 0.38),
		cframe = arm.CFrame * CFrame.new(0.48 * S, 0.18 * S, -0.22 * S),
		color = C.Tube,
		shape = Enum.PartType.Ball,
		material = Enum.Material.SmoothPlastic,
		reflectance = 0.15,
		castShadow = true,
	})
	local podLight = Instance.new("PointLight")
	podLight.Name = "PodLight"
	podLight.Color = C.Pod
	podLight.Brightness = 0.7
	podLight.Range = 6
	podLight.Parent = pod

	local mist = Instance.new("ParticleEmitter")
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Rate = 5
	mist.Lifetime = NumberRange.new(0.6, 1.1)
	mist.Speed = NumberRange.new(0.2, 0.6)
	mist.Size = NumberSequence.new(0.25, 0.7)
	mist.Transparency = NumberSequence.new(0.5, 1)
	mist.Color = ColorSequence.new(C.FleshDeep, C.Smoke)
	mist.LightEmission = 0.1
	mist.LockedToPart = false
	mist.Parent = pod

	stitches(arm, arm.CFrame * CFrame.new(0.2 * S, 0.05 * S, -0.35 * S) * CFrame.Angles(0, math.rad(20), math.rad(80)), 4, 0.55, 0.16)

	-- Selang kaku pendek dari pod ke canister (dua ujung, biar tidak melar saat lengan gerak).
	local function tubeBetween(a, b, host, thick, color)
		local delta = b - a
		local dist = delta.Magnitude
		if dist < 0.05 then
			return
		end
		local mid = (a + b) / 2
		local cfTube = CFrame.lookAt(mid, b) * CFrame.Angles(0, math.rad(90), 0)
		stick(host, {
			name = "Tube",
			size = Vector3.new(dist, thick, thick),
			cframe = cfTube,
			color = color,
			shape = Enum.PartType.Cylinder,
			reflectance = 0.12,
		})
	end

	local podPos = pod.Position
	local canPos = canister.Position
	tubeBetween(podPos, podPos:Lerp(canPos, 0.45), arm, 0.12 * S, C.Tube)
	tubeBetween(canPos, canPos:Lerp(podPos, 0.35), upper, 0.11 * S, C.PodDark)
	tubeBetween(podPos, podPos + Vector3.new(0.1 * S, 0.35 * S, 0.15 * S), arm, 0.09 * S, C.Tube)
	tubeBetween(arm.Position + Vector3.new(0.2 * S, 0.4 * S, 0.3 * S), arm.Position + Vector3.new(-0.1 * S, 0.55 * S, 0.45 * S), arm, 0.1 * S, C.Pod)

	----------------------------------------------------------------
	-- KAKI + BOOTS
	----------------------------------------------------------------
	local function dressLeg(side)
		local sign = side == "Right" and 1 or -1
		local ul, ll, foot = P[side .. "UpperLeg"], P[side .. "LowerLeg"], P[side .. "Foot"]
		stick(ul, {
			name = "Pants",
			size = ul.Size * Vector3.new(1.08, 1.02, 1.08),
			cframe = ul.CFrame,
			color = C.Pants,
			castShadow = true,
		})
		stick(ll, {
			name = "Pants",
			size = ll.Size * Vector3.new(1.06, 0.72, 1.06),
			cframe = ll.CFrame * CFrame.new(0, ll.Size.Y * 0.18, 0),
			color = C.Pants,
			castShadow = true,
		})

		local boot = stick(foot, {
			name = "Boot" .. side,
			size = Util.v3(1.16, 0.7, 1.85),
			cframe = foot.CFrame * CFrame.new(0, -0.06 * S, -0.08 * S),
			color = C.Boot,
			material = Enum.Material.SmoothPlastic,
			reflectance = 0.06,
			castShadow = true,
		})
		table.insert(soles, boot)

		stick(foot, {
			name = "BootToe",
			size = Util.v3(0.85, 0.42, 0.55),
			cframe = foot.CFrame * CFrame.new(0, -0.08 * S, -0.85 * S),
			color = C.Boot,
			shape = Enum.PartType.Ball,
			castShadow = true,
		})
		local cuff = stick(ll, {
			name = "BootCuff" .. side,
			size = Util.v3(1.14, 0.7, 1.14),
			cframe = ll.CFrame * CFrame.new(0, -0.48 * S, 0),
			color = C.Boot,
			castShadow = true,
		})
		table.insert(soles, cuff)

		strap(ll, ll.CFrame * CFrame.new(0, -0.28 * S, 0), Util.v3(1.2, 0.12, 1.2))
		strap(foot, foot.CFrame * CFrame.new(0, 0.12 * S, -0.15 * S), Util.v3(1.2, 0.1, 0.28))
		buckle(ll, ll.CFrame * CFrame.new(sign * 0.15 * S, -0.28 * S, -0.58 * S), 0.32)
		buckle(foot, foot.CFrame * CFrame.new(sign * 0.12 * S, 0.16 * S, -0.72 * S), 0.28)

		-- Sol sedikit lebih gelap.
		stick(foot, {
			name = "Sole",
			size = Util.v3(1.05, 0.1, 1.7),
			cframe = foot.CFrame * CFrame.new(0, -0.32 * S, -0.06 * S),
			color = Color3.fromRGB(6, 6, 8),
		})
	end

	dressLeg("Left")
	dressLeg("Right")

	----------------------------------------------------------------
	-- TENTAKEL (Motor6D, digoyang client)
	----------------------------------------------------------------
	local function growTentacle(spec)
		local host = P[spec.parent]
		if not host then
			return
		end
		local cursor = host.CFrame * Util.scf(spec.offset)
		local prev = host
		local n = spec.segments
		for i = 1, n do
			local len = spec.length * (1 - (i - 1) * 0.07)
			local thick = math.max(0.08, spec.thickness * (1 - (i - 1) * 0.1))
			local segCf = cursor * CFrame.new(0, -len / 2 * S, 0)
			local color = C[spec.color]:Lerp(C[spec.tip], (i - 1) / math.max(1, n - 1))
			local seg = bit({
				name = spec.name .. "_" .. i,
				size = Util.v3(thick, len, thick * 0.86),
				cframe = segCf,
				color = color,
				shape = Enum.PartType.Ball,
				reflectance = 0.08,
				castShadow = i <= 2,
			})
			local motor = Util.motor(spec.name .. "_" .. i, prev, seg)
			motor:SetAttribute("Kind", "Tent")
			motor:SetAttribute("Sway", spec.sway * (0.35 + 0.65 * (i / n)))
			motor:SetAttribute("Speed", spec.speed)
			motor:SetAttribute("Phase", spec.phase + i * 0.55)
			motor:SetAttribute("Index", i)
			motor:SetAttribute("Droop", 0.25 + i * 0.12)
			local curl = spec.curl and spec.curl[i] or 0.2
			cursor = seg.CFrame * CFrame.new(0, -seg.Size.Y / 2, 0) * CFrame.Angles(curl, spec.twist or 0.08, curl * 0.15)
			prev = seg
		end
	end

	for _, spec in Config.Tentacles do
		growTentacle(spec)
	end

	-- Ring di tanah tidak dipakai. Simpan daftar sol untuk HipHeight.
	ctx.soles = soles

	-- Outline halus biar siluet kebaca di baseplate terang.
	local highlight = Instance.new("Highlight")
	highlight.Name = "Rim"
	highlight.Adornee = model
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(70, 8, 12)
	highlight.OutlineTransparency = 0.45
	highlight.Parent = model
end

function Visuals.decorate(ctx)
	decorate(ctx)
end

return Visuals
