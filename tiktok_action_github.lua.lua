local _API_KEY = ...  -- ローダーから受け取る
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- シークレット状態フラグ（プレイヤーID→true）
local secretPlayers = {}

-- ===== サーバーURL =====
local BASE_URL = "https://roblox.touwa-roblox.win"
local API_KEY = _API_KEY or "default"

local function fetchServerURL()
end

local function fetchKeyByOwner()
end

local function registerPlayerKey(player)
end

local function getServerURL()
	return BASE_URL
end

local SERVER_URL = "http://localhost:5000/get_action"
local NAME_URL = "http://localhost:5000/get_name"

-- ===== アクション名日本語マッピング =====
local actionJP = {
	explosion = "爆発",
	kill = "即死",
	ragdoll = "上方向吹き飛ばし",
	lowgravity = "低重力",
	zerogravity = "超低重力",
	highspeed = "高速移動",
	ultrahighspeed = "超高速",
	giant = "巨大化（10秒）",
	tiny = "小型化（10秒）",
	supersize = "超巨大化",
	darkness = "画面暗転",
	antigravity = "逆重力",
	randomblast = "ランダム吹き飛ばし",
	spin = "くるくる回転",
	teleport = "ランダムテレポート",
	freeze = "氷結",
	fire = "燃焼エフェクト",
	superfire = "超炎ダメージ",
	multibounce = "連続吹き飛ばし×5",
	giantexplosion = "巨大化爆発",
	sink = "地面に沈む",
	zoomup = "超高く飛ばす",
	drunk = "酔っぱらい",
	shrinkboom = "縮小爆発",
	slowmo = "スローモーション",
	invisible = "透明化",
	hyperexplosion = "連鎖爆発×5",
	flip = "逆さま吹き飛ばし",
	earthquake = "地震",
	blackhole = "ブラックホール",
	tornado = "竜巻",
	lion = "ライオン突進",
	dog = "犬突進",
	allkill = "全員即死",
	allexplosion = "全員爆発",
	meteor = "隕石落下",
	bigmeteor = "巨大隕石",
	meteorshower = "流星群",
	bomb = "爆弾",
	bigbomb = "巨大爆弾",
	randomexplosion = "爆発×3",
	storm = "嵐エフェクト",
	lightning = "雷エフェクト",
	fog = "霧エフェクト",
	fireworks = "花火エフェクト",
	redsky = "赤い空",
	night = "夜にする",
	rainbow = "虹色点滅",
	obstacle = "障害物",
	-- 良い効果
	heal = "体力全回復",
	invincible = "無敵化（8秒）",
	fly = "飛行モード（10秒）",
	highjump = "高ジャンプ（10秒）",
	superhighjump = "超高ジャンプ（10秒）",
	allhighspeed = "全員高速移動（8秒）",
	allhighjump = "全員高ジャンプ（8秒）",
	allheal = "全員体力回復",
	stageskip1 = "1ステージ進める",
	stageskip3 = "3ステージ進める",
	allstageskip1 = "全員1ステージ進める",
	checkpoint = "チェックポイントに戻す",
	resettostart = "リセット",
	nofall = "落下無敵（10秒）",
	goaltp = "ゴール",
	secret = "シークレット（超巨大化1分間）",
	jumpboost = "ジャンプ力UP！（10秒）",
	speedboost = "スピードUP！（10秒）",
	stageskip25 = "＋50ステージ",
	stageback25 = "－50ステージ",
	thunderstorm = "雷",
}

-- ===== 効果音再生 =====
local function playSound(soundId, parent, volume, pitch)
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. tostring(soundId)
	s.Volume = volume or 1
	s.PlaybackSpeed = pitch or 1
	s.Parent = parent or workspace
	s:Play()
	Debris:AddItem(s, 5)
	return s
end

-- ===== パーティクル生成 =====
local function makeParticles(parent, color, lifetime, speed, size)
	local att = Instance.new("Attachment")
	att.Parent = parent
	local pe = Instance.new("ParticleEmitter")
	pe.Color = ColorSequence.new(color or Color3.fromRGB(255,100,0))
	pe.LightEmission = 1
	pe.LightInfluence = 0
	pe.Lifetime = NumberRange.new(lifetime or 0.5, lifetime or 1)
	pe.Rate = 100
	pe.Speed = NumberRange.new(speed or 10, speed or 20)
	pe.Size = NumberSequence.new(size or 2)
	pe.Parent = att
	Debris:AddItem(att, 3)
	return pe
end

-- ===== 名前表示UI =====
local function createNameDisplay(player)
	local pg = player:WaitForChild("PlayerGui")
	if pg:FindFirstChild("GiftUI") then pg.GiftUI:Destroy() end

	local sg = Instance.new("ScreenGui")
	sg.Name = "GiftUI"
	sg.ResetOnSpawn = false
	sg.Parent = pg

	local frame = Instance.new("Frame")
	frame.Name = "GiftFrame"
	frame.Size = UDim2.new(0, 700, 0, 130)
	frame.Position = UDim2.new(0.5, -350, 0, 130)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 5
	frame.Parent = sg

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = ""
	nameLabel.ZIndex = 6
	nameLabel.Parent = frame

	local actionLabel = Instance.new("TextLabel")
	actionLabel.Name = "ActionLabel"
	actionLabel.Size = UDim2.new(1, 0, 0.45, 0)
	actionLabel.Position = UDim2.new(0, 0, 0.55, 0)
	actionLabel.BackgroundTransparency = 1
	actionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionLabel.TextScaled = true
	actionLabel.Font = Enum.Font.Gotham
	actionLabel.Text = ""
	actionLabel.ZIndex = 6
	actionLabel.Parent = frame
end

local function showGiftName(player, name, action)
	local gui = player.PlayerGui:FindFirstChild("GiftUI")
	if not gui then return end
	local frame = gui:FindFirstChild("GiftFrame")
	if not frame then return end
	local nameLabel = frame:FindFirstChild("NameLabel")
	local actionLabel = frame:FindFirstChild("ActionLabel")
	local jpAction = actionJP[action] or action
	if nameLabel then nameLabel.Text = name end
	if actionLabel then actionLabel.Text = jpAction end
	frame.Visible = true
	task.wait(3)
	frame.Visible = false
end

Players.PlayerAdded:Connect(function(player)
	task.wait(1)
	createNameDisplay(player)
end)
for _, p in ipairs(Players:GetPlayers()) do
	task.wait(1)
	createNameDisplay(p)
end

-- ===== ユーティリティ =====
local function applyVelocity(hrp, vx, vy, vz)
	local bf = Instance.new("BodyVelocity")
	bf.Velocity = Vector3.new(vx, vy, vz)
	bf.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bf.Parent = hrp
	Debris:AddItem(bf, 0.2)
end

local function spawnExplosion(pos, radius, pressure)
	local e = Instance.new("Explosion")
	e.Position = pos
	e.BlastRadius = radius
	e.BlastPressure = pressure
	e.DestroyJointRadiusPercent = 0
	e.Parent = workspace
end

-- 派手な爆発（光・煙・爆発音付き）
local function fancyExplosion(pos, radius, pressure, color)
	spawnExplosion(pos, radius, pressure)
	-- 光球
	local flash = Instance.new("Part")
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(radius*0.8, radius*0.8, radius*0.8)
	flash.Position = pos
	flash.Anchored = true
	flash.CanCollide = false
	flash.BrickColor = BrickColor.new("Bright yellow")
	flash.Material = Enum.Material.Neon
	flash.CastShadow = false
	flash.Parent = workspace
	-- 光球フェード
	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(flash, ti, {Size = Vector3.new(0.1,0.1,0.1), Transparency = 1}):Play()
	Debris:AddItem(flash, 0.4)
	-- パーティクル
	makeParticles(flash, color or Color3.fromRGB(255,120,0), 1, 30, 3)
	-- 効果音
	playSound(3691985274, workspace, 1.5, math.random(90,110)/100)
end

