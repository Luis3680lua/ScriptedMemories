local CONFIG = {
    Name = "Activar Mejor Visualizador de FPS/Ping",
    Description = "Muestra FPS y ping con sus valores reales y colores según su rango.",
    SettingKey = "visuals_pingfps_enabled",
    PositionKey = "visuals_pingfps_position",
    CustomXKey = "visuals_pingfps_custom_x",
    CustomYKey = "visuals_pingfps_custom_y",
    DefaultEnabled = false,
    DefaultPosition = "Default",
    DefaultX = 10,
    DefaultY = 10,
    PositionSectionHeader = "Posición",
    PositionDefaultLabel = "Default",
    PositionCustomLabel = "Personalizada",
    PositionButtonPrefix = "",
    CustomOffsetXLabel = "Offset X",
    CustomOffsetYLabel = "Offset Y"
}

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
local menuGui = PlayerGui:FindFirstChild("ScriptedMemoriesUI")

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
        if menuGui and label:IsDescendantOf(menuGui) then
            return
        end
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

if Menu.Settings[CONFIG.SettingKey] == nil then
    Menu.Settings[CONFIG.SettingKey] = CONFIG.DefaultEnabled
end
if not Menu.Settings[CONFIG.PositionKey] then
    Menu.Settings[CONFIG.PositionKey] = CONFIG.DefaultPosition
end
if not Menu.Settings[CONFIG.CustomXKey] then
    Menu.Settings[CONFIG.CustomXKey] = CONFIG.DefaultX
end
if not Menu.Settings[CONFIG.CustomYKey] then
    Menu.Settings[CONFIG.CustomYKey] = CONFIG.DefaultY
end

local DEFAULT_POS = {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 10)
}

local function getPositionData()
    local pos = Menu.Settings[CONFIG.PositionKey]
    if pos == CONFIG.PositionCustomLabel then
        return {
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, Menu.Settings[CONFIG.CustomXKey], 0, Menu.Settings[CONFIG.CustomYKey])
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

    if not Menu.Settings[CONFIG.SettingKey] then
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

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 18
local KNOB_SIZE = 14
local KNOB_OFFSET = 2
local ROW_HEIGHT = 28

local function roundFrame(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or RADIUS)
    c.Parent = frame
    return c
end

local function createLabel(parent, text, font, size, color, width, height, align)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(width or 0, 0, 0, height or 18)
    label.BackgroundTransparency = 1
    label.Font = font or T.Font
    label.TextSize = size or 14
    label.TextColor3 = color or T.Text
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = parent
    return label
end

local sectionFrame = Instance.new("Frame")
sectionFrame.Size = UDim2.new(1, 0, 0, 0)
sectionFrame.BackgroundColor3 = T.Secondary
sectionFrame.BackgroundTransparency = 0.15
sectionFrame.BorderSizePixel = 0
sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
sectionFrame.Parent = page.Frame
roundFrame(sectionFrame, RADIUS)

local sectionPadding = Instance.new("UIPadding")
sectionPadding.PaddingLeft = UDim.new(0, PADDING)
sectionPadding.PaddingRight = UDim.new(0, PADDING)
sectionPadding.PaddingTop = UDim.new(0, 6)
sectionPadding.PaddingBottom = UDim.new(0, 6)
sectionPadding.Parent = sectionFrame

local sectionLayout = Instance.new("UIListLayout")
sectionLayout.Padding = UDim.new(0, 6)
sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
sectionLayout.Parent = sectionFrame

local optionFrame = Instance.new("Frame")
optionFrame.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
optionFrame.BackgroundColor3 = T.Secondary
optionFrame.BackgroundTransparency = 0.15
optionFrame.BorderSizePixel = 0
optionFrame.Parent = sectionFrame
roundFrame(optionFrame, RADIUS)

local optionLayout = Instance.new("UIListLayout")
optionLayout.FillDirection = Enum.FillDirection.Horizontal
optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionLayout.Padding = UDim.new(0, 8)
optionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionLayout.Parent = optionFrame

