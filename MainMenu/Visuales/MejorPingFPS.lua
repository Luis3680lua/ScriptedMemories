local CONFIG = {
    Name = "Activar Mejor Visualizador de FPS/Ping",
    Description = "Muestra FPS y ping con sus valores reales y colores según su rango.",
    SettingKey = "visuals_pingfps_enabled",
    PositionKey = "visuals_pingfps_position",
    DefaultEnabled = false,
    DefaultPosition = "Arriba Derecha",
    PositionSectionHeader = "Posición",
    PositionButtonPrefix = "",

    -- ══════════════════════════════════════════════════════
    -- Posiciones predefinidas (el usuario elige una)
    -- ══════════════════════════════════════════════════════
    PositionPresets = {
        {
            Name = "Arriba Derecha",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -10, 0, 10),
            TextXAlignment = Enum.TextXAlignment.Right,
        },
        {
            Name = "Arriba Izquierda",
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, 10, 0, 36),
            TextXAlignment = Enum.TextXAlignment.Left,
        },
        {
            Name = "Abajo Derecha",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -10, 1, -10),
            TextXAlignment = Enum.TextXAlignment.Right,
        },
        {
            Name = "Abajo Izquierda",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 10, 1, -5),
            TextXAlignment = Enum.TextXAlignment.Left,
        },
    },

    -- ══════════════════════════════════════════════════════
    -- Disabled = true  -> el ajuste queda apagado a la fuerza,
    --   sin importar lo que el usuario tenga guardado.
    -- UseDefault = true -> mientras Disabled, el efecto real
    --   usado es CONFIG.DefaultEnabled (no el valor guardado).
    --   UseDefault = false -> mientras Disabled, no hace nada,
    --   sin importar el default ni el guardado.
    -- ══════════════════════════════════════════════════════
    Disabled = false,
    UseDefault = false,
}

local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldStatsGui = PlayerGui:FindFirstChild("RealStatsGuiLeft")
if oldStatsGui then
    oldStatsGui:Destroy()
end

local PingThresholds = {10, 20, 35, 50, 70, 90, 110, 140, 170, 220}
local PingColors = {"#0077ff", "#00b7ff", "#00ff66", "#66ff33", "#bfff00", "#ffff00", "#ffd000", "#ff9900", "#ff6600", "#ff2d00", "#c80000"}
local FpsThresholds = {240, 165, 120, 90, 75, 60, 50, 40, 30, 20}
local FpsColors = {"#b000ff", "#0077ff", "#00c8ff", "#00ff66", "#66ff33", "#66ff00", "#ffff00", "#ffb000", "#ff7700", "#ff2200", "#c80000"}

