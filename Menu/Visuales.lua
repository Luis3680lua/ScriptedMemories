local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local PingThresholds = {10, 20, 35, 50, 70, 90, 110, 140, 170, 220}
local PingColors = {"#0077ff", "#00b7ff", "#00ff66", "#66ff33", "#bfff00", "#ffff00", "#ffd000", "#ff9900", "#ff6600", "#ff2d00", "#c80000"}
local FpsThresholds = {240, 165, 120, 90, 75, 60, 50, 40, 30, 20}
local FpsColors = {"#b000ff", "#0077ff", "#00c8ff", "#00ff66", "#66ff33", "#66ff00", "#ffff00", "#ffb000", "#ff7700", "#ff2200", "#c80000"}

local function GetPingColor(ping)
	for i = 1, #PingThresholds do
		if ping <= PingThresholds[i] then
			return PingColors[i]
		end
	end
	return PingColors[#PingColors]
end

local function GetFpsColor(fps)
	for i = 1, #FpsThresholds do
		if fps >= FpsThresholds[i] then
			return FpsColors[i]
		end
	end
	return FpsColors[#FpsColors]
end

local sfind = string.find
local slower = string.lower

local hiddenLabels = {}
local descendantConnection = nil

local function restoreOriginalLabels()
	for _, label in ipairs(hiddenLabels) do
		pcall(function()
			label.Visible = true
		end)
	end
	hiddenLabels = {}
end

local function hideSingleLabel(label)
	if label:IsA("TextLabel") and label.Name ~= "StatsLabel" then
		local text = slower(label.Text)
		if sfind(text, "ms", 1, true) or sfind(text, "fps", 1, true) then
			label.Visible = false
			table.insert(hiddenLabels, label)
		end
	end
end

local function scanAndHideAll()
	for _, v in ipairs(PlayerGui:GetDescendants()) do
		hideSingleLabel(v)
	end
end

if Menu.Settings.visuals_pingfps_enabled == nil then
	Menu.Settings.visuals_pingfps_enabled = false
end
if not Menu.Settings.visuals_pingfps_position then
	Menu.Settings.visuals_pingfps_position = "Default"
end
if not Menu.Settings.visuals_pingfps_custom_x then
	Menu.Settings.visuals_pingfps_custom_x = 10
end
if not Menu.Settings.visuals_pingfps_custom_y then
	Menu.Settings.visuals_pingfps_custom_y = 10
end

local DEFAULT_POS = {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10)}

local function getPositionData()
	local pos = Menu.Settings.visuals_pingfps_position
	if pos == "Personalizada" then
		return {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, Menu.Settings.visuals_pingfps_custom_x, 0, Menu.Settings.visuals_pingfps_custom_y)
		}
	else
		return DEFAULT_POS
	end
end

local StatsGui = nil
local HeartbeatConnection = nil

local function updateStatsDisplay()
	if HeartbeatConnection then
		HeartbeatConnection:Disconnect()
		HeartbeatConnection = nil
	end
	if StatsGui then
		StatsGui:Destroy()
		StatsGui = nil
	end
	if descendantConnection then
		descendantConnection:Disconnect()
		descendantConnection = nil
	end

	if not Menu.Settings.visuals_pingfps_enabled then
		restoreOriginalLabels()
		return
	end

	scanAndHideAll()
	descendantConnection = PlayerGui.DescendantAdded:Connect(hideSingleLabel)

	local posData = getPositionData()
	local gui = Instance.new("ScreenGui")
	gui.Name = "RealStatsGuiLeft"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.DisplayOrder = 1000000
	gui.Parent = PlayerGui

	local label = Instance.new("TextLabel")
	label.Name = "StatsLabel"
	label.Size = UDim2.new(0.35, 0, 0.035, 0)
	label.SizeConstraint = Enum.SizeConstraint.RelativeXY
	label.AnchorPoint = posData.AnchorPoint
	label.Position = posData.Position
	label.BackgroundTransparency = 1.0
	label.BorderSizePixel = 0
	label.TextSize = 14
	label.TextScaled = false
	label.Font = Enum.Font.RobotoMono
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.RichText = true
	label.Parent = gui

	local TextSizeConstraint = Instance.new("UITextSizeConstraint")
	TextSizeConstraint.MaxTextSize = 15
	TextSizeConstraint.MinTextSize = 11
	TextSizeConstraint.Parent = label

	StatsGui = gui

	local frameCount = 0
	local elapsedTime = 0

	HeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		frameCount = frameCount + 1
		elapsedTime = elapsedTime + deltaTime

		if elapsedTime >= 1 then
			local currentFps = math.round(frameCount / elapsedTime)
			frameCount = 0
			elapsedTime = 0

			local realPing = math.round(LocalPlayer:GetNetworkPing() * 1000)
			local pingColor = GetPingColor(realPing)
			local fpsColor = GetFpsColor(currentFps)

			label.Text = string.format(
				"<font color=\"%s\">%s MS</font>  |  <font color=\"%s\">FPS: %s</font>",
				pingColor, realPing, fpsColor, currentFps
			)
		end
	end)
