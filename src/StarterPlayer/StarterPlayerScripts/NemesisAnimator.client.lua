-- The Nemesis | R15
-- Studio: StarterPlayer.StarterPlayerScripts.NemesisAnimator  (LocalScript)
-- Animasi prosedural. Transform Motor6D tidak tereplikasi, jadi setiap klien
-- menghitung pose yang sama dari MoveDirection + attribute server.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("TheNemesis"):WaitForChild("Config"))
local player = Players.LocalPlayer

local BODY = {
	"Root",
	"Waist",
	"Neck",
	"LeftShoulder",
	"LeftElbow",
	"LeftWrist",
	"RightShoulder",
	"RightElbow",
	"RightWrist",
	"LeftHip",
	"LeftKnee",
	"LeftAnkle",
	"RightHip",
	"RightKnee",
	"RightAnkle",
	"Jaw",
}

local hooked = {}

local function ang(x, y, z)
	return CFrame.Angles(x or 0, y or 0, z or 0)
end

local function approach(cache, motor, target, sharpness, dt)
	local prev = cache[motor] or CFrame.new()
	local alpha = 1 - math.exp(-sharpness * dt)
	local nextCf = prev:Lerp(target, alpha)
	cache[motor] = nextCf
	motor.Transform = nextCf
end

local function stripDefaultAnimate(character)
	local animate = character:FindFirstChild("Animate")
	if animate then
		animate:Destroy()
	end
	local hum = character:FindFirstChildOfClass("Humanoid")
	local animator = hum and hum:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			track:Stop(0)
		end
	end
end

