-- The Nemesis | R15
-- Studio: ServerScriptService.NemesisServer  (Script, bukan ModuleScript)
-- Spawn boss, pad morph, AI, roket, raungan, hantaman.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Nemesis = require(ReplicatedStorage:WaitForChild("TheNemesis"))
local Config = Nemesis.Config

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage.TheNemesis

local actionEvent = Instance.new("RemoteEvent")
actionEvent.Name = "Action"
actionEvent.Parent = remotes

local function now()
	return workspace:GetServerTimeNow()
end

local function busy(model)
	return now() < (model:GetAttribute("ActionUntil") or 0) and model:GetAttribute("Action") ~= "Dead"
end

local function beginAction(model, name, duration)
	local t = now()
	model:SetAttribute("Action", name)
	model:SetAttribute("ActionStart", t)
	model:SetAttribute("ActionUntil", t + duration)
end

local function play(part, id, volume, pitch)
	if not part or not id then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = volume or 0.8
	s.PlaybackSpeed = pitch or 1
	s.RollOffMaxDistance = 100
	s.Parent = part
	s:Play()
	Debris:AddItem(s, 5)
end

local function rootOf(model)
	return model and model:FindFirstChild("HumanoidRootPart")
end

local function hurtAround(origin, radius, amount, attacker, knock)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { attacker }
	local parts = workspace:GetPartBoundsInRadius(origin, radius, params)
	local seen = {}
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model ~= attacker and not seen[model] then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				seen[model] = true
				hum:TakeDamage(amount)
				if knock and knock > 0 then
					local away = hrp.Position - origin
					if away.Magnitude < 0.05 then
						away = Vector3.new(0, 1, 0)
					else
						away = away.Unit
					end
					hrp.AssemblyLinearVelocity = away * knock + Vector3.new(0, knock * 0.28, 0)
				end
			end
		end
	end
end

local function boom(position, attacker)
	local ball = Instance.new("Part")
	ball.Name = "RocketBurst"
	ball.Shape = Enum.PartType.Ball
	ball.Material = Enum.Material.Neon
	ball.Color = Color3.fromRGB(255, 120, 40)
	ball.Size = Vector3.new(1, 1, 1)
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CFrame = CFrame.new(position)
	ball.Parent = workspace

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 140, 60)
	light.Brightness = 6
	light.Range = 16
	light.Parent = ball

	TweenService:Create(ball, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(9, 9, 9),
		Transparency = 1,
	}):Play()
	Debris:AddItem(ball, 0.4)
	play(ball, Config.Sounds.Boom, 1, 0.8)

	local radius = Config.Combat.RocketRadius
	hurtAround(position, radius, Config.Combat.RocketDamage, attacker, Config.Combat.RocketKnock)
	-- Falloff ringan di tepi sudah cukup dengan satu zona.
end