local function GetPingColor(ping)
    for i = 1, #PingThresholds do
        if ping <= PingThresholds[i] then return PingColors[i] end
    end
    return PingColors[#PingColors]
end

local function GetFpsColor(fps)
    for i = 1, #FpsThresholds do
        if fps >= FpsThresholds[i] then return FpsColors[i] end
    end
    return FpsColors[#FpsColors]
end

local slower = string.lower
local hiddenLabels = {}
local descendantConnection = nil
local menuGui = PlayerGui:FindFirstChild("ScriptedMemoriesUI")

local function looksLikeStatReadout(text)
    return text:match("%d+%s*fps") ~= nil
        or text:match("fps%s*:?%s*%d+") ~= nil
        or text:match("%d+%s*ms") ~= nil
        or text:match("ms%s*:?%s*%d+") ~= nil
end

local function isProtectedLabel(label)
    if label:GetAttribute("SM_Protected") then return true end
    local gui = menuGui or PlayerGui:FindFirstChild("ScriptedMemoriesUI")
    return gui ~= nil and label:IsDescendantOf(gui)
end

local function restoreOriginalLabels()
    for _, label in ipairs(hiddenLabels) do
        pcall(function() label.Visible = true end)
    end
    hiddenLabels = {}
end

local function hideSingleLabel(label)
    if label:IsA("TextLabel") and label.Name ~= "StatsLabel" then
        if isProtectedLabel(label) then return end
        local text = slower(label.Text)
        if looksLikeStatReadout(text) then
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

local function getEffectiveEnabled()
    if CONFIG.Disabled then
        return CONFIG.UseDefault and CONFIG.DefaultEnabled or false
    end
    return Menu.Settings[CONFIG.SettingKey]
end

local function getPresetByName(name)
    for _, preset in ipairs(CONFIG.PositionPresets) do
        if preset.Name == name then
            return preset
        end
    end
    -- fallback al primero (por si acaso)
    return CONFIG.PositionPresets[1]
end

local function getPositionData()
    local presetName = Menu.Settings[CONFIG.PositionKey] or CONFIG.DefaultPosition
    local preset = getPresetByName(presetName)
    return {
        AnchorPoint = preset.AnchorPoint,
        Position = preset.Position,
        TextXAlignment = preset.TextXAlignment,
    }
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

    if not getEffectiveEnabled() then
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
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000000
    gui.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Name = "StatsLabel"
    label.Size = UDim2.new(0.35, 0, 0.035, 0)
    label.SizeConstraint = Enum.SizeConstraint.RelativeXY
    label.AnchorPoint = posData.AnchorPoint
    label.Position = posData.Position
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextXAlignment = posData.TextXAlignment or Enum.TextXAlignment.Right
    label.RichText = true
    label.Parent = gui

    local textSizeConstraint = Instance.new("UITextSizeConstraint")
    textSizeConstraint.MaxTextSize = 15
    textSizeConstraint.MinTextSize = 11
    textSizeConstraint.Parent = label

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

Menu:RegisterDefault(page, CONFIG.SettingKey, CONFIG.DefaultEnabled)
Menu:RegisterDefault(page, CONFIG.PositionKey, CONFIG.DefaultPosition)

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 18
local KNOB_SIZE = 14
local KNOB_OFFSET = 2

local DISABLED_COLOR = Color3.fromRGB(45, 45, 52)

local function roundFrame(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or RADIUS)
    c.Parent = frame
    return c
end

local function card(parent)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundColor3 = T.Secondary
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Parent = parent
    roundFrame(f, RADIUS)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, PADDING)
    padding.PaddingRight = UDim.new(0, PADDING)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = f

    return f
end

local function infoText(parent, text, font, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.Font = font or T.Font
    l.TextSize = size or 14
    l.TextColor3 = color or T.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Text = text
    l:SetAttribute("SM_Protected", true)
    l.Parent = parent
    return l
end

local sectionFrame = card(page.Frame)

local optionFrame = Instance.new("Frame")
optionFrame.Size = UDim2.new(1, 0, 0, 0)
optionFrame.AutomaticSize = Enum.AutomaticSize.Y
optionFrame.BackgroundTransparency = 1
optionFrame.Parent = sectionFrame

local optionLayout = Instance.new("UIListLayout")
optionLayout.FillDirection = Enum.FillDirection.Horizontal
optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionLayout.Padding = UDim.new(0, 10)
optionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionLayout.Parent = optionFrame

local textFrame = Instance.new("Frame")
textFrame.Size = UDim2.new(1, -(SWITCH_WIDTH + 10), 0, 0)
textFrame.AutomaticSize = Enum.AutomaticSize.Y
textFrame.BackgroundTransparency = 1
textFrame.Parent = optionFrame

local textLayout = Instance.new("UIListLayout")
textLayout.Padding = UDim.new(0, 2)
textLayout.SortOrder = Enum.SortOrder.LayoutOrder
textLayout.Parent = textFrame

local nameText = CONFIG.Disabled and (CONFIG.Name .. "  🔒") or CONFIG.Name
infoText(textFrame, nameText, T.FontBold, 14, CONFIG.Disabled and T.TextDim or T.Text)
infoText(textFrame, CONFIG.Description, T.Font, 12, T.TextDim)

local enabled = Menu.Settings[CONFIG.SettingKey]

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
switchFrame.BackgroundColor3 = CONFIG.Disabled and DISABLED_COLOR or (enabled and T.Green or T.Red)
switchFrame.BorderSizePixel = 0
switchFrame.Parent = optionFrame
roundFrame(switchFrame, SWITCH_HEIGHT / 2)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
switchKnob.Position = enabled and
    UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
    UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
switchKnob.BackgroundColor3 = CONFIG.Disabled and Color3.fromRGB(90, 90, 96) or Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame
roundFrame(switchKnob, KNOB_SIZE / 2)

local function updateToggleVisual(state)
    switchFrame.BackgroundColor3 = state and T.Green or T.Red
    local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
    TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
    }):Play()
end

-- ─── Sección de posición ───
local positionSection = card(sectionFrame)
positionSection.Visible = getEffectiveEnabled()

infoText(positionSection, CONFIG.PositionSectionHeader, T.FontBold, 14, T.Text)

local currentPresetIndex = 1
local presetNames = {}
for i, preset in ipairs(CONFIG.PositionPresets) do
    presetNames[i] = preset.Name
    if preset.Name == Menu.Settings[CONFIG.PositionKey] then
        currentPresetIndex = i
    end
end

local posBtn = Instance.new("TextButton")
posBtn.Size = UDim2.new(1, 0, 0, 36)
posBtn.BackgroundColor3 = T.Tertiary
posBtn.TextColor3 = T.Text
posBtn.Font = T.FontBold
posBtn.TextSize = 14
posBtn.BorderSizePixel = 0
posBtn.AutoButtonColor = false
posBtn.Text = CONFIG.PositionButtonPrefix .. presetNames[currentPresetIndex]
posBtn.Parent = positionSection
roundFrame(posBtn, RADIUS)

posBtn.MouseEnter:Connect(function()
    TweenService:Create(posBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
end)
posBtn.MouseLeave:Connect(function()
    TweenService:Create(posBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end)

posBtn.MouseButton1Click:Connect(function()
    currentPresetIndex = currentPresetIndex % #presetNames + 1
    local newPreset = presetNames[currentPresetIndex]
    Menu.Settings[CONFIG.PositionKey] = newPreset
    posBtn.Text = CONFIG.PositionButtonPrefix .. newPreset
    if Menu.SaveSettings then Menu.SaveSettings() end
    updateStatsDisplay()
    if page.RefreshResetButton then page.RefreshResetButton() end
end)

if not CONFIG.Disabled then
    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newState = not Menu.Settings[CONFIG.SettingKey]
            Menu.Settings[CONFIG.SettingKey] = newState
            enabled = newState
            updateToggleVisual(newState)
            positionSection.Visible = getEffectiveEnabled()
            if Menu.SaveSettings then Menu.SaveSettings() end
            updateStatsDisplay()
            if page.RefreshResetButton then page.RefreshResetButton() end
            if Menu.UpdateCanvas then Menu.UpdateCanvas() end
        end
    end)
end

updateStatsDisplay()

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end