local function hook(model)
	if hooked[model] or not model:IsA("Model") then
		return
	end
	hooked[model] = true

	task.spawn(function()
		local hum = model:WaitForChild("Humanoid", 10)
		local hrp = model:WaitForChild("HumanoidRootPart", 10)
		if not hum or not hrp or not model.Parent then
			hooked[model] = nil
			return
		end

		local function refresh()
			if model == player.Character then
				stripDefaultAnimate(model)
			end
		end
		refresh()
		model.ChildAdded:Connect(function(child)
			if child.Name == "Animate" then
				task.defer(refresh)
			end
		end)

		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			animator.AnimationPlayed:Connect(function(track)
				track:Stop(0)
			end)
		end

		local motors = {}
		local coats = {}
		local tents = {}
		local function scan()
			motors = {}
			coats = {}
			tents = {}
			for _, d in model:GetDescendants() do
				if d:IsA("Motor6D") then
					if d:GetAttribute("Kind") == "Coat" then
						table.insert(coats, d)
					elseif d:GetAttribute("Kind") == "Tent" then
						table.insert(tents, d)
					elseif table.find(BODY, d.Name) then
						motors[d.Name] = d
					elseif d.Name == "GunMount" then
						motors.GunMount = d
					end
				end
			end
		end
		scan()

		local cache = {}
		local phase = 0
		local lastStep = 0
		local alive = true

		local conn
		conn = RunService.PreSimulation:Connect(function(dt)
			if not alive or not model.Parent then
				conn:Disconnect()
				return
			end
			dt = math.clamp(dt, 0, 0.05)
			local serverNow = workspace:GetServerTimeNow()

			if model == player.Character and animator then
				local tracks = animator:GetPlayingAnimationTracks()
				for _, track in tracks do
					track:Stop(0)
				end
			end

			local move = hum.MoveDirection.Magnitude
			local state = hum:GetState()
			local airborne = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall
			local moving = move > 0.15 and not airborne and hum.Health > 0
			if moving then
				phase += dt * (9 + move * 0.85)
			end
			local s = math.sin(phase)
			local breathe = math.sin(serverNow * 1.55)
			local amp = math.clamp(move / 13, 0.4, 1.15)

			local T = {}
			if hum.Health <= 0 then
				-- pose mayat diisi action Dead
			elseif airborne then
				T.LeftHip = ang(-0.4, 0, 0)
				T.RightHip = ang(0.15, 0, 0)
				T.LeftKnee = ang(0.85, 0, 0)
				T.RightKnee = ang(0.4, 0, 0)
				T.LeftShoulder = ang(-0.9, 0, 0)
				T.RightShoulder = ang(-0.45, 0, 0)
				T.LeftElbow = ang(0.4, 0, 0)
				T.RightElbow = ang(0.55, 0, 0)
				T.Waist = ang(0.18, 0, 0)
				T.Neck = ang(0.15, 0, 0)
				T.Root = CFrame.new(0, 0.05, 0)
			elseif moving then
				T.LeftHip = ang(s * 0.78 * amp, 0, 0)
				T.RightHip = ang(-s * 0.78 * amp, 0, 0)
				T.LeftKnee = ang(math.clamp(s, 0, 1) * 0.9 * amp, 0, 0)
				T.RightKnee = ang(math.clamp(-s, 0, 1) * 0.9 * amp, 0, 0)
				T.LeftAnkle = ang(-s * 0.18 * amp, 0, 0)
				T.RightAnkle = ang(s * 0.18 * amp, 0, 0)
				T.LeftShoulder = ang(-s * 0.48 * amp, 0, math.rad(8))
				T.RightShoulder = ang(s * 0.22 * amp, 0.08, math.rad(-6))
				T.LeftElbow = ang(0.15 + math.clamp(s, 0, 1) * 0.45, 0, 0)
				T.RightElbow = ang(0.35, 0, 0)
				T.Waist = CFrame.new(0, math.abs(s) * -0.035, 0) * ang(0.06, s * 0.14 * amp, -s * 0.04)
				T.Root = CFrame.new(0, math.abs(s) * -0.05 * amp, 0)
				T.Neck = ang(-0.16, s * 0.06, 0.04)
				if s > 0 and lastStep <= 0 and model:GetAttribute("Boss") then
					local snd = hrp:FindFirstChild("Stomp")
					if not snd then
						snd = Instance.new("Sound")
						snd.Name = "Stomp"
						snd.SoundId = Config.Sounds.Stomp
						snd.Volume = 0.28
						snd.PlaybackSpeed = 0.65
						snd.Parent = hrp
					end
					snd:Play()
				end
				lastStep = s
			else
				T.Waist = CFrame.new(0, breathe * 0.03, 0) * ang(0.1, math.sin(serverNow * 0.45) * 0.06, math.sin(serverNow * 0.3) * 0.025)
				T.Root = CFrame.new(0, breathe * 0.02, 0)
				T.Neck = ang(-0.24 + math.sin(serverNow * 0.8) * 0.035, math.sin(serverNow * 0.4) * 0.1, 0.04)
				T.LeftShoulder = ang(0.18 + math.sin(serverNow * 1.15) * 0.04, 0, math.rad(-10))
				T.RightShoulder = ang(0.32, 0.12, math.rad(12))
				T.LeftElbow = ang(0.4, 0, 0)
				T.RightElbow = ang(0.5, 0, 0)
				T.LeftWrist = ang(0.1, 0, 0)
				T.RightWrist = ang(0.15, 0, 0)
				T.LeftHip = ang(0.05, 0, math.rad(-2))
				T.RightHip = ang(-0.02, 0, math.rad(2))
				T.LeftKnee = ang(0.1, 0, 0)
				T.RightKnee = ang(0.1, 0, 0)
			end

			local look = model:GetAttribute("LookAt")
			if typeof(look) == "Vector3" and hum.Health > 0 then
				local lp = hrp.CFrame:PointToObjectSpace(look)
				local flat = Vector3.new(lp.X, 0, lp.Z).Magnitude
				local yaw = math.clamp(math.atan2(lp.X, -lp.Z), -0.75, 0.75)
				local pitch = math.clamp(math.atan2(lp.Y, math.max(0.25, flat)), -0.3, 0.4)
				T.Neck = (T.Neck or CFrame.new()) * ang(pitch * 0.65, yaw * 0.6, 0)
				T.Waist = (T.Waist or CFrame.new()) * ang(0, yaw * 0.22, 0)
			end

			T.Jaw = ang(math.sin(serverNow * 1.8) * 0.035 * Config.JawSign, 0, 0)

			local action = model:GetAttribute("Action") or ""
			if hum.Health <= 0 then
				action = "Dead"
			end
			local startT = model:GetAttribute("ActionStart") or serverNow
			local untilT = model:GetAttribute("ActionUntil") or 0
			local dur = math.max(0.05, untilT - startT)
			local alpha = math.clamp((serverNow - startT) / dur, 0, 1)
			local weight = 0
			if action == "Dead" then
				weight = math.clamp((serverNow - startT) / 0.85, 0, 1)
			elseif serverNow < untilT then
				if alpha < 0.12 then
					weight = alpha / 0.12
				elseif alpha > 0.78 then
					weight = 1 - (alpha - 0.78) / 0.22
				else
					weight = 1
				end
			end

			local A = {}
			if action == "Slam" then
				local wind = math.clamp(alpha / 0.38, 0, 1)
				local strike = math.clamp((alpha - 0.36) / 0.16, 0, 1)
				local recover = math.clamp((alpha - 0.58) / 0.42, 0, 1)
				local pull = wind * (1 - strike)
				local hit = strike * (1 - recover * 0.35)
				A.RightShoulder = ang(-1.5 * pull + 0.85 * hit, 0.25 * pull, math.rad(-18))
				A.RightElbow = ang(0.15 + 0.9 * pull, 0, 0)
				A.Waist = ang(0.25 * pull - 0.4 * hit, -0.45 * pull + 0.55 * hit, 0)
				A.Neck = ang(-0.15 - 0.25 * hit, -0.25 * pull, 0)
				A.LeftShoulder = ang(-0.35 * hit, 0, math.rad(16))
			elseif action == "Roar" then
				local o = math.sin(math.clamp(alpha, 0, 1) * math.pi)
				A.Neck = ang(0.75 * o, 0, 0)
				A.Jaw = ang(0.6 * o * Config.JawSign, 0, 0)
				A.Waist = ang(-0.28 * o, 0, 0)
				A.LeftShoulder = ang(-1.15 * o, 0, math.rad(-28 * o))
				A.RightShoulder = ang(-0.85 * o, 0, math.rad(24 * o))
				A.LeftElbow = ang(0.45 * o, 0, 0)
				A.RightElbow = ang(0.35 * o, 0, 0)
			elseif action == "Rocket" then
				A.RightShoulder = ang(-1.2, 0.12, math.rad(-10))
				A.RightElbow = ang(0.3, 0, 0)
				A.LeftShoulder = ang(-0.95, -0.2, math.rad(16))
				A.LeftElbow = ang(0.75, 0, 0)
				A.Waist = ang(-0.04, -0.3, 0)
				A.Neck = ang(-0.08, -0.18, 0)
			elseif action == "Dead" then
				A.Waist = ang(1.15, 0.15, 0.35)
				A.Neck = ang(0.85, 0.25, 0.1)
				A.Jaw = ang(0.35 * Config.JawSign, 0, 0)
				A.LeftShoulder = ang(0.55, 0, math.rad(-24))
				A.RightShoulder = ang(0.7, 0, math.rad(18))
				A.LeftElbow = ang(0.2, 0, 0)
				A.RightElbow = ang(0.25, 0, 0)
				A.LeftHip = ang(0.45, 0, 0)
				A.RightHip = ang(-0.15, 0, 0)
				A.LeftKnee = ang(1.25, 0, 0)
				A.RightKnee = ang(1.15, 0, 0)
				A.Root = CFrame.new(0, -0.4, 0)
			end

			local drawn = model:GetAttribute("GunDrawn") == true
			if drawn and action ~= "Dead" and action ~= "Slam" and action ~= "Roar" then
				local since = serverNow - (model:GetAttribute("RecoilTime") or 0)
				local recoil = (since >= 0 and since < 0.2) and (1 - since / 0.2) ^ 2 or 0
				A.RightShoulder = ang(-1.15 - recoil * 0.25, 0.08, math.rad(-8))
				A.RightElbow = ang(0.28 + recoil * 0.45, 0, 0)
				A.LeftShoulder = ang(-0.9, -0.22, math.rad(14))
				A.LeftElbow = ang(0.72, 0, 0)
				A.Neck = ang(-0.05, -0.12, 0)
				weight = math.max(weight, 0.92)
			end

			for name, motor in motors do
				if name ~= "GunMount" then
					local base = T[name] or CFrame.new()
					local over = A[name]
					local target = over and base:Lerp(over, math.clamp(weight, 0, 1)) or base
					approach(cache, motor, target, action == "Dead" and 6 or 12, dt)
				end
			end

			local roarAmp = (action == "Roar") and (1 + weight * 1.6) or 1
			for _, motor in tents do
				local sway = motor:GetAttribute("Sway") or 0.2
				local speed = motor:GetAttribute("Speed") or 1
				local ph = motor:GetAttribute("Phase") or 0
				local droop = motor:GetAttribute("Droop") or 0.4
				local target
				if action == "Dead" then
					target = ang(droop * weight + 0.2, 0, 0)
				else
					target = ang(
						math.sin(serverNow * speed + ph) * sway * roarAmp,
						math.cos(serverNow * speed * 0.75 + ph) * sway * 0.7 * roarAmp,
						0
					)
				end
				approach(cache, motor, target, 7, dt)
			end

			local drag = math.clamp(move, 0, 16) * 0.012
			for _, motor in coats do
				local sway = motor:GetAttribute("Sway") or 0.06
				local ph = motor:GetAttribute("Phase") or 0
				local target
				if action == "Dead" then
					target = ang(0.9 * weight, 0, 0)
				else
					target = ang(math.sin(serverNow * 1.7 + ph) * sway + drag + (moving and math.abs(s) * 0.05 or 0), 0, 0)
				end
				approach(cache, motor, target, 5, dt)
			end

			if motors.GunMount then
				local since = serverNow - (model:GetAttribute("RecoilTime") or 0)
				local recoil = (since >= 0 and since < 0.18) and (1 - since / 0.18) ^ 2 or 0
				approach(cache, motors.GunMount, CFrame.new(-recoil * 0.18, 0, 0), 18, dt)
			end

			for _, eyeName in { "EyePupilL", "EyePupilR" } do
				local pupil = model:FindFirstChild(eyeName, true)
				if pupil then
					local light = pupil:FindFirstChildOfClass("PointLight")
					if light then
						local glow = 0.35 + math.sin(serverNow * 3.2) * 0.12
						if action == "Roar" then
							glow = 1.5
						end
						light.Brightness = glow
					end
				end
			end
		end)

		model.Destroying:Connect(function()
			alive = false
			hooked[model] = nil
			if conn then
				conn:Disconnect()
			end
		end)
	end)
