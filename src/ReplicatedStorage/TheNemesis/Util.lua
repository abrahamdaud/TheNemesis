-- The Nemesis | R15
-- Studio: ReplicatedStorage.TheNemesis.Util  (ModuleScript)

local Config = require(script.Parent.Config)

local Util = {}
Util.scale = Config.Scale

function Util.v3(x, y, z)
	local s = Util.scale
	return Vector3.new(x * s, y * s, z * s)
end

function Util.scf(cf)
	local s = Util.scale
	return CFrame.new(cf.Position * s) * (cf - cf.Position)
end

function Util.part(props)
	local inst = Instance.new(props.className or "Part")
	inst.Name = props.name or "Part"
	inst.Size = props.size or Vector3.new(1, 1, 1)
	inst.CFrame = props.cframe or CFrame.new()
	inst.Color = props.color or Color3.new(1, 1, 1)
	inst.Material = props.material or Enum.Material.SmoothPlastic
	inst.Anchored = true
	inst.CanCollide = false
	inst.CanTouch = props.canTouch == true
	inst.CanQuery = props.canQuery ~= false
	inst.Massless = props.massless == true
	inst.CastShadow = props.castShadow == true
	inst.TopSurface = Enum.SurfaceType.Smooth
	inst.BottomSurface = Enum.SurfaceType.Smooth
	if props.transparency then
		inst.Transparency = props.transparency
	end
	if props.reflectance then
		inst.Reflectance = props.reflectance
	end
	if props.shape and inst:IsA("Part") then
		inst.Shape = props.shape
	end
	inst.Parent = props.parent
	return inst
end

function Util.weld(a, b)
	local w = Instance.new("WeldConstraint")
	w.Part0 = a
	w.Part1 = b
	w.Parent = a
	return w
end

-- C0 menyimpan pose bind. Transform (animasi) ditimpa di client.
function Util.motor(name, part0, part1)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = part0
	m.Part1 = part1
	m.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
	m.C1 = CFrame.new()
	m.Parent = part0
	return m
end

function Util.attach(parent, name, cf)
	local a = Instance.new("Attachment")
	a.Name = name
	a.CFrame = cf or CFrame.new()
	a.Parent = parent
	return a
end

function Util.lowestY(parts)
	local best = math.huge
	for _, p in parts do
		local hx, hy, hz = p.Size.X / 2, p.Size.Y / 2, p.Size.Z / 2
		for _, x in { -hx, hx } do
			for _, y in { -hy, hy } do
				for _, z in { -hz, hz } do
					local wp = p.CFrame:PointToWorldSpace(Vector3.new(x, y, z))
					if wp.Y < best then
						best = wp.Y
					end
				end
			end
		end
	end
	return best
end

function Util.sound(parent, id, volume, pitch)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = volume or 0.8
	s.PlaybackSpeed = pitch or 1
	s.RollOffMaxDistance = 80
	s.Parent = parent
	return s
end

return Util
