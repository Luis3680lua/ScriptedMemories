alocal Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("RealStatsGuiLeft")
if oldGui then
	oldGui:Destroy()
end

local function hideSingleLabel(label)
	if label:IsA("TextLabel") and label.Name ~= "StatsLabel" then
		local text = label.Text
		if string.find(text, "[Mm][Ss]") or string.find(text, "[Ff][Pp][Ss]") then
			label.Visible = false
		end
	end
end

local function scanAndHideAll()
	for _, v in pairs(PlayerGui:GetDescendants()) do
		hideSingleLabel(v)
	end
end

scanAndHideAll()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RealStatsGuiLeft"
ScreenGui.ResetOnSpawn = false
ScreenGui.ScreenInsets = Enum.ScreenInsets.None
ScreenGui.DisplayOrder = 1000000
ScreenGui.Parent = PlayerGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Name = "StatsLabel"
TextLabel.Size = UDim2.new(0.35, 0, 0.035, 0)
TextLabel.SizeConstraint = Enum.SizeConstraint.RelativeXY
TextLabel.AnchorPoint = Vector2.new(1, 0)
TextLabel.Position = UDim2.new(1, -10, 0, 10)
TextLabel.BackgroundTransparency = 1.0
TextLabel.BorderSizePixel = 0
TextLabel.TextSize = 14
TextLabel.TextScaled = false
TextLabel.Font = Enum.Font.RobotoMono
TextLabel.TextXAlignment = Enum.TextXAlignment.Right
TextLabel.RichText = true
TextLabel.Parent = ScreenGui

local TextSizeConstraint = Instance.new("UITextSizeConstraint")
TextSizeConstraint.MaxTextSize = 15
TextSizeConstraint.MinTextSize = 11
TextSizeConstraint.Parent = TextLabel

local function GetPingColorHex(ping)
	if ping <= 10 then
		return "#0077ff"
	elseif ping <= 20 then
		return "#00b7ff"
	elseif ping <= 35 then
		return "#00ff66"
	elseif ping <= 50 then
		return "#66ff33"
	elseif ping <= 70 then
		return "#bfff00"
	elseif ping <= 90 then
		return "#ffff00"
	elseif ping <= 110 then
		return "#ffd000"
	elseif ping <= 140 then
		return "#ff9900"
	elseif ping <= 170 then
		return "#ff6600"
	elseif ping <= 220 then
		return "#ff2d00"
	else
		return "#c80000"
	end
end

local function GetFpsColorHex(fps)
	if fps >= 240 then
		return "#b000ff"
	elseif fps >= 165 then
		return "#0077ff"
	elseif fps >= 120 then
		return "#00c8ff"
	elseif fps >= 90 then
		return "#00ff66"
	elseif fps >= 75 then
		return "#66ff33"
	elseif fps >= 60 then
		return "#66ff00"
	elseif fps >= 50 then
		return "#ffff00"
	elseif fps >= 40 then
		return "#ffb000"
	elseif fps >= 30 then
		return "#ff7700"
	elseif fps >= 20 then
		return "#ff2200"
	else
		return "#c80000"
	end
end

local frameCount = 0
local elapsedTime = 0
local currentFps = 60
local nextScanTime = 0

RunService.Heartbeat:Connect(function(deltaTime)
	frameCount = frameCount + 1
	elapsedTime = elapsedTime + deltaTime

	if elapsedTime >= 1 then
		currentFps = math.round(frameCount / elapsedTime)
		frameCount = 0
		elapsedTime = 0

		local realPing = math.round(LocalPlayer:GetNetworkPing() * 1000)
		local pingColor = GetPingColorHex(realPing)
		local fpsColor = GetFpsColorHex(currentFps)

		TextLabel.Text = string.format(
			"<font color=\"%s\">%s MS</font>  |  <font color=\"%s\">FPS: %s</font>",
			pingColor, tostring(realPing), fpsColor, tostring(currentFps)
		)
	end

	local now = os.clock()
	if now >= nextScanTime then
		scanAndHideAll()
		nextScanTime = now + 2
	end
end)