end

CollectionService:GetInstanceAddedSignal(Config.Tag):Connect(hook)
for _, model in CollectionService:GetTagged(Config.Tag) do
	hook(model)
end

----------------------------------------------------------------
-- Kontrol pemain (hanya saat karakter lokal adalah Nemesis)
----------------------------------------------------------------
local remotes = ReplicatedStorage:WaitForChild("TheNemesis"):WaitForChild("Remotes")
local actionEvent = remotes:WaitForChild("Action")

local gui = Instance.new("ScreenGui")
gui.Name = "NemesisControls"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local stack = Instance.new("Frame")
stack.Name = "Stack"
stack.AnchorPoint = Vector2.new(1, 0.5)
stack.Position = UDim2.new(1, -18, 0.58, 0)
stack.Size = UDim2.fromOffset(92, 250)
stack.BackgroundTransparency = 1
stack.Visible = false
stack.Parent = gui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = stack

local function makeButton(text, hint)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(84, 72)
	b.BackgroundColor3 = Color3.fromRGB(18, 12, 14)
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Text = ""
	b.Parent = stack
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(150, 36, 40)
	stroke.Thickness = 1.5
	stroke.Parent = b
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0.58, 0)
	title.Font = Enum.Font.GothamBlack
	title.Text = text
	title.TextScaled = true
	title.TextColor3 = Color3.fromRGB(236, 230, 226)
	title.Parent = b
	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0, 0, 0.55, 0)
	sub.Size = UDim2.new(1, 0, 0.35, 0)
	sub.Font = Enum.Font.Gotham
	sub.Text = hint
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromRGB(196, 90, 90)
	sub.Parent = b
	return b