local textFrame = Instance.new("Frame")
textFrame.Size = UDim2.new(1, -SWITCH_WIDTH - 20, 0, ROW_HEIGHT)
textFrame.BackgroundTransparency = 1
textFrame.Parent = optionFrame

local textLayout = Instance.new("UIListLayout")
textLayout.FillDirection = Enum.FillDirection.Horizontal
textLayout.SortOrder = Enum.SortOrder.LayoutOrder
textLayout.Padding = UDim.new(0, 4)
textLayout.VerticalAlignment = Enum.VerticalAlignment.Center
textLayout.Parent = textFrame

createLabel(textFrame, CONFIG.Name, T.FontBold, 14, T.Text, 0, ROW_HEIGHT)
createLabel(textFrame, "• " .. CONFIG.Description, T.Font, 11, T.TextDim, 0, ROW_HEIGHT)

local enabled = Menu.Settings[CONFIG.SettingKey]

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
switchFrame.BackgroundColor3 = enabled and T.Green or T.Red
switchFrame.BorderSizePixel = 0
switchFrame.Parent = optionFrame
roundFrame(switchFrame, SWITCH_HEIGHT / 2)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
switchKnob.Position = enabled and
    UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
    UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame
roundFrame(switchKnob, KNOB_SIZE / 2)

local function updateToggleVisual(state)
    switchFrame.BackgroundColor3 = state and T.Green or T.Red
    local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
    TweenService:Create(
        switchKnob,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad),
        { Position = UDim2.new(0, targetX, 0, KNOB_OFFSET) }
    ):Play()
end

local positionSection = Instance.new("Frame")
positionSection.Size = UDim2.new(1, 0, 0, 0)
positionSection.BackgroundColor3 = T.Secondary
positionSection.BackgroundTransparency = 0.15
positionSection.BorderSizePixel = 0
positionSection.AutomaticSize = Enum.AutomaticSize.Y
positionSection.Visible = enabled
positionSection.Parent = sectionFrame
roundFrame(positionSection, RADIUS)

local posSectionPadding = Instance.new("UIPadding")
posSectionPadding.PaddingLeft = UDim.new(0, PADDING)
posSectionPadding.PaddingRight = UDim.new(0, PADDING)
posSectionPadding.PaddingTop = UDim.new(0, 6)
posSectionPadding.PaddingBottom = UDim.new(0, 6)
posSectionPadding.Parent = positionSection

local posSectionLayout = Instance.new("UIListLayout")
posSectionLayout.Padding = UDim.new(0, 4)
posSectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
posSectionLayout.Parent = positionSection

createLabel(positionSection, CONFIG.PositionSectionHeader, T.FontBold, 14, T.Text, 1, 22)

local positionIsCustom = (Menu.Settings[CONFIG.PositionKey] == CONFIG.PositionCustomLabel)

local posBtn = Instance.new("TextButton")
posBtn.Size = UDim2.new(1, 0, 0, 36)
posBtn.BackgroundColor3 = T.Tertiary
posBtn.TextColor3 = T.Text
posBtn.Font = T.FontBold
posBtn.TextSize = 14
posBtn.BorderSizePixel = 0
posBtn.Text = CONFIG.PositionButtonPrefix .. (positionIsCustom and CONFIG.PositionCustomLabel or CONFIG.PositionDefaultLabel)
posBtn.AutoButtonColor = false
roundFrame(posBtn, RADIUS)
posBtn.Parent = positionSection