end

local T = {
	Bg = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(30, 30, 38),
	Tertiary = Color3.fromRGB(42, 42, 50),
	Hover = Color3.fromRGB(55, 55, 65),
	Text = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(180, 180, 195),
	Accent = Color3.fromRGB(70, 150, 255),
	Green = Color3.fromRGB(70, 210, 110),
	Red = Color3.fromRGB(220, 80, 80),
	Border = Color3.fromRGB(60, 60, 75),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
}

local function roundFrame(frame, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = frame
end

local page = Menu:RegisterPage("Visuales", "🎨")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(1, 0, 0, 0)
mainContainer.BackgroundTransparency = 1
mainContainer.AutomaticSize = Enum.AutomaticSize.Y
mainContainer.Parent = page.Frame

local mainList = Instance.new("UIListLayout")
mainList.Padding = UDim.new(0, 6)
mainList.SortOrder = Enum.SortOrder.LayoutOrder
mainList.Parent = mainContainer

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Font = T.FontBold
title.TextSize = 20
title.TextColor3 = T.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎨 Visuales"
title.Parent = mainContainer

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0, 42)
desc.BackgroundTransparency = 1
desc.Font = T.Font
desc.TextSize = 13
desc.TextWrapped = true
desc.TextColor3 = T.TextDim
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.Text = "Ajustes visuales y superposiciones en pantalla."
desc.Parent = mainContainer

local toggleSection = Instance.new("Frame")
toggleSection.Size = UDim2.new(1, 0, 0, 0)
toggleSection.BackgroundTransparency = 1
toggleSection.AutomaticSize = Enum.AutomaticSize.Y
toggleSection.Parent = mainContainer

local toggleSectionList = Instance.new("UIListLayout")
toggleSectionList.Padding = UDim.new(0, 4)
toggleSectionList.SortOrder = Enum.SortOrder.LayoutOrder
toggleSectionList.Parent = toggleSection

local toggleHeader = Instance.new("TextLabel")
toggleHeader.Size = UDim2.new(1, 0, 0, 22)
toggleHeader.BackgroundTransparency = 1
toggleHeader.Font = T.FontBold
toggleHeader.TextSize = 15
toggleHeader.TextColor3 = T.Text
toggleHeader.TextXAlignment = Enum.TextXAlignment.Left
toggleHeader.Text = "📶 Ping y FPS"
toggleHeader.Parent = toggleSection

local enabled = Menu.Settings.visuals_pingfps_enabled

local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(1, 0, 0, 50)
toggleFrame.BackgroundColor3 = T.Tertiary
toggleFrame.BackgroundTransparency = 0.3
toggleFrame.BorderSizePixel = 0
roundFrame(toggleFrame, 6)
toggleFrame.Parent = toggleSection

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(0, 220, 0, 26)
toggleLabel.Position = UDim2.new(0, 12, 0, 12)
toggleLabel.BackgroundTransparency = 1
toggleLabel.TextColor3 = T.Text
toggleLabel.Font = T.Font
toggleLabel.TextSize = 14
toggleLabel.Text = "Activar medidor avanzado de FPS/Ping"
toggleLabel.Parent = toggleFrame

local toggleBg = Instance.new("Frame")
toggleBg.Size = UDim2.new(0, 44, 0, 22)
toggleBg.Position = UDim2.new(1, -56, 0, 14)
toggleBg.BackgroundColor3 = enabled and T.Green or T.Red
toggleBg.BorderSizePixel = 0
roundFrame(toggleBg, 11)
toggleBg.Parent = toggleFrame

local toggleKnob = Instance.new("Frame")
toggleKnob.Size = UDim2.new(0, 18, 0, 18)
toggleKnob.Position = enabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleKnob.BorderSizePixel = 0
roundFrame(toggleKnob, 9)
toggleKnob.Parent = toggleBg

local function updateToggleVisual(state)
	toggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	toggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

local positionSection = Instance.new("Frame")
positionSection.Size = UDim2.new(1, 0, 0, 0)
positionSection.BackgroundTransparency = 1
positionSection.AutomaticSize = Enum.AutomaticSize.Y
positionSection.Visible = enabled
positionSection.Parent = mainContainer

local positionSectionList = Instance.new("UIListLayout")
positionSectionList.Padding = UDim.new(0, 4)
positionSectionList.SortOrder = Enum.SortOrder.LayoutOrder
positionSectionList.Parent = positionSection