local function launchRocket(model, dir)
	local hrp = rootOf(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then
		return
	end
	if model:GetAttribute("Action") == "Dead" then
		return
	end
	local t = now()
	if t < (model:GetAttribute("NextRocket") or 0) then
		return
	end
	model:SetAttribute("NextRocket", t + Config.Combat.RocketCooldown)
	model:SetAttribute("RecoilTime", t)
	beginAction(model, "Rocket", 0.55)

	if typeof(dir) ~= "Vector3" or dir.Magnitude < 0.2 then
		dir = hrp.CFrame.LookVector
	else
		dir = dir.Unit
	end
	dir = Vector3.new(dir.X, math.clamp(dir.Y, -0.25, 0.45), dir.Z)
	if dir.Magnitude < 0.1 then
		dir = hrp.CFrame.LookVector
	end
	dir = dir.Unit

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { model }
	local chest = hrp.Position + Vector3.new(0, 1.35, 0)
	local probe = workspace:Raycast(chest, dir * 5, params)
	local origin = probe and (probe.Position - dir * 1.1) or (chest + dir * 4.2)

	local rocket = Instance.new("Part")
	rocket.Name = "NemesisRocket"
	rocket.Size = Vector3.new(1.35, 0.38, 0.38)
	rocket.Shape = Enum.PartType.Cylinder
	rocket.Material = Enum.Material.Metal
	rocket.Color = Color3.fromRGB(90, 70, 48)
	rocket.Anchored = true
	rocket.CanCollide = false
	rocket.CanQuery = false
	rocket.CFrame = CFrame.lookAt(origin, origin + dir) * CFrame.Angles(0, math.rad(90), 0)
	rocket.Parent = workspace

	local fire = Instance.new("ParticleEmitter")
	fire.Texture = "rbxasset://textures/particles/fire_main.dds"
	fire.Rate = 80
	fire.Lifetime = NumberRange.new(0.15, 0.3)
	fire.Speed = NumberRange.new(2, 6)
	fire.Size = NumberSequence.new(0.4, 0.05)
	fire.LightEmission = 0.8
	fire.Parent = rocket

	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 150, 60)
	glow.Brightness = 3
	glow.Range = 10
	glow.Parent = rocket

	play(hrp, Config.Sounds.Rocket, 0.9, 0.85)

	if model:GetAttribute("Kind") == "boss" then
		Nemesis.setGunDrawn(model, true)
		task.delay(0.7, function()
			if model.Parent and model:GetAttribute("Kind") == "boss" then
				Nemesis.setGunDrawn(model, false)
			end
		end)
	end

	local speed = Config.Combat.RocketSpeed
	local life = Config.Combat.RocketLife
	task.spawn(function()
		local pos = origin
		local t0 = os.clock()
		while rocket.Parent and os.clock() - t0 < life do
			local dt = task.wait()
			local step = dir * speed * dt
			local hit = workspace:Raycast(pos, step, params)
			if hit then
				rocket:Destroy()
				boom(hit.Position, model)
				return
			end
			pos = pos + step
			rocket.CFrame = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, math.rad(90), 0)
		end
		if rocket.Parent then
			local endPos = rocket.Position
			rocket:Destroy()
			boom(endPos, model)
		end
	end)
end

local function slam(model)
	local hrp = rootOf(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then
		return
	end
	if busy(model) then
		return
	end
	local t = now()
	if t < (model:GetAttribute("NextMelee") or 0) then
		return
	end
	model:SetAttribute("NextMelee", t + Config.Combat.MeleeCooldown)
	beginAction(model, "Slam", Config.Combat.SlamTime)
	play(hrp, Config.Sounds.Swing, 0.7, 0.6)
	task.delay(Config.Combat.SlamHit, function()
		if not model.Parent or hum.Health <= 0 then
			return
		end
		local origin = hrp.CFrame * Vector3.new(0, 0.6, -3.4)
		hurtAround(origin, Config.Combat.MeleeRange, Config.Combat.MeleeDamage, model, Config.Combat.MeleeKnock)
		play(hrp, Config.Sounds.Hit, 0.8, 0.75)
	end)
end

local function roar(model)
	local hrp = rootOf(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then
		return
	end
	if busy(model) then
		return
	end
	local t = now()
	if t < (model:GetAttribute("NextRoar") or 0) then
		return
	end
	model:SetAttribute("NextRoar", t + Config.Combat.RoarCooldown)
	beginAction(model, "Roar", Config.Combat.RoarTime)
	play(hrp, Config.Sounds.Roar, 1, 0.5)
	task.delay(0.35, function()
		if model.Parent and hum.Health > 0 then
			hurtAround(hrp.Position, Config.Combat.RoarRadius, Config.Combat.RoarDamage, model, Config.Combat.RoarKnock)
		end
	end)
end

local function addBossPlate(model)
	local head = model:FindFirstChild("Head")
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not head or not hum then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "BossPlate"
	gui.Size = UDim2.new(5.5, 0, 1.1, 0)
	gui.StudsOffset = Vector3.new(0, 2.3, 0)
	gui.MaxDistance = 140
	gui.Parent = head

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0.48, 0)
	title.Font = Enum.Font.GothamBlack
	title.Text = Config.Boss.Title
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(236, 232, 228)
	title.Parent = gui

	local back = Instance.new("Frame")
	back.Name = "Back"
	back.BackgroundColor3 = Color3.fromRGB(18, 6, 8)
	back.BorderSizePixel = 0
	back.Position = UDim2.new(0.08, 0, 0.55, 0)
	back.Size = UDim2.new(0.84, 0, 0.28, 0)
	back.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = back

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(168, 28, 32)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.Parent = back
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 3)
	fillCorner.Parent = fill

	hum.HealthChanged:Connect(function(health)
		local ratio = math.clamp(health / math.max(1, hum.MaxHealth), 0, 1)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
	end)