posBtn.MouseEnter:Connect(function()
    TweenService:Create(posBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
end)
posBtn.MouseLeave:Connect(function()
    TweenService:Create(posBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end)

local customFrame = Instance.new("Frame")
customFrame.Size = UDim2.new(1, 0, 0, 80)
customFrame.BackgroundColor3 = T.Secondary
customFrame.BackgroundTransparency = 0.15
customFrame.BorderSizePixel = 0
customFrame.Visible = positionIsCustom
customFrame.Parent = positionSection
roundFrame(customFrame, RADIUS)

local customPadding = Instance.new("UIPadding")
customPadding.PaddingLeft = UDim.new(0, PADDING)
customPadding.PaddingRight = UDim.new(0, PADDING)
customPadding.PaddingTop = UDim.new(0, 6)
customPadding.PaddingBottom = UDim.new(0, 6)
customPadding.Parent = customFrame

local customList = Instance.new("UIListLayout")
customList.Padding = UDim.new(0, 6)
customList.SortOrder = Enum.SortOrder.LayoutOrder
customList.Parent = customFrame

local customXRow = Instance.new("Frame")
customXRow.Size = UDim2.new(1, 0, 0, 30)
customXRow.BackgroundTransparency = 1
customXRow.Parent = customFrame

createLabel(customXRow, CONFIG.CustomOffsetXLabel, T.Font, 13, T.TextDim, 0, 22).Size = UDim2.new(0, 80, 0, 22)
local customXBox = Instance.new("TextBox")
customXBox.Size = UDim2.new(0, 80, 0, 26)
customXBox.Position = UDim2.new(0, 88, 0, 0)
customXBox.BackgroundColor3 = T.Tertiary
customXBox.TextColor3 = T.Text
customXBox.Font = T.Font
customXBox.TextSize = 14
customXBox.Text = tostring(Menu.Settings[CONFIG.CustomXKey])
customXBox.Parent = customXRow
roundFrame(customXBox, 4)

local customYRow = Instance.new("Frame")
customYRow.Size = UDim2.new(1, 0, 0, 30)
customYRow.BackgroundTransparency = 1
customYRow.Parent = customFrame

createLabel(customYRow, CONFIG.CustomOffsetYLabel, T.Font, 13, T.TextDim, 0, 22).Size = UDim2.new(0, 80, 0, 22)
local customYBox = Instance.new("TextBox")
customYBox.Size = UDim2.new(0, 80, 0, 26)
customYBox.Position = UDim2.new(0, 88, 0, 0)
customYBox.BackgroundColor3 = T.Tertiary
customYBox.TextColor3 = T.Text
customYBox.Font = T.Font
customYBox.TextSize = 14
customYBox.Text = tostring(Menu.Settings[CONFIG.CustomYKey])
customYBox.Parent = customYRow
roundFrame(customYBox, 4)

local function applyCustomValues()
    local x = tonumber(customXBox.Text)
    local y = tonumber(customYBox.Text)
    if x and y then
        Menu.Settings[CONFIG.CustomXKey] = x
        Menu.Settings[CONFIG.CustomYKey] = y
        if Menu.SaveSettings then Menu.SaveSettings() end
        updateStatsDisplay()
    end
end

customXBox.FocusLost:Connect(applyCustomValues)
customYBox.FocusLost:Connect(applyCustomValues)

posBtn.MouseButton1Click:Connect(function()
    local newPos = positionIsCustom and CONFIG.PositionDefaultLabel or CONFIG.PositionCustomLabel
    Menu.Settings[CONFIG.PositionKey] = newPos
    positionIsCustom = (newPos == CONFIG.PositionCustomLabel)
    posBtn.Text = CONFIG.PositionButtonPrefix .. newPos
    customFrame.Visible = positionIsCustom
    if Menu.SaveSettings then Menu.SaveSettings() end
    updateStatsDisplay()
end)

switchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local newState = not Menu.Settings[CONFIG.SettingKey]
        Menu.Settings[CONFIG.SettingKey] = newState
        enabled = newState
        updateToggleVisual(newState)
        positionSection.Visible = enabled
        if Menu.SaveSettings then Menu.SaveSettings() end
        updateStatsDisplay()
        if Menu.UpdateCanvas then
            Menu.UpdateCanvas()
        end
    end
end)

updateStatsDisplay()

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end