local posHeader = Instance.new("TextLabel")
posHeader.Size = UDim2.new(1, 0, 0, 22)
posHeader.BackgroundTransparency = 1
posHeader.Font = T.FontBold
posHeader.TextSize = 15
posHeader.TextColor3 = T.Text
posHeader.TextXAlignment = Enum.TextXAlignment.Left
posHeader.Text = "📍 Posición"
posHeader.Parent = positionSection

local positionIsCustom = (Menu.Settings.visuals_pingfps_position == "Personalizada")

local posBtn = Instance.new("TextButton")
posBtn.Size = UDim2.new(1, 0, 0, 52)
posBtn.BackgroundColor3 = T.Tertiary
posBtn.TextColor3 = T.Text
posBtn.Font = T.FontBold
posBtn.TextSize = 14
posBtn.BorderSizePixel = 0
posBtn.Text = "📍 " .. (positionIsCustom and "Personalizada" or "Default")
posBtn.AutoButtonColor = false
roundFrame(posBtn, 6)
posBtn.Parent = positionSection

posBtn.MouseEnter:Connect(function()
	TweenService:Create(posBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
end)
posBtn.MouseLeave:Connect(function()
	TweenService:Create(posBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end)

local customFrame = Instance.new("Frame")
customFrame.Size = UDim2.new(1, 0, 0, 100)
customFrame.BackgroundTransparency = 1
customFrame.Visible = positionIsCustom
customFrame.Parent = positionSection

local customXLabel = Instance.new("TextLabel")
customXLabel.Size = UDim2.new(0, 80, 0, 22)
customXLabel.Position = UDim2.new(0, 0, 0, 0)
customXLabel.BackgroundTransparency = 1
customXLabel.Font = T.Font
customXLabel.TextSize = 13
customXLabel.TextColor3 = T.TextDim
customXLabel.Text = "Offset X"
customXLabel.TextXAlignment = Enum.TextXAlignment.Left
customXLabel.Parent = customFrame

local customXBox = Instance.new("TextBox")
customXBox.Size = UDim2.new(0, 80, 0, 28)
customXBox.Position = UDim2.new(0, 88, 0, -3)
customXBox.BackgroundColor3 = T.Tertiary
customXBox.TextColor3 = T.Text
customXBox.Font = T.Font
customXBox.TextSize = 14
customXBox.Text = tostring(Menu.Settings.visuals_pingfps_custom_x)
customXBox.Parent = customFrame
roundFrame(customXBox, 4)

local customYLabel = Instance.new("TextLabel")
customYLabel.Size = UDim2.new(0, 80, 0, 22)
customYLabel.Position = UDim2.new(0, 0, 0, 40)
customYLabel.BackgroundTransparency = 1
customYLabel.Font = T.Font
customYLabel.TextSize = 13
customYLabel.TextColor3 = T.TextDim
customYLabel.Text = "Offset Y"
customYLabel.TextXAlignment = Enum.TextXAlignment.Left
customYLabel.Parent = customFrame

local customYBox = Instance.new("TextBox")
customYBox.Size = UDim2.new(0, 80, 0, 28)
customYBox.Position = UDim2.new(0, 88, 0, 37)
customYBox.BackgroundColor3 = T.Tertiary
customYBox.TextColor3 = T.Text
customYBox.Font = T.Font
customYBox.TextSize = 14
customYBox.Text = tostring(Menu.Settings.visuals_pingfps_custom_y)
customYBox.Parent = customFrame
roundFrame(customYBox, 4)

local function applyCustomValues()
	local x = tonumber(customXBox.Text)
	local y = tonumber(customYBox.Text)
	if x and y then
		Menu.Settings.visuals_pingfps_custom_x = x
		Menu.Settings.visuals_pingfps_custom_y = y
		if Menu.SaveSettings then Menu.SaveSettings() end
		updateStatsDisplay()
	end
end

customXBox.FocusLost:Connect(function()
	applyCustomValues()
end)
customYBox.FocusLost:Connect(function()
	applyCustomValues()
end)

posBtn.MouseButton1Click:Connect(function()
	local newPos = positionIsCustom and "Default" or "Personalizada"
	Menu.Settings.visuals_pingfps_position = newPos
	positionIsCustom = (newPos == "Personalizada")
	posBtn.Text = "📍 " .. newPos
	customFrame.Visible = positionIsCustom
	if Menu.SaveSettings then Menu.SaveSettings() end
	updateStatsDisplay()
end)

toggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.visuals_pingfps_enabled
		Menu.Settings.visuals_pingfps_enabled = newState
		enabled = newState
		updateToggleVisual(newState)
		positionSection.Visible = enabled
		if Menu.SaveSettings then Menu.SaveSettings() end
		updateStatsDisplay()
	end
end)

updateStatsDisplay()

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end