end

local function addHurtbox(model)
	local torso = model:FindFirstChild("UpperTorso")
	if not torso then
		return
	end
	local hb = Instance.new("Part")
	hb.Name = "Hurtbox"
	hb.Size = Vector3.new(4.4, 6.2, 3.4)
	hb.Transparency = 1
	hb.CanCollide = false
	hb.CanQuery = false
	hb.CanTouch = true
	hb.Massless = true
	hb.Anchored = true
	hb.CFrame = torso.CFrame
	hb.Parent = model
	local w = Instance.new("WeldConstraint")
	w.Part0 = torso
	w.Part1 = hb
	w.Parent = hb
	hb.Anchored = false

	local last = {}
	hb.Touched:Connect(function(hit)
		local other = hit:FindFirstAncestorOfClass("Model")
		if not other or other == model then
			return
		end
		local hum = other:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			return
		end
		local t = os.clock()
		if last[hum] and t - last[hum] < 0.85 then
			return
		end
		last[hum] = t
		hum:TakeDamage(Config.Boss.TouchDamage)
	end)
end

local function baseCFrame()
	local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		return spawn.CFrame
	end
	local plate = workspace:FindFirstChild("Baseplate")
	if plate and plate:IsA("BasePart") then
		return CFrame.new(plate.Position + Vector3.new(0, plate.Size.Y / 2, 0))
	end
	return CFrame.new(0, 5, 0)
end

