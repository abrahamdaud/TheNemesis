-- The Nemesis | R15
-- Studio: ReplicatedStorage.TheNemesis.Gear  (ModuleScript)
-- Rocket launcher dari model sheet: moncong, laras berkarat, kain merah,
-- gagang kayu, selang, diikat di punggung atau di tangan kanan.

local Config = require(script.Parent.Config)
local Util = require(script.Parent.Util)

local Gear = {}

local function axes(xAxis, yHint)
	local x = xAxis.Unit
	local y = (yHint - x * yHint:Dot(x))
	if y.Magnitude < 1e-4 then
		y = Vector3.yAxis
	end
	y = y.Unit
	local z = x:Cross(y)
	return x, y, z
end

function Gear.attach(ctx)
	local model = ctx.model
	local folder = ctx.gear
	local C = Config.Colors
	local S = Util.scale
	local torso = ctx.parts.UpperTorso
	local hand = ctx.parts.RightHand

	-- Bangun senjata di ruang lokal GunRoot.
	-- +X = arah laras (sumbu silinder Roblox), -Y = arah gagang turun.
	local xAxis, yAxis, zAxis = axes(Vector3.new(1, 0.08, 0.02), Vector3.new(0, 1, 0))
	local holsterPos = Vector3.new(0.05, 0.22, 0.95) * S
	local rootCf = torso.CFrame * CFrame.fromMatrix(holsterPos, xAxis, yAxis, zAxis)

	local function gpart(props)
		props.parent = folder
		props.massless = true
		props.canQuery = false
		props.cframe = rootCf * props.localCf
		props.localCf = nil
		return Util.part(props)
	end

	local root = gpart({
		name = "GunRoot",
		size = Util.v3(0.35, 0.35, 0.35),
		localCf = CFrame.new(),
		color = C.Wood,
		transparency = 1,
	})

	local function weldLocal(props)
		local p = gpart(props)
		Util.weld(root, p)
		return p
	end

	-- Laras: belakang zaitun, tengah karat, moncong melebar.
	weldLocal({
		name = "BarrelRear",
		size = Util.v3(0.85, 0.42, 0.42),
		localCf = CFrame.new(0.15 * S, 0, 0),
		color = C.Olive,
		shape = Enum.PartType.Cylinder,
		reflectance = 0.08,
		castShadow = true,
	})
	weldLocal({
		name = "BarrelMid",
		size = Util.v3(1.55, 0.38, 0.38),
		localCf = CFrame.new(1.2 * S, 0, 0),
		color = C.Rust,
		material = Enum.Material.CorrodedMetal,
		shape = Enum.PartType.Cylinder,
		castShadow = true,
	})
	weldLocal({
		name = "BarrelBand",
		size = Util.v3(0.12, 0.46, 0.46),
		localCf = CFrame.new(0.7 * S, 0, 0),
		color = C.Metal,
		material = Enum.Material.Metal,
		shape = Enum.PartType.Cylinder,
		reflectance = 0.4,
	})
	weldLocal({
		name = "Muzzle",
		size = Util.v3(0.45, 0.62, 0.62),
		localCf = CFrame.new(2.15 * S, 0, 0),
		color = C.MetalDark,
		material = Enum.Material.Metal,
		shape = Enum.PartType.Cylinder,
		castShadow = true,
	})
	weldLocal({
		name = "MuzzleLip",
		size = Util.v3(0.12, 0.74, 0.74),
		localCf = CFrame.new(2.38 * S, 0, 0),
		color = C.Metal,
		material = Enum.Material.Metal,
		shape = Enum.PartType.Cylinder,
	})
	-- Lubang laras.
	weldLocal({
		name = "Bore",
		size = Util.v3(0.08, 0.28, 0.28),
		localCf = CFrame.new(2.46 * S, 0, 0),
		color = Color3.fromRGB(8, 8, 10),
		shape = Enum.PartType.Cylinder,
	})

	-- Pegangan atas.
	weldLocal({
		name = "Carry",
		size = Util.v3(0.85, 0.08, 0.08),
		localCf = CFrame.new(1.15 * S, 0.42 * S, 0),
		color = C.MetalDark,
		material = Enum.Material.Metal,
		shape = Enum.PartType.Cylinder,
	})
	weldLocal({
		name = "CarryLegA",
		size = Util.v3(0.08, 0.28, 0.08),
		localCf = CFrame.new(0.78 * S, 0.24 * S, 0),
		color = C.MetalDark,
		material = Enum.Material.Metal,
	})
	weldLocal({
		name = "CarryLegB",
		size = Util.v3(0.08, 0.28, 0.08),
		localCf = CFrame.new(1.52 * S, 0.24 * S, 0),
		color = C.MetalDark,
		material = Enum.Material.Metal,
	})

	-- Gagang kayu + pelatuk.
	weldLocal({
		name = "Grip",
		size = Util.v3(0.22, 0.55, 0.28),
		localCf = CFrame.new(-0.05 * S, -0.4 * S, 0) * CFrame.Angles(0, 0, math.rad(12)),
		color = C.Wood,
		material = Enum.Material.Wood,
		castShadow = true,
	})
	weldLocal({
		name = "Trigger",
		size = Util.v3(0.06, 0.16, 0.06),
		localCf = CFrame.new(0.18 * S, -0.22 * S, 0),
		color = C.MetalDark,
		material = Enum.Material.Metal,
	})
	weldLocal({
		name = "Guard",
		size = Util.v3(0.28, 0.06, 0.08),
		localCf = CFrame.new(0.12 * S, -0.38 * S, 0),
		color = C.Metal,
		material = Enum.Material.Metal,
	})

	-- Kain merah diikat.
	for _, x in { 1.65, 1.85 } do
		weldLocal({
			name = "Cloth",
			size = Util.v3(0.16, 0.5, 0.5),
			localCf = CFrame.new(x * S, 0, 0) * CFrame.Angles(math.rad(20), math.rad(40), math.rad(15)),
			color = C.Cloth,
			material = Enum.Material.Fabric,
		})
	end
	weldLocal({
		name = "ClothKnot",
		size = Util.v3(0.2, 0.16, 0.16),
		localCf = CFrame.new(1.75 * S, 0.22 * S, 0.12 * S),
		color = C.Cloth,
		material = Enum.Material.Fabric,
		shape = Enum.PartType.Ball,
	})

	-- Selang melengkung di bawah laras.
	local hosePoints = 6
	for i = 0, hosePoints - 1 do
		local t = i / (hosePoints - 1)
		local x = (0.4 + t * 1.3) * S
		local y = (-0.28 - math.sin(t * math.pi) * 0.28) * S
		weldLocal({
			name = "Hose",
			size = Util.v3(0.28, 0.1, 0.1),
			localCf = CFrame.new(x, y, 0.16 * S) * CFrame.Angles(0, 0, math.rad(-30 * (0.5 - t))),
			color = C.MetalDark,
			material = Enum.Material.Metal,
			shape = Enum.PartType.Cylinder,
		})
	end

	-- Karat tambahan.
	weldLocal({
		name = "RustPatch",
		size = Util.v3(0.35, 0.2, 0.08),
		localCf = CFrame.new(1.05 * S, 0.12 * S, 0.16 * S),
		color = C.Rust,
		material = Enum.Material.CorrodedMetal,
	})

	local muzzle = Util.attach(root, "Muzzle", CFrame.new(2.5 * S, 0, 0))

	local mount = Instance.new("Motor6D")
	mount.Name = "GunMount"
	mount.Part0 = torso
	mount.Part1 = root
	mount.C0 = torso.CFrame:ToObjectSpace(root.CFrame)
	mount.C1 = CFrame.new()
	mount.Parent = torso

	-- Tangan: laras (+X senjata) searah keluar tinju (lokal -Y tangan),
	-- gagang (-Y senjata) mengarah ke +Z tangan supaya saat lengan diangkat gagang turun.
	local handOffset = CFrame.fromMatrix(
		Vector3.new(0, -0.42 * S, -0.02 * S),
		Vector3.new(0, -1, 0),
		Vector3.new(0, 0, -1),
		Vector3.new(1, 0, 0)
	)
	-- Cek: fromMatrix kolom X = (0,-1,0) artinya +X senjata = -Y tangan. Benar.
	-- Kolom Y = (0,0,-1) artinya +Y senjata = -Z tangan, jadi -Y senjata = +Z tangan.

	model:SetAttribute("GunHolsterC0", mount.C0)
	model:SetAttribute("GunHandC0", handOffset)

	-- Tool tak terlihat, cuma pemicu klik / tap.
	if ctx.kind == "player" then
		local tool = Instance.new("Tool")
		tool.Name = "Rocket Launcher"
		tool.ToolTip = "Tembak roket"
		tool.RequiresHandle = true
		tool.CanBeDropped = false
		tool.Parent = ctx.templates

		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.2, 0.2, 0.2)
		handle.Transparency = 1
		handle.CanCollide = false
		handle.Massless = true
		handle.Parent = tool
		tool.Grip = CFrame.new()
	end

	return muzzle
end

function Gear.setDrawn(model, drawn)
	local motor = model:FindFirstChild("GunMount", true)
	if not motor then
		return
	end
	local partName = drawn and "RightHand" or "UpperTorso"
	local attr = drawn and "GunHandC0" or "GunHolsterC0"
	local host = model:FindFirstChild(partName)
	local cf = model:GetAttribute(attr)
	if not host or typeof(cf) ~= "CFrame" then
		return
	end
	motor.Part0 = host
	motor.C0 = cf
	motor.C1 = CFrame.new()
	model:SetAttribute("GunDrawn", drawn == true)
end

return Gear
