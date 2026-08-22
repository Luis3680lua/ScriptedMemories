local CONFIG = {
    Name = "Mostrar Ping Real",
    Description = "Muestra el ping real (sin multiplicar por 2). Oculta el contador de ping falso del juego.",
    SettingKey = "real_ping_enabled",
    PositionKey = "real_ping_position",
    DefaultEnabled = false,
    DefaultPosition = "Arriba Derecha",
    PositionSectionHeader = "Posición",
    PositionButtonPrefix = "",

    -- ══════════════════════════════════════════════════════
    -- Posiciones predefinidas
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
            Position = UDim2.new(0, 10, 0, 62),
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
}

local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Eliminar si ya existe una instancia anterior
local oldPingGui = PlayerGui:FindFirstChild("RealPingGui")
if oldPingGui then
    oldPingGui:Destroy()
end

-- Palabras clave para detectar el ping falso (el juego usa "MS")
local KEYWORDS = { "%d+%s*ms", "ms%s*:?%s*%d+" }

local hiddenElements = {}
local descendantConnection = nil

local function containsPingText(text)
    local lower = string.lower(text or "")
    for _, pattern in ipairs(KEYWORDS) do
        if lower:match(pattern) then
            return true
        end
    end
    return false
end

local function isProtectedLabel(label)
    if label:GetAttribute("SM_Protected") then return true end
    local gui = PlayerGui:FindFirstChild("ScriptedMemoriesUI")
    return gui ~= nil and label:IsDescendantOf(gui)
end

local function restoreElements()
    for element, _ in pairs(hiddenElements) do
        pcall(function() element.Visible = true end)
    end
    hiddenElements = {}
end

local function hideElement(element)
    if element:GetAttribute("SM_Protected") then return end
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        if containsPingText(element.Text) then
            if not hiddenElements[element] then
                hiddenElements[element] = true
                element.Visible = false
            end
        end
    end
end

local function scanAndHideAll()
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        hideElement(v)
    end
end

if Menu.Settings[CONFIG.SettingKey] == nil then
    Menu.Settings[CONFIG.SettingKey] = CONFIG.DefaultEnabled
end
if not Menu.Settings[CONFIG.PositionKey] then
    Menu.Settings[CONFIG.PositionKey] = CONFIG.DefaultPosition
end

local function getPresetByName(name)
    for _, preset in ipairs(CONFIG.PositionPresets) do
        if preset.Name == name then
            return preset
        end
    end
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

local PingGui = nil
local HeartbeatConnection = nil

local function updatePingDisplay()
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
    if PingGui then
        PingGui:Destroy()
        PingGui = nil
    end
    if descendantConnection then
        descendantConnection:Disconnect()
        descendantConnection = nil
    end

    if not Menu.Settings[CONFIG.SettingKey] then
        restoreElements()
        return
    end

    scanAndHideAll()
    descendantConnection = PlayerGui.DescendantAdded:Connect(hideElement)

    local posData = getPositionData()

    local gui = Instance.new("ScreenGui")
    gui.Name = "RealPingGui"
    gui.ResetOnSpawn = false
    gui.ScreenInsets = Enum.ScreenInsets.None
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 1000001
    gui.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Name = "PingLabel"
    label.Size = UDim2.new(0.2, 0, 0.035, 0)
    label.SizeConstraint = Enum.SizeConstraint.RelativeXY
    label.AnchorPoint = posData.AnchorPoint
    label.Position = posData.Position
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextXAlignment = posData.TextXAlignment or Enum.TextXAlignment.Right
    label.RichText = true
    label.Text = ""
    label:SetAttribute("SM_Protected", true)
    label.Parent = gui

    local textSizeConstraint = Instance.new("UITextSizeConstraint")
    textSizeConstraint.MaxTextSize = 15
    textSizeConstraint.MinTextSize = 11
    textSizeConstraint.Parent = label

    PingGui = gui

    HeartbeatConnection = RunService.Heartbeat:Connect(function()
        local realPing = math.round(LocalPlayer:GetNetworkPing() * 1000) -- ✅ Ping real (sin x2)
        label.Text = string.format("<font color=\"#00b7ff\">%s MS</font>", realPing)
    end)
end

-- ─── UI ───
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

infoText(textFrame, CONFIG.Name, T.FontBold, 14, T.Text)

local descLabel = infoText(textFrame, CONFIG.Description, T.Font, 12, T.TextDim)
descLabel.Visible = false

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
    TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
    }):Play()
end

optionFrame.MouseEnter:Connect(function()
    descLabel.Visible = true
end)
optionFrame.MouseLeave:Connect(function()
    descLabel.Visible = false
end)

-- Sección de posición
local positionSection = card(sectionFrame)
positionSection.Visible = enabled

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
    updatePingDisplay()
    if page.RefreshResetButton then page.RefreshResetButton() end
end)

switchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local newState = not Menu.Settings[CONFIG.SettingKey]
        Menu.Settings[CONFIG.SettingKey] = newState
        enabled = newState
        updateToggleVisual(newState)
        positionSection.Visible = enabled
        if Menu.SaveSettings then Menu.SaveSettings() end
        updatePingDisplay()
        if page.RefreshResetButton then page.RefreshResetButton() end
        if Menu.UpdateCanvas then Menu.UpdateCanvas() end
    end
end)

updatePingDisplay()

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end