end

local btnMelee = makeButton("HANTAM", "F")
local btnRoar = makeButton("RAUNG", "R")
local btnGun = makeButton("TEMBAK", "KLIK")

local function isNemesis()
	local ch = player.Character
	return ch ~= nil and ch:GetAttribute("IsNemesis") == true
end

local function fire(name)
	if not isNemesis() then
		return
	end
	local aim
	if name == "Rocket" then
		local cam = workspace.CurrentCamera
		aim = cam and cam.CFrame.LookVector or nil
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local pack = player:FindFirstChildOfClass("Backpack")
		local tool = (char and char:FindFirstChild("Rocket Launcher")) or (pack and pack:FindFirstChild("Rocket Launcher"))
		if hum and tool and tool.Parent ~= char then
			hum:EquipTool(tool)
		end
	end
	actionEvent:FireServer(name, aim)
end

btnMelee.MouseButton1Click:Connect(function()
	fire("Melee")
end)
btnRoar.MouseButton1Click:Connect(function()
	fire("Roar")
end)
btnGun.MouseButton1Click:Connect(function()
	fire("Rocket")
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not isNemesis() then
		return
	end
	if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonX then
		fire("Melee")
	elseif input.KeyCode == Enum.KeyCode.R or input.KeyCode == Enum.KeyCode.ButtonY then
		fire("Roar")
	end
end)

