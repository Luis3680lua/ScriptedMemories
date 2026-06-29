local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("RealStatsGuiLeft")
if oldGui then
	oldGui:Destroy()
end

local PingThresholds = {10, 20, 35, 50, 70, 90, 110, 140, 170, 220}
local PingColors = {"#0077ff", "#00b7ff", "#00ff66", "#66ff33", "#bfff00", "#ffff00", "#ffd000", "#ff9900", "#ff6600", "#ff2d00", "#c80000"}
local FpsThresholds = {240, 165, 120, 90, 75, 60, 50, 40, 30, 20}
local FpsColors = {"#b000ff", "#0077ff", "#00c8ff", "#00ff66", "#66ff33", "#66ff00", "#ffff00", "#ffb000", "#ff7700", "#ff2200", "#c80000"}

local function GetPingColor(ping)
	for i, threshold in ipairs(PingThresholds) do
		if ping <= threshold then
			return PingColors[i]
		end
	end
	return PingColors[#PingColors]
end

local function GetFpsColor(fps)
	for i, threshold in ipairs(FpsThresholds) do
		if fps >= threshold then
			return FpsColors[i]
		end
	end
	return FpsColors[#FpsColors]
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
	for _, v in ipairs(PlayerGui:GetDescendants()) do
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

local frameCount = 0
local elapsedTime = 0
local scanAccum = 0
local currentFps = 60

RunService.Heartbeat:Connect(function(deltaTime)
	frameCount = frameCount + 1
	elapsedTime = elapsedTime + deltaTime

	if elapsedTime >= 1 then
		currentFps = math.round(frameCount / elapsedTime)
		frameCount = 0
		elapsedTime = 0

		local realPing = math.round(LocalPlayer:GetNetworkPing() * 1000)
		local pingColor = GetPingColor(realPing)
		local fpsColor = GetFpsColor(currentFps)

		TextLabel.Text = string.format(
			"<font color=\"%s\">%s MS</font>  |  <font color=\"%s\">FPS: %s</font>",
			pingColor, realPing, fpsColor, currentFps
		)
	end

	scanAccum = scanAccum + deltaTime
	if scanAccum >= 2 then
		scanAndHideAll()
		scanAccum = 0
	end
end)