local function placeOnGround(model, worldCFrame, serverOwn)
	local stand = model:GetAttribute("HipStand") or 4
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { model }
	local origin = worldCFrame.Position + Vector3.new(0, 80, 0)
	local hit = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
	local gy = hit and hit.Position.Y or worldCFrame.Position.Y
	local yaw = select(2, worldCFrame:ToOrientation())
	local cf = CFrame.new(worldCFrame.Position.X, gy + stand, worldCFrame.Position.Z) * CFrame.Angles(0, yaw, 0)
	model.Parent = workspace
	model:PivotTo(cf)
	Nemesis.unlock(model, serverOwn)
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Anchored = true
		task.delay(0.2, function()
			if hrp.Parent then
				hrp.Anchored = false
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
	return cf
end

local function nearestTarget(fromPos, maxDist, ignore)
	local bestRoot, bestDist
	for _, plr in Players:GetPlayers() do
		local ch = plr.Character
		if ch and ch ~= ignore and not ch:GetAttribute("Boss") then
			local hum = ch:FindFirstChildOfClass("Humanoid")
			local hrp = ch:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				local dist = (hrp.Position - fromPos).Magnitude
				if dist <= maxDist and (not bestDist or dist < bestDist) then
					bestRoot = hrp
					bestDist = dist
				end
			end
		end
	end
	return bestRoot, bestDist
end

local spawnBoss

local function bindBoss(model)
	addBossPlate(model)
	addHurtbox(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	local home = hrp.Position
	local saw = false

	hum.Died:Connect(function()
		beginAction(model, "Dead", 2)
		model:SetAttribute("Action", "Dead")
		hum.PlatformStand = true
		task.delay(6, function()
			if model.Parent then
				model:Destroy()
			end
			if Config.SpawnBoss then
				task.delay(3, function()
					spawnBoss()
				end)
			end
		end)
	end)

	task.spawn(function()
		while model.Parent and hum.Health > 0 do
			task.wait(math.random(8, 14))
			if hum.Health > 0 and hrp.Parent then
				play(hrp, Config.Sounds.Growl, 0.4, 0.5 + math.random() * 0.12)
			end
		end
	end)

	task.spawn(function()
		while model.Parent and hum.Health > 0 do
			local target, dist = nearestTarget(hrp.Position, Config.Boss.Leash, model)
			if busy(model) then
				hum.WalkSpeed = 3
				hum:MoveTo(hrp.Position)
				task.wait(0.15)
				continue
			end
			if target and dist then
				model:SetAttribute("LookAt", target.Position)
				if not saw then
					saw = true
					roar(model)
					task.wait(0.2)
					continue
				end
				if dist > Config.Boss.Leash * 0.98 and (hrp.Position - home).Magnitude > Config.Boss.Leash then
					model:SetAttribute("LookAt", nil)
					hum.WalkSpeed = Config.Boss.WalkSpeed
					hum:MoveTo(home)
				elseif dist <= Config.Boss.MeleeRange then
					hum.WalkSpeed = 4
					hum:MoveTo(hrp.Position)
					slam(model)
				elseif dist >= Config.Boss.RocketMin and dist <= Config.Boss.RocketMax then
					hum.WalkSpeed = Config.Boss.ChaseSpeed * 0.65
					hum:MoveTo(target.Position)
					local aim = target.Position + Vector3.new(0, 1.2, 0) - (hrp.Position + Vector3.new(0, 1.3, 0))
					launchRocket(model, aim)
				else
					hum.WalkSpeed = Config.Boss.ChaseSpeed
					hum:MoveTo(target.Position)
				end
			else
				model:SetAttribute("LookAt", nil)
				saw = false
				hum.WalkSpeed = Config.Boss.WalkSpeed
				if (hrp.Position - home).Magnitude > 6 then
					hum:MoveTo(home)
				end
			end
			task.wait(0.28)
		end
	end)
end

spawnBoss = function()
	if workspace:FindFirstChild("TheNemesis") then
		return
	end
	local model = Nemesis.create({ kind = "boss", name = "TheNemesis" })
	local spot = baseCFrame() * CFrame.new(0, 8, -18)
	placeOnGround(model, spot, true)
	bindBoss(model)
end

local function giveLauncher(player, model)
	local templates = model:FindFirstChild("Templates")
	local template = templates and templates:FindFirstChild("Rocket Launcher")
	local backpack = player:FindFirstChild("Backpack") or player:WaitForChild("Backpack", 5)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not template or not backpack or not hum then
		return
	end
	local tool = template:Clone()
	local handle = tool:FindFirstChild("Handle")
	if handle then
		handle.Anchored = false
	end
	tool.Parent = backpack
	hum:EquipTool(tool)
	Nemesis.setGunDrawn(model, true)
	tool.Equipped:Connect(function()
		if model.Parent then
			Nemesis.setGunDrawn(model, true)
		end
	end)
	tool.Unequipped:Connect(function()
		if model.Parent then
			Nemesis.setGunDrawn(model, false)
		end
	end)
end

local function morphPlayer(player)
	local current = player.Character
	if not current then
		return
	end
	if current:GetAttribute("IsNemesis") then
		return
	end
	local pivot = current:GetPivot()
	local model = Nemesis.create({ kind = "player", name = player.Name })
	local hum = model:FindFirstChildOfClass("Humanoid")
	hum.DisplayName = player.DisplayName or player.Name
	model.Parent = workspace
	player.Character = model
	task.wait()
	if not model.Parent then
		return
	end
	placeOnGround(model, pivot, false)
	giveLauncher(player, model)
	hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Died:Connect(function()
			beginAction(model, "Dead", 2)
			model:SetAttribute("Action", "Dead")
			hum.PlatformStand = true
		end)
	end
end

local function makePad()
	local spot = baseCFrame() * CFrame.new(8, 6, -8)
	local params = RaycastParams.new()
	local hit = workspace:Raycast(spot.Position + Vector3.new(0, 40, 0), Vector3.new(0, -200, 0), params)
	local gy = hit and hit.Position.Y or spot.Position.Y

	local pad = Instance.new("Part")
	pad.Name = "NemesisPad"
	pad.Shape = Enum.PartType.Cylinder
	pad.Size = Vector3.new(0.55, 7.2, 7.2)
	pad.Color = Color3.fromRGB(14, 14, 16)
	pad.Material = Enum.Material.Metal
	pad.Anchored = true
	-- Sumbu silinder Roblox ada di X. Putar supaya koin-nya terbaring.
	pad.CFrame = CFrame.new(spot.Position.X, gy + 0.3, spot.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
	pad.Parent = workspace

	local ring = Instance.new("Part")
	ring.Name = "PadRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.18, 6.2, 6.2)
	ring.Color = Color3.fromRGB(150, 24, 28)
	ring.Material = Enum.Material.Neon
	ring.Anchored = true
	ring.CanCollide = false
	ring.CFrame = pad.CFrame * CFrame.new(0.22, 0, 0)
	ring.Parent = pad

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(160, 20, 24)
	light.Brightness = 1.4
	light.Range = 10
	light.Parent = pad

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(8, 0, 2.2, 0)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.MaxDistance = 80
	gui.Parent = pad

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0.55, 0)
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(236, 230, 226)
	label.Text = "THE NEMESIS"
	label.Parent = gui

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 0, 0.52, 0)
	sub.Size = UDim2.new(1, 0, 0.4, 0)
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromRGB(196, 64, 64)
	sub.Text = "SENTUH  ·  /nemesis"
	sub.Parent = gui

	local debounce = {}
	pad.Touched:Connect(function(hit)
		local char = hit:FindFirstAncestorOfClass("Model")
		local plr = char and Players:GetPlayerFromCharacter(char)
		if not plr or debounce[plr] then
			return
		end
		debounce[plr] = true
		task.delay(2, function()
			debounce[plr] = nil
		end)
		morphPlayer(plr)
	end)
end

local function sanitizeAim(hrp, requested)
	local face = hrp.CFrame.LookVector
	if typeof(requested) ~= "Vector3" or requested.Magnitude < 0.4 or requested.Magnitude > 4 then
		return face
	end
	local dir = requested.Unit
	if face:Dot(dir) < 0.2 then
		return face
	end
	return dir
end

actionEvent.OnServerEvent:Connect(function(player, action, aim)
	if typeof(action) ~= "string" then
		return
	end
	local char = player.Character
	if not char or not char:GetAttribute("IsNemesis") then
		return
	end
	local hrp = rootOf(char)
	if not hrp then
		return
	end
	if action == "Rocket" then
		launchRocket(char, sanitizeAim(hrp, aim))
	elseif action == "Melee" then
		slam(char)
	elseif action == "Roar" then
		roar(char)
	end
end)

local function hookChat(player)
	player.Chatted:Connect(function(message)
		local text = string.lower(message)
		if text == "/nemesis" then
			morphPlayer(player)
		elseif text == "/human" then
			player:LoadCharacter()
		end
	end)
end

Players.PlayerAdded:Connect(hookChat)
for _, player in Players:GetPlayers() do
	hookChat(player)
end

if Config.SpawnBoss then
	task.defer(spawnBoss)
end
if Config.SpawnPad then
	task.defer(makePad)
end