-- ===== アクション実行 =====
local function executeAction(actionName, playerName)
	local players = Players:GetPlayers()
	if #players == 0 then return end

	local target = nil
	for _, p in ipairs(players) do
		if p.Name == playerName then target = p break end
	end
	if not target then target = players[math.random(1, #players)] end

	local char = target.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not hrp or not hum then return end

	-- シークレット状態中は妨害・サイズ変更系をブロック
	local BLOCKED_IN_SECRET = {
		kill=true, ragdoll=true, lowgravity=true, zerogravity=true,
		antigravity=true, randomblast=true, spin=true, teleport=true,
		freeze=true, superfire=true, multibounce=true, giantexplosion=true,
		sink=true, zoomup=true, drunk=true, shrinkboom=true, slowmo=true,
		hyperexplosion=true, flip=true, earthquake=true, blackhole=true,
		tornado=true, allkill=true, allexplosion=true, meteorshower=true,
		bomb=true, bigbomb=true, randomexplosion=true, storm=true,
		lightning=true, thunderstorm=true, obstacle=true,
		giant=true, tiny=true, supersize=true, stageback25=true, stageskip25=false,
		resettostart=true,
	}
	if secretPlayers[target.UserId] and BLOCKED_IN_SECRET[actionName] then
		return
	end
	if actionName == "explosion" then
		fancyExplosion(hrp.Position, 10, 500000)
		applyVelocity(hrp, math.random(-30,30), 120, math.random(-30,30))
		playSound(3691985274, hrp, 2)

	elseif actionName == "kill" then
		-- 即死演出
		playSound(4612378735, hrp, 2)
		fancyExplosion(hrp.Position, 5, 0, Color3.fromRGB(200,0,0))
		hum.Health = 0

	elseif actionName == "ragdoll" then
		playSound(3691985274, hrp, 1.5)
		applyVelocity(hrp, math.random(-60,60), 200, math.random(-60,60))
		makeParticles(hrp, Color3.fromRGB(255,200,0), 1, 20, 2)

	elseif actionName == "lowgravity" then
		-- 派手な低重力演出
		workspace.Gravity = 20
		playSound(2645858750, hrp, 1.5) -- woosh
		-- 上昇する青いパーティクル
		local att = Instance.new("Attachment")
		att.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.Color = ColorSequence.new(Color3.fromRGB(100,180,255))
		pe.LightEmission = 1
		pe.Lifetime = NumberRange.new(1, 2)
		pe.Rate = 50
		pe.Speed = NumberRange.new(5, 15)
		pe.Size = NumberSequence.new(1.5)
		pe.Rotation = NumberRange.new(0, 360)
		pe.RotSpeed = NumberRange.new(-90, 90)
		pe.Parent = att
		-- 画面エフェクト（空が薄くなる演出用にLightingを変化）
		local l = game:GetService("Lighting")
		local origBright = l.Brightness
		l.Brightness = 4
		task.wait(10)
		l.Brightness = origBright
		pe.Enabled = false
		Debris:AddItem(att, 2)
		workspace.Gravity = 196.2

	elseif actionName == "zerogravity" then
		workspace.Gravity = 2
		playSound(2645858750, hrp, 2)
		makeParticles(hrp, Color3.fromRGB(0,255,255), 2, 10, 2)
		task.wait(10)
		workspace.Gravity = 196.2

	elseif actionName == "highspeed" then
		hum.WalkSpeed = 80
		playSound(2545110825, hrp, 1.5) -- speed woosh
		makeParticles(hrp, Color3.fromRGB(255,255,0), 0.5, 30, 1.5)
		task.wait(8)
		hum.WalkSpeed = 16

	elseif actionName == "ultrahighspeed" then
		hum.WalkSpeed = 200
		playSound(2545110825, hrp, 2, 1.5)
		makeParticles(hrp, Color3.fromRGB(255,165,0), 0.3, 50, 2)
		task.wait(8)
		hum.WalkSpeed = 16

	elseif actionName == "giant" then
		-- 巨大化（10秒）3倍・良い効果
		playSound(4612378735, hrp, 2, 0.6)
		makeParticles(hrp, Color3.fromRGB(100,255,100), 1, 20, 3)
		char:ScaleTo(3)
		fancyExplosion(hrp.Position, 8, 0, Color3.fromRGB(0,255,100))
		task.spawn(function()
			task.wait(10)
			if char and char.Parent then
				char:ScaleTo(1)
				playSound(4612378735, hrp, 1.5, 2)
			end
		end)

	elseif actionName == "tiny" then
		char:ScaleTo(0.3)
		playSound(4612378735, hrp, 1.5, 2)
		task.wait(10)
		char:ScaleTo(1)

	elseif actionName == "supersize" then
		char:ScaleTo(6)
		playSound(4612378735, hrp, 2, 0.5)
		makeParticles(hrp, Color3.fromRGB(255,0,255), 1, 20, 4)
		task.wait(8)
		char:ScaleTo(1)

	elseif actionName == "darkness" then
		local l = game:GetService("Lighting")
		l.Brightness = 0
		playSound(1124958144, workspace, 1.5) -- dramatic sting
		task.wait(8)
		l.Brightness = 2

	elseif actionName == "antigravity" then
		workspace.Gravity = -50
		playSound(2645858750, hrp, 2, 0.5)
		makeParticles(hrp, Color3.fromRGB(180,0,255), 1.5, 20, 2)
		task.wait(8)
		workspace.Gravity = 196.2

	elseif actionName == "randomblast" then
		playSound(2645858750, hrp, 1.5)
		for i = 1, 3 do
			applyVelocity(hrp, math.random(-100,100), math.random(50,150), math.random(-100,100))
			task.wait(1.5)
		end

	elseif actionName == "spin" then
		playSound(2545110825, hrp, 1)
		for i = 1, 20 do
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(36), 0)
			task.wait(0.05)
		end

	elseif actionName == "teleport" then
		local rx = math.random(-100, 100)
		local rz = math.random(-100, 100)
		playSound(1548195490, hrp, 1.5)
		fancyExplosion(hrp.Position, 3, 0, Color3.fromRGB(100,0,255))
		hrp.CFrame = CFrame.new(rx, hrp.Position.Y + 5, rz)
		fancyExplosion(hrp.Position, 3, 0, Color3.fromRGB(100,0,255))

	elseif actionName == "freeze" then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		playSound(2545110825, hrp, 1.5, 0.5)
		-- 氷エフェクト
		local ice = Instance.new("Part")
		ice.Size = Vector3.new(4, 4, 4)
		ice.Position = hrp.Position
		ice.Anchored = true
		ice.CanCollide = false
		ice.BrickColor = BrickColor.new("Cyan")
		ice.Material = Enum.Material.Ice
		ice.Transparency = 0.4
		ice.Parent = workspace
		Debris:AddItem(ice, 6)
		task.wait(6)
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		-- 解凍エフェクト
		fancyExplosion(hrp.Position, 4, 0, Color3.fromRGB(0,200,255))

	elseif actionName == "fire" then
		local fire = Instance.new("Fire")
		fire.Size = 5
		fire.Heat = 10
		fire.Parent = hrp
		playSound(1283240118, hrp, 1.5)
		task.wait(8)
		fire:Destroy()

	elseif actionName == "superfire" then
		local fire = Instance.new("Fire")
		fire.Size = 10
		fire.Heat = 25
		fire.Parent = hrp
		playSound(1283240118, hrp, 2, 0.7)
		for i = 1, 8 do
			hum.Health = math.max(0, hum.Health - 8)
			task.wait(1)
		end
		fire:Destroy()

	elseif actionName == "multibounce" then
		playSound(3691985274, hrp, 1.5)
		for i = 1, 5 do
			applyVelocity(hrp, math.random(-80,80), math.random(80,180), math.random(-80,80))
			makeParticles(hrp, Color3.fromRGB(255,100,0), 0.5, 20, 2)
			task.wait(1.2)
		end

	elseif actionName == "giantexplosion" then
		char:ScaleTo(3)
		playSound(4612378735, hrp, 2, 0.5)
		task.wait(2)
		fancyExplosion(hrp.Position, 20, 800000, Color3.fromRGB(255,50,0))
		applyVelocity(hrp, math.random(-50,50), 200, math.random(-50,50))
		task.wait(1)
		char:ScaleTo(1)

	elseif actionName == "sink" then
		playSound(2545110825, hrp, 1, 0.5)
		for i = 1, 10 do
			hrp.CFrame = hrp.CFrame + Vector3.new(0, -2, 0)
			task.wait(0.1)
		end

	elseif actionName == "zoomup" then
		playSound(2645858750, hrp, 2, 2)
		makeParticles(hrp, Color3.fromRGB(255,255,100), 1, 60, 3)
		applyVelocity(hrp, 0, 500, 0)

	elseif actionName == "drunk" then
		-- 気持ち悪い酔っぱらい演出
		local l = game:GetService("Lighting")
		local blur = Instance.new("BlurEffect")
		blur.Size = 0
		blur.Parent = l
		local colorCorr = Instance.new("ColorCorrectionEffect")
		colorCorr.Saturation = 0
		colorCorr.Parent = l
		-- 星・泡パーティクル
		local att = Instance.new("Attachment")
		att.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.LightEmission = 1
		pe.Lifetime = NumberRange.new(1, 2)
		pe.Rate = 30
		pe.Speed = NumberRange.new(3, 8)
		pe.Size = NumberSequence.new(1.5)
		pe.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,255,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180,0,180)),
		})
		pe.RotSpeed = NumberRange.new(-180, 180)
		pe.Parent = att
		-- 気持ち悪い緑・黄色・紫で点滅
		local sickColors = {
			Color3.fromRGB(0,180,0),
			Color3.fromRGB(180,180,0),
			Color3.fromRGB(150,0,150),
			Color3.fromRGB(0,150,0),
			Color3.fromRGB(200,200,0),
		}
		playSound(2645858750, hrp, 1.5, 0.4)
		for i = 1, 10 do
			local col = sickColors[(i % #sickColors) + 1]
			colorCorr.TintColor = col
			blur.Size = math.abs(math.sin(i * 0.8)) * 25 + 5
			l.Ambient = col
			applyVelocity(hrp,
				math.sin(i * 1.3) * 65,
				math.abs(math.sin(i * 0.7)) * 18,
				math.cos(i * 1.1) * 65
			)
			task.wait(0.7)
		end
		blur:Destroy()
		colorCorr:Destroy()
		l.Ambient = Color3.fromRGB(70,70,70)
		pe.Enabled = false
		Debris:AddItem(att, 2)

	elseif actionName == "shrinkboom" then
		char:ScaleTo(0.1)
		playSound(2545110825, hrp, 2, 2)
		task.wait(2)
		fancyExplosion(hrp.Position, 15, 700000, Color3.fromRGB(255,200,0))
		applyVelocity(hrp, math.random(-40,40), 160, math.random(-40,40))
		task.wait(0.5)
		char:ScaleTo(1)

	elseif actionName == "slowmo" then
		hum.WalkSpeed = 2
		hum.JumpPower = 10
		playSound(2545110825, hrp, 1, 0.3)
		task.wait(10)
		hum.WalkSpeed = 16
		hum.JumpPower = 50

	elseif actionName == "invisible" then
		playSound(1548195490, hrp, 1.5)
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.Transparency = 1 end
		end
		task.wait(8)
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.Transparency = 0 end
		end
		playSound(1548195490, hrp, 1.5)

	elseif actionName == "hyperexplosion" then
		playSound(3691985274, hrp, 2)
		for i = 1, 5 do
			fancyExplosion(
				hrp.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)),
				12, 600000, Color3.fromRGB(255,80,0))
			task.wait(0.5)
		end
		applyVelocity(hrp, math.random(-60,60), 250, math.random(-60,60))

	elseif actionName == "flip" then
		playSound(2645858750, hrp, 1.5, 1.5)
		applyVelocity(hrp, math.random(-20,20), 300, math.random(-20,20))
		hrp.CFrame = hrp.CFrame * CFrame.Angles(math.pi, 0, 0)

	elseif actionName == "earthquake" then
		playSound(3691985274, workspace, 2, 0.5)
		for i = 1, 10 do
			for _, p in ipairs(Players:GetPlayers()) do
				local c = p.Character
				if c then
					local h = c:FindFirstChild("HumanoidRootPart")
					if h then
						applyVelocity(h, math.random(-30,30), math.random(10,40), math.random(-30,30))
						fancyExplosion(h.Position + Vector3.new(math.random(-5,5),0,math.random(-5,5)), 3, 0)
					end
				end
			end
			task.wait(0.5)
		end

	elseif actionName == "blackhole" then
		local center = hrp.Position
		playSound(1124958144, workspace, 2, 0.5)
		-- ブラックホール視覚エフェクト
		local bh = Instance.new("Part")
		bh.Shape = Enum.PartType.Ball
		bh.Size = Vector3.new(10,10,10)
		bh.Position = center
		bh.Anchored = true
		bh.CanCollide = false
		bh.BrickColor = BrickColor.new("Black")
		bh.Material = Enum.Material.Neon
		bh.Parent = workspace
		makeParticles(bh, Color3.fromRGB(80,0,180), 1, 30, 3)
		for i = 1, 6 do
			for _, p in ipairs(Players:GetPlayers()) do
				local c = p.Character
				if c then
					local h = c:FindFirstChild("HumanoidRootPart")
					if h then
						local dir = (center - h.Position).Unit
						local bv = Instance.new("BodyVelocity")
						bv.Velocity = dir * 40
						bv.MaxForce = Vector3.new(1e6,1e6,1e6)
						bv.Parent = h
						Debris:AddItem(bv, 0.2)
					end
				end
			end
			task.wait(0.5)
		end
		fancyExplosion(center, 20, 900000, Color3.fromRGB(80,0,180))
		Debris:AddItem(bh, 0.1)

	elseif actionName == "tornado" then
		-- 超超派手な竜巻演出
		playSound(3167705355, workspace, 2, 0.5)
		local center = hrp.Position
		local height = 150
		-- デブリを大量に螺旋状生成（80個）
		for i = 1, 80 do
			task.spawn(function()
				local p = Instance.new("Part")
				local partSize = math.random(10, 50) / 10
				p.Size = Vector3.new(partSize, partSize * 0.5, partSize)
				p.Anchored = false
				p.CanCollide = true
				local mats = {Enum.Material.Slate, Enum.Material.Wood, Enum.Material.Grass, Enum.Material.Rock, Enum.Material.Brick}
				p.Material = mats[math.random(1,#mats)]
				local cols = {"Dark grey","Reddish brown","Medium stone grey","Brown","Dark tan","Sand red"}
				p.BrickColor = BrickColor.new(cols[math.random(1,#cols)])
				p.CastShadow = false
				p.Parent = workspace
				local angle = (i / 80) * math.pi * 12
				local r = math.random(2, 20)
				local y = (i / 80) * height
				p.Position = center + Vector3.new(math.cos(angle)*r, y, math.sin(angle)*r)
				local speed = math.random(80, 140)
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = Vector3.new(math.cos(angle+math.pi/2)*speed, math.random(30,80), math.sin(angle+math.pi/2)*speed)
				bv.MaxForce = Vector3.new(1e5,1e5,1e5)
				bv.Parent = p
				Debris:AddItem(bv, 0.5)
				Debris:AddItem(p, 6)
			end)
		end
		-- 光る竜巻コア（螺旋Neon柱・24本）
		for i = 1, 24 do
			local glow = Instance.new("Part")
			glow.Size = Vector3.new(1.5, 10, 1.5)
			local angle = (i/24) * math.pi * 2
			local r = i * 0.5
			glow.Position = center + Vector3.new(math.cos(angle)*r, i*5, math.sin(angle)*r)
			glow.Anchored = true
			glow.CanCollide = false
			glow.CastShadow = false
			local neonCols = {"Cyan","Bright blue","Hot pink","Bright yellow","Lime green","Bright orange"}
			glow.BrickColor = BrickColor.new(neonCols[((i-1)%#neonCols)+1])
			glow.Material = Enum.Material.Neon
			glow.Transparency = 0.2
			glow.Parent = workspace
			Debris:AddItem(glow, 5)
		end
		-- 落雷8発
		for i = 1, 8 do
			task.spawn(function()
				task.wait(i * 0.3)
				local bolt = Instance.new("Part")
				bolt.Size = Vector3.new(1, 100, 1)
				bolt.Position = center + Vector3.new(math.random(-8,8), 50, math.random(-8,8))
				bolt.Anchored = true
				bolt.CanCollide = false
				bolt.BrickColor = BrickColor.new("Bright yellow")
				bolt.Material = Enum.Material.Neon
				bolt.CastShadow = false
				bolt.Parent = workspace
				Debris:AddItem(bolt, 0.15)
				playSound(3167705355, workspace, 1.5, 2)
			end)
		end
		-- 空を暗くする
		local l = game:GetService("Lighting")
		local origBright = l.Brightness
		l.Brightness = 0.3
		-- プレイヤーを激しく巻き上げ（螺旋）
		for i = 1, 16 do
			local rad = math.rad(i * 22.5)
			applyVelocity(hrp, math.cos(rad)*120, 60, math.sin(rad)*120)
			task.wait(0.2)
		end
		-- 全速度をリセットして真上に確実に飛ばす
		local upBV = Instance.new("BodyVelocity")
		upBV.Velocity = Vector3.new(0, 120, 0)
		upBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		upBV.Parent = hrp
		playSound(3691985274, hrp, 2, 0.5)
		makeParticles(hrp, Color3.fromRGB(100,200,255), 1, 30, 3)
		task.wait(0.4)
		upBV:Destroy()
		task.wait(2)
		l.Brightness = origBright

	elseif actionName == "lion" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- ライオンモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright yellow")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://16817687634"
		mesh.TextureId = "rbxassetid://16817689058"
		mesh.Scale = Vector3.new(3, 3, 3) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		playSound(1249690399, workspace, 3, 0.8)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			playSound(1249690399, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back1")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(1249690399, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				-- ライオンも追従
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						local lionFront = Vector3.new(playerPos.X, playerPos.Y, playerPos.Z)
						lion.CFrame = CFrame.new(lionFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			playSound(1249690399, workspace, 2, 0.5)
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "lion" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- ライオンモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright yellow")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://16817687634"
		mesh.TextureId = "rbxassetid://16817689058"
		mesh.Scale = Vector3.new(3, 3, 3) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		playSound(1249690399, workspace, 3, 0.8)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			playSound(1249690399, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back1")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(1249690399, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				-- ライオンも追従
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						local lionFront = Vector3.new(playerPos.X, playerPos.Y, playerPos.Z)
						lion.CFrame = CFrame.new(lionFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			playSound(1249690399, workspace, 2, 0.5)
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "lion" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- ライオンモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright yellow")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://16817687634"
		mesh.TextureId = "rbxassetid://16817689058"
		mesh.Scale = Vector3.new(3, 3, 3) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		playSound(1249690399, workspace, 3, 0.8)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			playSound(1249690399, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back1")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(1249690399, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				-- ライオンも追従
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						local lionFront = Vector3.new(playerPos.X, playerPos.Y, playerPos.Z)
						lion.CFrame = CFrame.new(lionFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			playSound(1249690399, workspace, 2, 0.5)
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "lion" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- ライオンモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright yellow")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://16817687634"
		mesh.TextureId = "rbxassetid://16817689058"
		mesh.Scale = Vector3.new(3, 3, 3) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		playSound(1249690399, workspace, 3, 0.8)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			playSound(1249690399, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back1")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(1249690399, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				-- ライオンも追従
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						local lionFront = Vector3.new(playerPos.X, playerPos.Y, playerPos.Z)
						lion.CFrame = CFrame.new(lionFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			playSound(1249690399, workspace, 2, 0.5)
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "chimpa" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
			lion.Size = Vector3.new(63, 45, 27) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Brown")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://116835248081696"
		mesh.TextureId = "rbxassetid://135986129901008"
			mesh.Scale = Vector3.new(0.9, 0.9, 0.9) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://131679067155488"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
			task.delay(10, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- +100テキスト表示
			local Players2 = game:GetService("Players")
			for _, p in ipairs(Players2:GetPlayers()) do
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "ChimpaText"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = p.PlayerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = "+100"
				label.TextColor3 = Color3.fromRGB(0, 255, 100)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 10)
			end

			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward100")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "elephant" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(140, 100, 60) -- 20倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Hot pink")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://129250442843650"
		mesh.TextureId = "rbxassetid://124204506577115"
		mesh.Scale = Vector3.new(5, 5, 5) -- 20倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://139678867434517"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(30, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- -200テキスト表示
			local Players2 = game:GetService("Players")
			for _, p in ipairs(Players2:GetPlayers()) do
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "ElephantText"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = p.PlayerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = "-200"
				label.TextColor3 = Color3.fromRGB(255, 50, 50)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 30)
			end

			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back200")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "sixseven" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(52, 49, 24) -- 20倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright blue")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://122075817917987"
		mesh.TextureId = "rbxassetid://114980445321940"
		mesh.Scale = Vector3.new(20, 20, 20) -- 20倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://138959447988096"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(8, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- +50テキスト表示
			local Players2 = game:GetService("Players")
			for _, p in ipairs(Players2:GetPlayers()) do
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "SixSevenText"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = p.PlayerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = "-50"
				label.TextColor3 = Color3.fromRGB(255, 50, 50)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 8)
			end

			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- sixseven_back50：ステージ変更のみ・テレポートなし
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("sixseven_back50")
			end
			task.wait(0.5)
			connFinal:Disconnect()

			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- 8秒かけてTweenで移動
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + pushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "cow" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(7, 5, 3)
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("White")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://886347883"
		mesh.TextureId = "rbxassetid://886347886"
		mesh.Scale = Vector3.new(0.25, 0.25, 0.25)
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://130603216665013"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(8, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- +50テキスト表示
			local Players2 = game:GetService("Players")
			for _, p in ipairs(Players2:GetPlayers()) do
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "CowText"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = p.PlayerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = "+50"
				label.TextColor3 = Color3.fromRGB(0, 255, 100)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 8)
			end

			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward50")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "noob" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(63, 45, 27) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright yellow")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://4085411119"
		mesh.TextureId = "rbxassetid://4085411180"
		mesh.Scale = Vector3.new(9, 9, 9) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://117844524716388"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(10, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back100")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "bacon" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(63, 45, 27) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Reddish brown")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://1701719064"
		mesh.TextureId = "rbxassetid://1701719148"
		mesh.Scale = Vector3.new(9, 9, 9) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://139591383949364"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(10, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward100")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "earth" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(315, 225, 135) -- 15倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright blue")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://9293030426"
		mesh.TextureId = "rbxassetid://9293030547"
		mesh.Scale = Vector3.new(45, 45, 45) -- 15倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://138193763653015"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(30, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- ランダム数字を画面中央に表示
			local Players = game:GetService("Players")
			local winValues = {-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10}
			-- -10から+10の20個（0含む21個から20個選ぶため0を除外して-10〜-1と1〜10の20個）
			local winValues20 = {}
			for w = -50, 50 do
				if w ~= 0 then
					table.insert(winValues20, w)
				end
			end
			local randomWin = winValues20[math.random(1, #winValues20)]
			local winText = (randomWin > 0 and "+" or "") .. tostring(randomWin) .. "WIN"
			local winColor = randomWin > 0 and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
			for _, p in ipairs(Players:GetPlayers()) do
				local playerGui = p.PlayerGui
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "EarthWin"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = playerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = winText
				label.TextColor3 = winColor
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 30)
			end

			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("dragon_random")
			end
			task.wait(0.5)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "dragon" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 通常サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Really red")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://90273539962742"
		mesh.TextureId = "rbxassetid://99240142801503"
		mesh.Scale = Vector3.new(3, 3, 3)
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://140591547158413"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(25, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- ランダム数字を画面中央に表示
			local Players = game:GetService("Players")
			local winValues = {-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10}
			-- -10から+10の20個（0含む21個から20個選ぶため0を除外して-10〜-1と1〜10の20個）
			local winValues20 = {-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9,10}
			local randomWin = winValues20[math.random(1, #winValues20)]
			local winText = (randomWin > 0 and "+" or "") .. tostring(randomWin) .. "WIN"
			local winColor = randomWin > 0 and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
			for _, p in ipairs(Players:GetPlayers()) do
				local playerGui = p.PlayerGui
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "DragonWin"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = playerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = winText
				label.TextColor3 = winColor
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 25)
			end

			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("dragon_random")
			end
			task.wait(0.5)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "rocket" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 通常サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright red")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://14016125493"
		mesh.TextureId = "rbxassetid://14016125552"
		mesh.Scale = Vector3.new(3, 3, 3)
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://133382901512851"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(20, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward200")
			end
			task.wait(0.5)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "ufo" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 通常サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Cyan")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://92432375432532"
		mesh.TextureId = "rbxassetid://72331969877406"
		mesh.Scale = Vector3.new(3, 3, 3)
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://137655472188899"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(20, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back200")
			end
			task.wait(0.5)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "kiwi" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 通常サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright green")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://6282201900"
		mesh.TextureId = "rbxassetid://6282202252"
		mesh.Scale = Vector3.new(3, 3, 3)
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://82136668674568"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(5, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back30")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "gacha" then
		-- ガチャ：ランダムでアクション発動
		-- 確率：ウシ24.75%・シックスセブン24.75%・チンパンジーニ24.75%・バレリーナ24.75%・エレファント1%
		local rand = math.random(1, 10000)
		local selected
		if rand <= 100 then
			selected = "elephant"    -- 1%
		elseif rand <= 2575 then
			selected = "cow"         -- 24.75%
		elseif rand <= 5050 then
			selected = "sixseven"    -- 24.75%
		elseif rand <= 7525 then
			selected = "chimpa"      -- 24.75%
		else
			selected = "ballerina"   -- 24.75%
		end
		executeAction(selected, playerName)

	elseif actionName == "luffy" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(56, 42, 28) -- 7倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright yellow")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://16094349325"
		mesh.TextureId = "rbxassetid://16094349339"
		mesh.Scale = Vector3.new(8.4, 8.4, 8.4) -- 7倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://134650193771026"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(5, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back10")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "chopper" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(210, 150, 90) -- 10倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Bright red")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://6996210515"
		mesh.TextureId = "rbxassetid://6996210569"
		mesh.Scale = Vector3.new(30, 30, 30) -- 10倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://100912973655395"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
		task.delay(5, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward10")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "ballerina" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- バレリーナモデル作成
		local lion = Instance.new("Part")
			lion.Size = Vector3.new(1260, 900, 540) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Pink")
		local dirToPlayerLion = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerLion)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://78496759198059"
		mesh.TextureId = "rbxassetid://133711531628652"
			mesh.Scale = Vector3.new(60, 60, 60) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		local ballerinaSound = Instance.new("Sound")
		ballerinaSound.SoundId = "rbxassetid://107504695212807"
		ballerinaSound.Volume = 2
		ballerinaSound.Looped = false
		ballerinaSound.Parent = workspace
		ballerinaSound:Play()
			task.delay(10, function()
			if ballerinaSound and ballerinaSound.Parent then
				ballerinaSound:Stop()
				ballerinaSound:Destroy()
			end
		end)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- -100テキスト表示
			local Players2 = game:GetService("Players")
			for _, p in ipairs(Players2:GetPlayers()) do
				local screenGui = Instance.new("ScreenGui")
				screenGui.Name = "BallerinaText"
				screenGui.ResetOnSpawn = false
				screenGui.Parent = p.PlayerGui
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.8, 0)
				label.Position = UDim2.new(0, 0, 0.1, 0)
				label.BackgroundTransparency = 1
				label.Text = "-100"
				label.TextColor3 = Color3.fromRGB(255, 50, 50)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.new(0,0,0)
				label.Parent = screenGui
				game:GetService("Debris"):AddItem(screenGui, 10)
			end

			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			-- 効果音は最初の1つのみ
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back100")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			-- なし
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.03)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						lion.CFrame = CFrame.new(
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z),
							Vector3.new(playerPos.X, playerPos.Y, playerPos.Z) + currentPushDir
						)
					end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			-- 音楽は3秒で自動停止
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "tungsahur" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- トゥントゥントゥンサーフールモデル作成（10倍サイズ・正面向き・透明パーツなし）
		local lion = Instance.new("Part")
			lion.Size = Vector3.new(140, 100, 60) -- 20倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("White")
		-- 正面がプレイヤーに向くようにCFrameを設定
		local dirToPlayer = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayer)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://82464974337955"
		mesh.TextureId = "rbxassetid://105445253181063"
			mesh.Scale = Vector3.new(20, 20, 20) -- 20倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		playSound(138857089980331, workspace, 3, 0.8)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			playSound(138857089980331, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward20")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(138857089980331, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				-- ライオンも追従
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						local lionFront = Vector3.new(playerPos.X, playerPos.Y, playerPos.Z)
						lion.CFrame = CFrame.new(lionFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: 退場
			playSound(138857089980331, workspace, 2, 0.5)
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "monkey" then
		local lionSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		lionSpawnPos = Vector3.new(lionSpawnPos.X, hrp.Position.Y + 2, lionSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		-- ライオンモデル作成
		local lion = Instance.new("Part")
		lion.Size = Vector3.new(21, 15, 9) -- 3倍サイズ
		lion.Transparency = 0
		lion.BrickColor = BrickColor.new("Brown")
		local dirToPlayerMonkey = (Vector3.new(hrp.Position.X, lionSpawnPos.Y, hrp.Position.Z) - lionSpawnPos).Unit
		lion.CFrame = CFrame.new(lionSpawnPos, lionSpawnPos + dirToPlayerMonkey)
		lion.Anchored = true
		lion.CanCollide = false
		lion.CastShadow = false
		lion.Material = Enum.Material.SmoothPlastic
		lion.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://22111333"
		mesh.TextureId = "rbxassetid://22111313"
		mesh.Scale = Vector3.new(3, 3, 3) -- 3倍スケール
		mesh.Parent = lion

		Debris:AddItem(lion, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, lion)
		end

		playSound(2473639958, workspace, 3, 0.8)
		makeParticles(lion, Color3.fromRGB(255, 200, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not lion.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - lion.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = lion.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				lion.CFrame = CFrame.new(newPos, target)
				end

			playSound(2473639958, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 50, 0), 0.5, 60, 2)

			-- 押す方向を決定（ライオン→プレイヤーの逆方向）
			local pushDir = (hrp.Position - lion.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			-- ライオンをプレイヤー正面に密着
			lion.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum and hum.WalkSpeed or 16
			local origJumpPower = hum and hum.JumpPower or 50
			if hum then hum.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125 -- 5倍速

			-- LionCpEventを準備
			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			-- lionbackで3ステージ一気に戻してセーブポイント位置を取得
			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("back1")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			-- セーブポイント方向を計算
			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(2473639958, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			-- スムーズに押し戻し（TweenServiceで滑らか移動）
			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				-- ライオンも追従
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not lion.Parent then break end
						local playerPos = hrp.Position
						local lionFront = Vector3.new(playerPos.X, playerPos.Y, playerPos.Z)
						lion.CFrame = CFrame.new(lionFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			-- 操作を完全復旧
			bv.Velocity = Vector3.new(0, 0, 0)
			bv:Destroy()
			task.wait(0.1)
			if hum and hum.Parent then
				hum.PlatformStand = false
				hum.WalkSpeed = origWalkSpeed
				hum.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum and hum.Parent then
					hum.PlatformStand = false
					hum.WalkSpeed = origWalkSpeed
					hum.JumpPower = origJumpPower
				end
			end)

			-- Phase3: ライオン退場
			playSound(2473639958, workspace, 2, 0.5)
			makeParticles(lion, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)

			lion.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = lion
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(lion, 2)
		end)

	elseif actionName == "dog" then
		local dogSpawnPos = hrp.Position + hrp.CFrame.LookVector * 35
		dogSpawnPos = Vector3.new(dogSpawnPos.X, hrp.Position.Y + 2, dogSpawnPos.Z)
		local baseY = hrp.Position.Y + 2

		local dog = Instance.new("Part")
		dog.Size = Vector3.new(25, 20, 15) -- 5倍サイズ
		dog.Transparency = 0
		dog.BrickColor = BrickColor.new("Bright orange")
		local dirToPlayerDog = (Vector3.new(hrp.Position.X, dogSpawnPos.Y, hrp.Position.Z) - dogSpawnPos).Unit
		dog.CFrame = CFrame.new(dogSpawnPos, dogSpawnPos + dirToPlayerDog)
		dog.Anchored = true
		dog.CanCollide = false
		dog.CastShadow = false
		dog.Material = Enum.Material.SmoothPlastic
		dog.Parent = workspace

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://2366123453"
		mesh.TextureId = "rbxassetid://2366123527"
		mesh.Scale = Vector3.new(5, 5, 5) -- 5倍スケール
		mesh.Parent = dog

		Debris:AddItem(dog, 30)
		Debris:AddItem(aura, 30)

		local rs = game:GetService("ReplicatedStorage")
		local re = rs:FindFirstChild("LionCamEvent")
		if not re then
			re = Instance.new("RemoteEvent")
			re.Name = "LionCamEvent"
			re.Parent = rs
		end
		for _, p in ipairs(Players:GetPlayers()) do
			re:FireClient(p, dog)
		end

		playSound(132514715, workspace, 3, 0.8)
		makeParticles(dog, Color3.fromRGB(255, 150, 0), 1, 40, 2)

		local obbyBindable = rs:FindFirstChild("ObbyBindable")

		task.spawn(function()
			-- Phase1: 突進
			for i = 1, 80 do
				task.wait(0.05)
				if not dog.Parent or not hrp.Parent then return end
				local target = Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
				local dir = (target - dog.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude < 14 then break end
				dir = dir.Unit
				local newPos = dog.Position + dir * 55 * 0.05
				newPos = Vector3.new(newPos.X, baseY, newPos.Z)
				dog.CFrame = CFrame.new(newPos, target)
				end

			playSound(132514715, workspace, 3, 1.2)
			makeParticles(hrp, Color3.fromRGB(255, 100, 0), 0.5, 60, 2)

			local pushDir = (hrp.Position - dog.Position)
			pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

			dog.CFrame = CFrame.new(
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z) - pushDir * 8,
				Vector3.new(hrp.Position.X, baseY, hrp.Position.Z)
			)

			-- Phase2: 3ステージ押し戻し
			local hum2 = char:FindFirstChild("Humanoid")
			local origWalkSpeed = hum2 and hum2.WalkSpeed or 16
			local origJumpPower = hum2 and hum2.JumpPower or 50
			if hum2 then hum2.PlatformStand = true end

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bv.Velocity = Vector3.new(0, 0, 0)
			bv.Parent = hrp

			local speed = 125

			local cpEvent = rs:FindFirstChild("LionCpEvent")
			if not cpEvent then
				cpEvent = Instance.new("BindableEvent")
				cpEvent.Name = "LionCpEvent"
				cpEvent.Parent = rs
			end

			local finalCpPos = nil
			local connFinal = cpEvent.Event:Connect(function(pos)
				finalCpPos = pos
			end)
			if obbyBindable then
				obbyBindable:Fire("forward1")
			end
			task.wait(0.1)
			connFinal:Disconnect()

			local currentPushDir = pushDir
			if finalCpPos then
				local dir = (finalCpPos - hrp.Position)
				dir = Vector3.new(dir.X, 0, dir.Z)
				if dir.Magnitude > 1 then
					currentPushDir = dir.Unit
				end
			end

			playSound(132514715, workspace, 2, 0.8)
			makeParticles(hrp, Color3.fromRGB(255, 150, 0), 0.3, 20, 1)

			local TweenService = game:GetService("TweenService")
			if finalCpPos then
				local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = TweenService:Create(hrp, tweenInfo, {
					CFrame = CFrame.new(finalCpPos)
				})
				task.spawn(function()
					while tween.PlaybackState ~= Enum.PlaybackState.Completed do
						task.wait(0.05)
						if not hrp.Parent or not dog.Parent then break end
						local playerPos = hrp.Position
						local dogFront = Vector3.new(playerPos.X, baseY, playerPos.Z) - currentPushDir * 8
						dog.CFrame = CFrame.new(dogFront, Vector3.new(playerPos.X, baseY, playerPos.Z))
								end
				end)
				tween:Play()
				tween.Completed:Wait()
			end
			bv.Velocity = Vector3.new(0, 0, 0)
			task.wait(0.1)

			bv:Destroy()
			if hum2 and hum2.Parent then
				hum2.PlatformStand = false
				hum2.WalkSpeed = origWalkSpeed
				hum2.JumpPower = origJumpPower
			end
			task.spawn(function()
				task.wait(1)
				if hum2 and hum2.Parent then
					hum2.PlatformStand = false
					hum2.WalkSpeed = origWalkSpeed
					hum2.JumpPower = origJumpPower
				end
			end)

			-- Phase3: 犬退場
			playSound(132514715, workspace, 2, 0.5)
			makeParticles(dog, Color3.fromRGB(255, 100, 0), 1, 80, 2)
			task.wait(0.3)
			dog.Anchored = false
			local jumpBV = Instance.new("BodyVelocity")
			jumpBV.Velocity = -pushDir * 40 + Vector3.new(0, 60, 0)
			jumpBV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			jumpBV.Parent = dog
			Debris:AddItem(jumpBV, 0.5)
			Debris:AddItem(dog, 2)
		end)

	elseif actionName == "allkill" then
		playSound(4612378735, workspace, 2)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("HumanoidRootPart")
				if h then fancyExplosion(h.Position, 8, 0) end
				local hu = c:FindFirstChild("Humanoid")
				if hu then hu.Health = 0 end
			end
		end

	elseif actionName == "allexplosion" then
		playSound(3691985274, workspace, 2)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("HumanoidRootPart")
				if h then fancyExplosion(h.Position, 10, 500000) end
			end
		end

	elseif actionName == "meteor" then
		playSound(3691985274, hrp, 2)
		local m = Instance.new("Part")
		m.Size = Vector3.new(8,8,8)
		m.Position = hrp.Position + Vector3.new(0, 80, 0)
		m.BrickColor = BrickColor.new("Dark orange")
		m.Shape = Enum.PartType.Ball
		m.Parent = workspace
		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 15
		fire.Parent = m
		makeParticles(m, Color3.fromRGB(255,100,0), 0.5, 20, 3)
		local bf = Instance.new("BodyForce")
		bf.Force = Vector3.new(0, -500000, 0)
		bf.Parent = m
		Debris:AddItem(m, 5)
		task.wait(1.5)
		fancyExplosion(m.Position, 12, 400000)

	elseif actionName == "bigmeteor" then
		playSound(3691985274, hrp, 2, 0.5)
		local m = Instance.new("Part")
		m.Size = Vector3.new(20,20,20)
		m.Position = hrp.Position + Vector3.new(0, 120, 0)
		m.BrickColor = BrickColor.new("Dark orange")
		m.Shape = Enum.PartType.Ball
		m.Parent = workspace
		local fire = Instance.new("Fire")
		fire.Size = 15
		fire.Heat = 25
		fire.Parent = m
		makeParticles(m, Color3.fromRGB(255,50,0), 0.5, 30, 5)
		local bf = Instance.new("BodyForce")
		bf.Force = Vector3.new(0, -900000, 0)
		bf.Parent = m
		Debris:AddItem(m, 6)
		task.wait(1.5)
		fancyExplosion(m.Position, 25, 1000000)

	elseif actionName == "meteorshower" then
		playSound(3691985274, workspace, 2)
		for i = 1, 10 do
			local m = Instance.new("Part")
			m.Size = Vector3.new(4,4,4)
			m.Position = hrp.Position + Vector3.new(math.random(-30,30), math.random(60,100), math.random(-30,30))
			m.BrickColor = BrickColor.new("Dark orange")
			m.Shape = Enum.PartType.Ball
			m.Parent = workspace
			local fire = Instance.new("Fire")
			fire.Size = 5
			fire.Parent = m
			local bf = Instance.new("BodyForce")
			bf.Force = Vector3.new(0, -400000, 0)
			bf.Parent = m
			Debris:AddItem(m, 4)
			task.wait(0.3)
		end

	elseif actionName == "bomb" then
		playSound(1124958144, hrp, 1.5)
		local b = Instance.new("Part")
		b.Size = Vector3.new(4,4,4)
		b.Position = hrp.Position + Vector3.new(0, 10, 0)
		b.BrickColor = BrickColor.new("Really black")
		b.Shape = Enum.PartType.Ball
		b.Parent = workspace
		-- カウントダウン演出
		for i = 1, 4 do
			b.BrickColor = (i%2==0) and BrickColor.new("Bright red") or BrickColor.new("Really black")
			task.wait(0.5)
		end
		fancyExplosion(b.Position, 12, 600000)
		b:Destroy()

	elseif actionName == "bigbomb" then
		playSound(1124958144, hrp, 2, 0.5)
		local b = Instance.new("Part")
		b.Size = Vector3.new(10,10,10)
		b.Position = hrp.Position + Vector3.new(0, 15, 0)
		b.BrickColor = BrickColor.new("Really black")
		b.Shape = Enum.PartType.Ball
		b.Parent = workspace
		for i = 1, 6 do
			b.BrickColor = (i%2==0) and BrickColor.new("Bright red") or BrickColor.new("Really black")
			b.Size = b.Size + Vector3.new(0.5,0.5,0.5)
			task.wait(0.33)
		end
		fancyExplosion(b.Position, 25, 1000000)
		b:Destroy()

	elseif actionName == "randomexplosion" then
		-- 派手なランダム爆発×3
		playSound(3691985274, workspace, 2)
		for i = 1, 3 do
			local offset = Vector3.new(math.random(-8,8), 0, math.random(-8,8))
			local epos = hrp.Position + offset
			-- 予告の光柱
			local pillar = Instance.new("Part")
			pillar.Size = Vector3.new(2, 50, 2)
			pillar.Position = epos + Vector3.new(0, 25, 0)
			pillar.Anchored = true
			pillar.CanCollide = false
			pillar.BrickColor = BrickColor.new("Bright red")
			pillar.Material = Enum.Material.Neon
			pillar.Transparency = 0.3
			pillar.CastShadow = false
			pillar.Parent = workspace
			task.wait(0.3)
			-- 爆発
			fancyExplosion(epos, 8, 400000, Color3.fromRGB(255,50,0))
			applyVelocity(hrp, math.random(-40,40), math.random(60,120), math.random(-40,40))
			pillar:Destroy()
			playSound(3691985274, workspace, 1.5, math.random(80,120)/100)
			task.wait(0.8)
		end

	elseif actionName == "storm" then
		local l = game:GetService("Lighting")
		l.FogEnd = 30
		l.FogColor = Color3.fromRGB(100,100,120)
		playSound(3167705355, workspace, 2)
		task.wait(10)
		l.FogEnd = 100000
		l.FogColor = Color3.fromRGB(192,192,192)

	elseif actionName == "lightning" then
		playSound(3167705355, hrp, 2, 2)
		-- 稲妻ビジュアル
		local bolt = Instance.new("Part")
		bolt.Size = Vector3.new(1, 60, 1)
		bolt.Position = hrp.Position + Vector3.new(0, 30, 0)
		bolt.Anchored = true
		bolt.CanCollide = false
		bolt.BrickColor = BrickColor.new("Bright yellow")
		bolt.Material = Enum.Material.Neon
		bolt.CastShadow = false
		bolt.Parent = workspace
		Debris:AddItem(bolt, 0.2)
		fancyExplosion(hrp.Position + Vector3.new(0,5,0), 5, 300000, Color3.fromRGB(255,255,0))
		applyVelocity(hrp, math.random(-20,20), 80, math.random(-20,20))

	elseif actionName == "fog" then
		local l = game:GetService("Lighting")
		l.FogEnd = 10
		l.FogColor = Color3.fromRGB(180,180,180)
		playSound(2645858750, workspace, 1, 0.3)
		task.wait(8)
		l.FogEnd = 100000

	elseif actionName == "fireworks" then
		playSound(1283240118, hrp, 1.5, 1.5)
		for i = 1, 8 do
			local p = Instance.new("Part")
			p.Size = Vector3.new(1,1,1)
			p.Position = hrp.Position + Vector3.new(math.random(-8,8), math.random(5,25), math.random(-8,8))
			p.BrickColor = BrickColor.Random()
			p.Material = Enum.Material.Neon
			p.Anchored = true
			p.CanCollide = false
			p.Parent = workspace
			makeParticles(p, p.BrickColor.Color, 1, 15, 2)
			Debris:AddItem(p, 1.5)
			task.wait(0.2)
		end

	elseif actionName == "redsky" then
		local l = game:GetService("Lighting")
		l.OutdoorAmbient = Color3.fromRGB(255,50,50)
		l.Ambient = Color3.fromRGB(255,0,0)
		playSound(1124958144, workspace, 1.5, 0.5)
		task.wait(10)
		l.OutdoorAmbient = Color3.fromRGB(127,127,127)
		l.Ambient = Color3.fromRGB(70,70,70)

	elseif actionName == "night" then
		local l = game:GetService("Lighting")
		l.ClockTime = 0
		playSound(1124958144, workspace, 1, 0.3)
		task.wait(10)
		l.ClockTime = 14

	elseif actionName == "rainbow" then
		local l = game:GetService("Lighting")
		playSound(1283240118, hrp, 1.5)
		local colors = {
			Color3.fromRGB(255,0,0), Color3.fromRGB(255,165,0),
			Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0),
			Color3.fromRGB(0,0,255), Color3.fromRGB(128,0,128)
		}
		for i = 1, 12 do
			l.Ambient = colors[(i % #colors) + 1]
			task.wait(0.5)
		end
		l.Ambient = Color3.fromRGB(70,70,70)

	-- ===== 障害物設置 =====
	elseif actionName == "obstacle" then
		-- プレイヤーの正面に障害物を設置（押せる・落とせる）
		-- ポコン・ポン効果音
		playSound(6817150445, workspace, 3, 1.8)
		task.wait(0.15)
		playSound(6817150445, workspace, 3, 2.2)
		local lookVec = hrp.CFrame.LookVector
		local spawnPos = hrp.Position + lookVec * 6 + Vector3.new(0, 2, 0)
		-- ランダムな障害物
		local shapes = {
			Enum.PartType.Block, Enum.PartType.Block, Enum.PartType.Cylinder, Enum.PartType.Ball
		}
		local colors2 = {
			"Bright red", "Bright orange", "Bright blue", "Bright green",
			"Bright violet", "Gold", "Hot pink", "Really black"
		}
		local obstacle = Instance.new("Part")
		obstacle.Shape = shapes[math.random(1, #shapes)]
		obstacle.Size = Vector3.new(
			math.random(3,6), math.random(3,8), math.random(3,6)
		)
		obstacle.Position = spawnPos
		obstacle.BrickColor = BrickColor.new(colors2[math.random(1,#colors2)])
		obstacle.Material = Enum.Material.SmoothPlastic
		obstacle.Anchored = false
		obstacle.CanCollide = true
		obstacle.Parent = workspace
		-- 落下する重力あり（通常の物理）
		makeParticles(obstacle, obstacle.BrickColor.Color, 0.5, 10, 1.5)
		-- 15秒後に消える
		Debris:AddItem(obstacle, 15)
		-- スポーン演出
		local flash2 = Instance.new("Part")
		flash2.Size = Vector3.new(3,3,3)
		flash2.Shape = Enum.PartType.Ball
		flash2.Position = spawnPos
		flash2.Anchored = true
		flash2.CanCollide = false
		flash2.BrickColor = BrickColor.new("Bright yellow")
		flash2.Material = Enum.Material.Neon
		flash2.CastShadow = false
		flash2.Parent = workspace
		TweenService:Create(flash2, TweenInfo.new(0.3), {Transparency = 1, Size = Vector3.new(0.1,0.1,0.1)}):Play()
		Debris:AddItem(flash2, 0.4)

	-- ===== 良い効果 =====
	elseif actionName == "heal" then
		hum.Health = hum.MaxHealth
		playSound(1283240118, hrp, 1.5, 1.5)
		makeParticles(hrp, Color3.fromRGB(0,255,100), 1, 10, 2)

	elseif actionName == "invincible" then
		hum.MaxHealth = 99999
		hum.Health = 99999
		playSound(1283240118, hrp, 2)
		makeParticles(hrp, Color3.fromRGB(255,220,0), 1.5, 15, 2.5)
		task.wait(8)
		hum.MaxHealth = 100
		hum.Health = 100

	elseif actionName == "fly" then
		local bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(0,0,0)
		bg.Parent = hrp
		local bv = Instance.new("BodyVelocity")
		bv.Velocity = Vector3.new(0,0,0)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bv.Parent = hrp
		workspace.Gravity = 0
		hum.WalkSpeed = 30
		playSound(2645858750, hrp, 1.5)
		makeParticles(hrp, Color3.fromRGB(100,200,255), 1, 10, 2)
		task.wait(10)
		workspace.Gravity = 196.2
		hum.WalkSpeed = 16
		bg:Destroy()
		bv:Destroy()

	elseif actionName == "highjump" then
		hum.JumpPower = 100
		playSound(2645858750, hrp, 1.5, 1.5)
		makeParticles(hrp, Color3.fromRGB(0,255,200), 0.5, 20, 2)
		task.wait(10)
		hum.JumpPower = 50

	elseif actionName == "superhighjump" then
		hum.JumpPower = 200
		playSound(2645858750, hrp, 2, 2)
		makeParticles(hrp, Color3.fromRGB(0,255,255), 0.3, 40, 2.5)
		task.wait(10)
		hum.JumpPower = 50

	elseif actionName == "allhighspeed" then
		playSound(2545110825, workspace, 1.5)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("Humanoid")
				if h then h.WalkSpeed = 60 end
				local rp = c:FindFirstChild("HumanoidRootPart")
				if rp then makeParticles(rp, Color3.fromRGB(255,255,0), 0.5, 30, 1.5) end
			end
		end
		task.wait(8)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("Humanoid")
				if h then h.WalkSpeed = 16 end
			end
		end

	elseif actionName == "allhighjump" then
		playSound(2645858750, workspace, 1.5)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("Humanoid")
				if h then h.JumpPower = 100 end
				local rp = c:FindFirstChild("HumanoidRootPart")
				if rp then makeParticles(rp, Color3.fromRGB(0,255,200), 0.5, 20, 2) end
			end
		end
		task.wait(8)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("Humanoid")
				if h then h.JumpPower = 50 end
			end
		end

	elseif actionName == "allheal" then
		playSound(1283240118, workspace, 2)
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c then
				local h = c:FindFirstChild("Humanoid")
				if h then h.Health = h.MaxHealth end
				local rp = c:FindFirstChild("HumanoidRootPart")
				if rp then makeParticles(rp, Color3.fromRGB(0,255,100), 1, 10, 2) end
			end
		end

	elseif actionName == "stageskip1" then
		local be = game:GetService("ReplicatedStorage"):FindFirstChild("ObbyBindable")
		if be then be:Fire("skip", 1) end
		playSound(1283240118, hrp, 2, 1.5)

	elseif actionName == "stageskip3" then
		local be = game:GetService("ReplicatedStorage"):FindFirstChild("ObbyBindable")
		if be then be:Fire("skip", 3) end
		playSound(1283240118, hrp, 2, 2)

	elseif actionName == "allstageskip1" then
		local be = game:GetService("ReplicatedStorage"):FindFirstChild("ObbyBindable")
		if be then be:Fire("skipall", 1) end
		playSound(1283240118, workspace, 2, 1.5)

	elseif actionName == "checkpoint" then
		local be = game:GetService("ReplicatedStorage"):FindFirstChild("ObbyBindable")
		if be then be:Fire("checkpoint", 0) end
		playSound(1548195490, hrp, 1.5)

	elseif actionName == "resettostart" then
		-- リセット：体10倍に巨大化→画面青く光る→吹っ飛び→スタートに戻る
		local rs2 = game:GetService("ReplicatedStorage")
		local be2 = rs2:FindFirstChild("ObbyBindable")
		if not be2 then
			be2 = Instance.new("BindableEvent")
			be2.Name = "ObbyBindable"
			be2.Parent = rs2
		end
		playSound(1124958144, hrp, 2, 0.5)
		char:ScaleTo(10)
		-- 画面を青く光らせる（全プレイヤー）
		for _, p in ipairs(Players:GetPlayers()) do
			local gui = p.PlayerGui
			if gui then
				local flash = Instance.new("ScreenGui")
				flash.Name = "FlashUI"
				flash.ResetOnSpawn = false
				flash.Parent = gui
				local f = Instance.new("Frame")
				f.Size = UDim2.new(1,0,1,0)
				f.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
				f.BackgroundTransparency = 0.2
				f.BorderSizePixel = 0
				f.ZIndex = 20
				f.Parent = flash
				game:GetService("TweenService"):Create(f,
					TweenInfo.new(0.8),
					{BackgroundTransparency = 1}
				):Play()
				game:GetService("Debris"):AddItem(flash, 1)
			end
		end
		local resetCols = {
			BrickColor.new("Bright red"), BrickColor.new("Bright orange"),
			BrickColor.new("Bright yellow"), BrickColor.new("Lime green"),
			BrickColor.new("Bright blue"), BrickColor.new("Hot pink"),
		}
		local att = Instance.new("Attachment")
		att.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,255)),
		})
		pe.LightEmission = 1
		pe.Lifetime = NumberRange.new(0.5, 1.5)
		pe.Rate = 200
		pe.Speed = NumberRange.new(15, 30)
		pe.Size = NumberSequence.new(3)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Parent = att
		for i = 1, 10 do
			local col = resetCols[(i % #resetCols) + 1]
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.BrickColor = col end
			end
			local angle = math.rad(i * 36)
			applyVelocity(hrp, math.cos(angle)*150, math.random(60,120), math.sin(angle)*150)
			fancyExplosion(hrp.Position, 5, 0, col.Color)
			playSound(3691985274, hrp, 1.2, 0.7 + i*0.05)
			task.wait(0.3)
		end
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.BrickColor = BrickColor.new("Medium stone grey") end
		end
		pe.Enabled = false
		Debris:AddItem(att, 1)
		char:ScaleTo(1)
		be2:Fire("resettostart")

	elseif actionName == "nofall" then
		local be = game:GetService("ReplicatedStorage"):FindFirstChild("ObbyBindable")
		if be then be:Fire("nofall", 10) end
		playSound(1283240118, hrp, 2)
		makeParticles(hrp, Color3.fromRGB(100,255,200), 1, 5, 2)


	elseif actionName == "secret" then
		-- シークレット：段階的に10倍まで巨大化（1分間）
		playSound(4612378735, hrp, 2, 0.3)
		-- 画面を金色にフラッシュ
		for _, p in ipairs(Players:GetPlayers()) do
			local gui = p.PlayerGui
			if gui then
				local flash = Instance.new("ScreenGui")
				flash.Name = "FlashUI"
				flash.ResetOnSpawn = false
				flash.Parent = gui
				local f = Instance.new("Frame")
				f.Size = UDim2.new(1,0,1,0)
				f.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
				f.BackgroundTransparency = 0.1
				f.BorderSizePixel = 0
				f.ZIndex = 20
				f.Parent = flash
				game:GetService("TweenService"):Create(f, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
				game:GetService("Debris"):AddItem(flash, 2)
			end
		end
		makeParticles(hrp, Color3.fromRGB(255,220,0), 2, 50, 8)
		-- 1→2→4→7→10倍と段階的に巨大化（間隔を長くしてわかりやすく）
		local stages = {2, 4, 7, 10}
		for _, s in ipairs(stages) do
			char:ScaleTo(s)
			playSound(4612378735, hrp, 1.5, 0.4)
			fancyExplosion(hrp.Position, s * 3, 0, Color3.fromRGB(255,220,0))
			makeParticles(hrp, Color3.fromRGB(255,200,0), 1, 20, s)
			task.wait(1.5)
		end
		-- 10倍のまま1分間維持
		secretPlayers[target.UserId] = true
		task.spawn(function()
			task.wait(60)
			secretPlayers[target.UserId] = nil
			if char and char.Parent then
				makeParticles(hrp, Color3.fromRGB(200,200,200), 1, 30, 5)
				char:ScaleTo(1)
				playSound(4612378735, hrp, 2, 2)
			end
		end)
	elseif actionName == "goaltp" then
		local rs2 = game:GetService("ReplicatedStorage")
		local be2 = rs2:FindFirstChild("ObbyBindable")
		if not be2 then
			be2 = Instance.new("BindableEvent")
			be2.Name = "ObbyBindable"
			be2.Parent = rs2
		end
		playSound(1283240118, hrp, 2, 0.8)
		char:ScaleTo(10)
		-- 画面を赤く光らせる（全プレイヤー）
		for _, p in ipairs(Players:GetPlayers()) do
			local gui = p.PlayerGui
			if gui then
				local flash = Instance.new("ScreenGui")
				flash.Name = "FlashUI"
				flash.ResetOnSpawn = false
				flash.Parent = gui
				local f = Instance.new("Frame")
				f.Size = UDim2.new(1,0,1,0)
				f.BackgroundColor3 = Color3.fromRGB(255, 50, 0)
				f.BackgroundTransparency = 0.2
				f.BorderSizePixel = 0
				f.ZIndex = 20
				f.Parent = flash
				game:GetService("TweenService"):Create(f,
					TweenInfo.new(0.8),
					{BackgroundTransparency = 1}
				):Play()
				game:GetService("Debris"):AddItem(flash, 1)
			end
		end
		local goalCols = {
			BrickColor.new("Bright red"), BrickColor.new("Bright orange"),
			BrickColor.new("Bright yellow"), BrickColor.new("Lime green"),
			BrickColor.new("Bright blue"), BrickColor.new("Hot pink"),
		}
		local att = Instance.new("Attachment")
		att.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,200,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,50,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,100)),
		})
		pe.LightEmission = 1
		pe.Lifetime = NumberRange.new(0.5, 1.5)
		pe.Rate = 200
		pe.Speed = NumberRange.new(15, 30)
		pe.Size = NumberSequence.new(3)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Parent = att
		for i = 1, 10 do
			local col = goalCols[(i % #goalCols) + 1]
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.BrickColor = col end
			end
			local angle = math.rad(i * 36)
			applyVelocity(hrp, math.cos(angle)*150, math.random(60,120), math.sin(angle)*150)
			fancyExplosion(hrp.Position, 5, 0, col.Color)
			playSound(3691985274, hrp, 1.2, 0.7 + i*0.05)
			task.wait(0.3)
		end
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.BrickColor = BrickColor.new("Medium stone grey") end
		end
		pe.Enabled = false
		Debris:AddItem(att, 1)
		char:ScaleTo(1)
		be2:Fire("goaltp")

	elseif actionName == "jumpboost" then
		-- ジャンプ力UP（10秒）通常の2倍
		-- JumpHeightを使う（新しいRobloxキャラはこちらが優先）
		local origHeight = hum.JumpHeight
		hum.JumpHeight = origHeight * 2
		playSound(2645858750, hrp, 2, 1.8)
		-- 発動中ずっとキャラ周りに緑パーティクル
		local att = Instance.new("Attachment")
		att.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,100)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100,255,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,0)),
		})
		pe.LightEmission = 1
		pe.Lifetime = NumberRange.new(0.5, 1.0)
		pe.Rate = 60
		pe.Speed = NumberRange.new(5, 15)
		pe.Size = NumberSequence.new(1.5)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Parent = att
		-- 足元に光輪
		local ring = Instance.new("Part")
		ring.Size = Vector3.new(8, 0.3, 8)
		ring.CFrame = CFrame.new(hrp.Position + Vector3.new(0, -3, 0))
		ring.Anchored = true
		ring.CanCollide = false
		ring.BrickColor = BrickColor.new("Lime green")
		ring.Material = Enum.Material.Neon
		ring.Transparency = 0.2
		ring.Parent = workspace
		TweenService:Create(ring, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(14, 0.1, 14)}):Play()
		Debris:AddItem(ring, 1.2)
		-- 10秒後に元に戻す
		task.spawn(function()
			task.wait(10)
			if hum and hum.Parent then
				hum.JumpHeight = origHeight
			end
			pe.Enabled = false
			task.wait(1)
			att:Destroy()
		end)

	elseif actionName == "speedboost" then
		-- スピードUP（10秒）通常の1.5倍・加速なし
		hum.WalkSpeed = 32
		playSound(2545110825, hrp, 2, 1.5)
		-- パーティクル
		local att = Instance.new("Attachment")
		att.Parent = hrp
		local pe = Instance.new("ParticleEmitter")
		pe.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,200,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,100,0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,50,50)),
		})
		pe.LightEmission = 1
		pe.Lifetime = NumberRange.new(0.3, 0.8)
		pe.Rate = 100
		pe.Speed = NumberRange.new(20, 50)
		pe.Size = NumberSequence.new(1.5)
		pe.SpreadAngle = Vector2.new(180, 180)
		pe.Parent = att
		-- スピードライン演出（吹っ飛びなし）
		for i = 1, 5 do
			local line = Instance.new("Part")
			line.Size = Vector3.new(0.3, 0.3, math.random(5, 15))
			line.CFrame = CFrame.new(hrp.Position + Vector3.new(
				math.random(-3,3), math.random(-2,2), -math.random(3,8)
			))
			line.Anchored = true
			line.CanCollide = false
			line.BrickColor = BrickColor.new("Bright yellow")
			line.Material = Enum.Material.Neon
			line.CastShadow = false
			line.Parent = workspace
			Debris:AddItem(line, 0.3)
		end
		-- 10秒後に元に戻す（非同期・吹っ飛ばしなし）
		task.spawn(function()
			task.wait(10)
			hum.WalkSpeed = 16
			pe.Enabled = false
			Debris:AddItem(att, 1)
		end)
	elseif actionName == "stageskip25" then
		-- 25ステージ進む：虹色に光って巨大化→10連続吹っ飛び→テレポート
		print("[DEBUG] stageskip25 開始")
		local rs2 = game:GetService("ReplicatedStorage")
		local be2 = rs2:FindFirstChild("ObbyBindable")
		if not be2 then
			print("[DEBUG] ObbyBindable が見つからないので作成")
			be2 = Instance.new("BindableEvent")
			be2.Name = "ObbyBindable"
			be2.Parent = rs2
		end
		print("[DEBUG] ObbyBindable 取得OK:", be2.Name)

		-- 巨大化
		char:ScaleTo(3)
		playSound(1283240118, hrp, 2, 0.5)

		-- 虹色に光るパーティクル
		local att1 = Instance.new("Attachment")
		att1.Parent = hrp
		local pe1 = Instance.new("ParticleEmitter")
		pe1.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,165,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(128,0,128)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
		})
		pe1.LightEmission = 1
		pe1.Lifetime = NumberRange.new(0.5, 1.5)
		pe1.Rate = 200
		pe1.Speed = NumberRange.new(15, 30)
		pe1.Size = NumberSequence.new(3)
		pe1.SpreadAngle = Vector2.new(180, 180)
		pe1.Parent = att1

		-- 虹色に体を点滅させる
		local rainbowCols = {
			BrickColor.new("Bright red"), BrickColor.new("Bright orange"),
			BrickColor.new("Bright yellow"), BrickColor.new("Lime green"),
			BrickColor.new("Bright blue"), BrickColor.new("Hot pink"),
		}

		-- 10連続吹っ飛び＋虹点滅
		for i = 1, 10 do
			local col = rainbowCols[(i % #rainbowCols) + 1]
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.BrickColor = col
				end
			end
			local angle = math.rad(i * 36)
			applyVelocity(hrp,
				math.cos(angle) * 120,
				math.random(80, 160),
				math.sin(angle) * 120
			)
			playSound(3691985274, hrp, 1.5, 0.8 + i * 0.05)
			fancyExplosion(hrp.Position, 5, 0, col.Color)
			task.wait(0.3)
		end

		-- 元の色に戻す
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.BrickColor = BrickColor.new("Medium stone grey") end
		end
		pe1.Enabled = false
		Debris:AddItem(att1, 1)
		char:ScaleTo(1)

		-- テレポート
		print("[DEBUG] be2:Fire skip25 実行")
		be2:Fire("skip50")
		playSound(1283240118, hrp, 2, 2)
		makeParticles(hrp, Color3.fromRGB(255,220,0), 1.5, 40, 4)

	elseif actionName == "stageback25" then
		-- 25ステージ戻る：虹色に光って巨大化→10連続吹っ飛び→テレポート
		print("[DEBUG] stageback25 開始")
		local rs2 = game:GetService("ReplicatedStorage")
		local be2 = rs2:FindFirstChild("ObbyBindable")
		if not be2 then
			print("[DEBUG] ObbyBindable が見つからないので作成")
			be2 = Instance.new("BindableEvent")
			be2.Name = "ObbyBindable"
			be2.Parent = rs2
		end
		print("[DEBUG] ObbyBindable 取得OK:", be2.Name)

		playSound(1124958144, hrp, 2, 0.5)
		char:ScaleTo(3)

		-- 赤・黒の電車カラーで点滅
		local trainCols = {
			BrickColor.new("Bright blue"), BrickColor.new("Cyan"),
			BrickColor.new("Bright blue"), BrickColor.new("White"),
		}
		local att2 = Instance.new("Attachment")
		att2.Parent = hrp
		local pe2 = Instance.new("ParticleEmitter")
		pe2.Color = ColorSequence.new(Color3.fromRGB(0, 100, 255))
		pe2.LightEmission = 1
		pe2.Lifetime = NumberRange.new(0.5, 1)
		pe2.Rate = 150
		pe2.Speed = NumberRange.new(20, 40)
		pe2.Size = NumberSequence.new(3)
		pe2.SpreadAngle = Vector2.new(180,180)
		pe2.Parent = att2

		-- ホーン
		for i = 1, 3 do
			playSound(1124958144, workspace, 2, 1 + i * 0.2)
			task.wait(0.3)
		end

		-- 10連続吹っ飛び
		for i = 1, 10 do
			local col = trainCols[(i % #trainCols) + 1]
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.BrickColor = col end
			end
			local angle = math.rad(i * 36 + 180)
			applyVelocity(hrp,
				math.cos(angle) * 150,
				math.random(60, 120),
				math.sin(angle) * 150
			)
			fancyExplosion(hrp.Position, 5, 0, col.Color)
			playSound(3691985274, hrp, 1.2, 0.7 + i * 0.05)
			task.wait(0.3)
		end

		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.BrickColor = BrickColor.new("Medium stone grey") end
		end
		pe2.Enabled = false
		Debris:AddItem(att2, 1)
		char:ScaleTo(1)

		print("[DEBUG] be2:Fire back25 実行")
		be2:Fire("back50")

	elseif actionName == "thunderstorm" then
		-- 超派手な雷嵐・周りも黄色くピカピカ
		playSound(3167705355, workspace, 2, 0.5)
		local l = game:GetService("Lighting")
		local origBright = l.Brightness
		local origAmb = l.Ambient

		-- 空が黄色くピカピカ点滅
		task.spawn(function()
			for i = 1, 20 do
				if i % 2 == 0 then
					l.Brightness = 8
					l.Ambient = Color3.fromRGB(255, 255, 0)
					l.OutdoorAmbient = Color3.fromRGB(255, 220, 0)
				else
					l.Brightness = 0.5
					l.Ambient = Color3.fromRGB(20, 20, 50)
					l.OutdoorAmbient = Color3.fromRGB(20, 20, 60)
				end
				task.wait(0.12)
			end
			l.Brightness = origBright
			l.Ambient = origAmb
			l.OutdoorAmbient = Color3.fromRGB(128, 178, 230)
		end)

		-- 16本の雷を連続落下
		for strike = 1, 16 do
			task.spawn(function()
				task.wait(math.random(0, 30) * 0.08)
				local ox = math.random(-25, 25)
				local oz = math.random(-25, 25)
				local boltPos = hrp.Position + Vector3.new(ox, 0, oz)
				-- 主雷
				local bolt = Instance.new("Part")
				bolt.Size = Vector3.new(1, 140, 1)
				bolt.Position = boltPos + Vector3.new(0, 70, 0)
				bolt.Anchored = true
				bolt.CanCollide = false
				bolt.BrickColor = BrickColor.new("Bright yellow")
				bolt.Material = Enum.Material.Neon
				bolt.CastShadow = false
				bolt.Parent = workspace
				-- 横枝5本
				for j = 1, 5 do
					local branch = Instance.new("Part")
					branch.Size = Vector3.new(0.5, 0.5, math.random(10, 25))
					branch.CFrame = CFrame.new(
						boltPos + Vector3.new(math.random(-10,10), math.random(5,60), math.random(-10,10))
					) * CFrame.Angles(
						math.rad(math.random(-60,60)),
						math.rad(math.random(0,360)),
						0
					)
					branch.Anchored = true
					branch.CanCollide = false
					branch.BrickColor = BrickColor.new("Bright yellow")
					branch.Material = Enum.Material.Neon
					branch.CastShadow = false
					branch.Parent = workspace
					Debris:AddItem(branch, 0.15)
				end
				-- 地面の光輪
				local ring = Instance.new("Part")
				ring.Size = Vector3.new(12, 0.5, 12)
				ring.Position = boltPos + Vector3.new(0, 0.5, 0)
				ring.Anchored = true
				ring.CanCollide = false
				ring.BrickColor = BrickColor.new("Bright yellow")
				ring.Material = Enum.Material.Neon
				ring.Transparency = 0.3
				ring.Shape = Enum.PartType.Cylinder
				ring.CastShadow = false
				ring.Parent = workspace
				Debris:AddItem(ring, 0.2)
				playSound(3167705355, workspace, 2, math.random(80, 200)/100)
				fancyExplosion(boltPos, 8, 80000, Color3.fromRGB(255,255,100))
				Debris:AddItem(bolt, 0.15)
				-- 近くにいたらランダム方向に激しく吹っ飛ぶ
				local dist = (hrp.Position - boltPos).Magnitude
				if dist < 30 then
					local angle = math.rad(math.random(0, 360))
					applyVelocity(hrp,
						math.cos(angle) * math.random(100, 250),
						math.random(80, 200),
						math.sin(angle) * math.random(100, 250)
					)
				end
			end)
		end
		task.wait(3)

	end
end

-- ===== メインループ =====
task.spawn(function()
	while true do
		local ok, _ = pcall(function()
			local url = getServerURL()
			-- API_KEYでキューをポーリング
			local res = HttpService:GetAsync(url .. "/get_action?key=" .. API_KEY, true)
			local data = HttpService:JSONDecode(res)
			if data and data.action and data.action ~= "none" then
				if data.player and data.player ~= "" then
					for _, p in ipairs(Players:GetPlayers()) do
						task.spawn(showGiftName, p, data.player, data.action)
					end
				end
				task.spawn(executeAction, data.action, data.player or "")
			end
		end)
		task.wait(0.5)
	end
end)

task.spawn(function()
	while true do
		local ok, _ = pcall(function()
			local url = getServerURL()
			local res = HttpService:GetAsync(url .. "/get_name?key=" .. API_KEY, true)
			local data = HttpService:JSONDecode(res)
			if data and data.name and data.name ~= "" then
				for _, p in ipairs(Players:GetPlayers()) do
					task.spawn(showGiftName, p, data.name, data.action or "")
				end
			end
		end)
		task.wait(0.5)
	end
end)