local function hookTool(tool)
	if tool:GetAttribute("NemesisBound") then
		return
	end
	tool:SetAttribute("NemesisBound", true)
	tool.Activated:Connect(function()
		fire("Rocket")
	end)
end

local function watchCharacter(char)
	stack.Visible = char ~= nil and char:GetAttribute("IsNemesis") == true
	if not char then
		return
	end
	char:GetAttributeChangedSignal("IsNemesis"):Connect(function()
		stack.Visible = char:GetAttribute("IsNemesis") == true
	end)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child.Name == "Rocket Launcher" then
			hookTool(child)
		end
	end)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, child in backpack:GetChildren() do
			if child:IsA("Tool") and child.Name == "Rocket Launcher" then
				hookTool(child)
			end
		end
		backpack.ChildAdded:Connect(function(child)
			if child:IsA("Tool") and child.Name == "Rocket Launcher" then
				hookTool(child)
			end
		end)
	end
end

player.CharacterAdded:Connect(watchCharacter)
if player.Character then
	watchCharacter(player.Character)
end

-- Guncangan kamera lokal saat raungan dekat.
local shake = 0
RunService.RenderStepped:Connect(function(dt)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		shake = 0
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local extra = char:GetAttribute("IsNemesis") and 0.55 or 0
	for _, model in CollectionService:GetTagged(Config.Tag) do
		if model:GetAttribute("Action") == "Roar" then
			local other = model:FindFirstChild("HumanoidRootPart")
			if other and hrp and (other.Position - hrp.Position).Magnitude < 22 then
				shake = math.max(shake, 0.22)
			end
		end
	end
	if shake > 0 then
		local t = os.clock()
		hum.CameraOffset = Vector3.new(math.sin(t * 48) * shake, extra + math.cos(t * 37) * shake * 0.6, 0)
		shake = math.max(0, shake - dt * 0.45)
	elseif char:GetAttribute("IsNemesis") then
		hum.CameraOffset = Vector3.new(0, extra, 0)
	end
end)
