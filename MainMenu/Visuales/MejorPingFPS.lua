local CONFIG = {
    Name = "Activar Mejor Visualizador de FPS/Ping",
    Description = "Muestra FPS y ping con sus valores reales y colores según su rango.",
    SettingKey = "visuals_pingfps_enabled",
    PositionKey = "visuals_pingfps_position",
    CustomXKey = "visuals_pingfps_custom_x",
    CustomYKey = "visuals_pingfps_custom_y",
    DefaultEnabled = false,
    DefaultX = 10,
    DefaultY = 10,
    PositionSectionHeader = "Posición",
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
    if label:GetAttribute("SM_Protected") then
        return true
    end
    local gui = menuGui or PlayerGui:FindFirstChild("ScriptedMemoriesUI")
    return gui ~= nil and label:IsDescendantOf(gui)
end

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
        if isProtectedLabel(label) then
            return
        end
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
    Menu.Settings[CONFIG.PositionKey] = "SuperiorDerecha"
end
if not Menu.Settings[CONFIG.CustomXKey] then
    Menu.Settings[CONFIG.CustomXKey] = CONFIG.DefaultX
end
if not Menu.Settings[CONFIG.CustomYKey] then
    Menu.Settings[CONFIG.CustomYKey] = CONFIG.DefaultY
end

local POSITIONS = {
    SuperiorDerecha = {
        label = "Superior Derecha",
        anchor = Vector2.new(1, 0),
        pos = UDim2.new(1, -10, 0, 10),
        align = Enum.TextXAlignment.Right
    },
    InferiorDerecha = {
        label = "Inferior Derecha",
        anchor = Vector2.new(1, 1),
        pos = UDim2.new(1, -10, 1, -10),
        align = Enum.TextXAlignment.Right
    },
    SuperiorIzquierda = {
        label = "Superior Izquierda",
        anchor = Vector2.new(0, 0),
        pos = UDim2.new(0, 10, 0, 10),
        align = Enum.TextXAlignment.Left
    },
    InferiorIzquierda = {
        label = "Inferior Izquierda",
        anchor = Vector2.new(0, 1),
        pos = UDim2.new(0, 10, 1, -10),
        align = Enum.TextXAlignment.Left
    }
}
local POS_NAMES = {"SuperiorDerecha", "InferiorDerecha", "SuperiorIzquierda", "InferiorIzquierda"}

local function getPositionData()
    local posKey = Menu.Settings[CONFIG.PositionKey]
    if posKey == "Personalizada" then
        return {
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, Menu.Settings[CONFIG.CustomXKey], 0, Menu.Settings[CONFIG.CustomYKey]),
            TextAlign = Enum.TextXAlignment.Right
        }
    end
    local cfg = POSITIONS[posKey]
    if cfg then
        return {
            AnchorPoint = cfg.anchor,
            Position = cfg.pos,
            TextAlign = cfg.align
        }
    end
    local def = POSITIONS.SuperiorDerecha
    return {
        AnchorPoint = def.anchor,
        Position = def.pos,
        TextAlign = def.align
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
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextXAlignment = posData.TextAlign or Enum.TextXAlignment.Right
    label.RichText = true
    label.Parent = gui

    local textSizeConstraint = Instance.new("UITextSizeConstraint")
    textSizeConstraint.MaxTextSize = 15
    textSizeConstraint.MinTextSize = 11
    textSizeConstraint.Parent = label

    StatsGui = gui
    _G._StatsGui = gui

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
infoText(textFrame, CONFIG.Description, T.Font, 12, T.TextDim)

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

-- ===== SECCIÓN DE POSICIÓN (REEMPLAZADA) =====
local positionSection = card(sectionFrame)
positionSection.Visible = enabled

infoText(positionSection, CONFIG.PositionSectionHeader, T.FontBold, 14, T.Text)

local posGrid = Instance.new("Frame")
posGrid.Size = UDim2.new(1, 0, 0, 0)
posGrid.AutomaticSize = Enum.AutomaticSize.Y
posGrid.BackgroundTransparency = 1
posGrid.Parent = positionSection

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 120, 0, 32)
gridLayout.CellPadding = UDim.new(0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
gridLayout.Parent = posGrid

local function makePosButton(text, posKey, isCustom)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 32)
    btn.BackgroundColor3 = T.Tertiary
    btn.TextColor3 = T.Text
    btn.Font = T.FontBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text
    btn.Parent = posGrid
    roundFrame(btn, 4)

    local isActive = (not isCustom and Menu.Settings[CONFIG.PositionKey] == posKey) or
                     (isCustom and Menu.Settings[CONFIG.PositionKey] == "Personalizada")
    if isActive then
        btn.BackgroundColor3 = T.Hover
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if (not isCustom and Menu.Settings[CONFIG.PositionKey] ~= posKey) or
           (isCustom and Menu.Settings[CONFIG.PositionKey] ~= "Personalizada") then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
        end
    end)

    return btn
end

local posButtons = {}
for _, key in ipairs(POS_NAMES) do
    local btn = makePosButton(POSITIONS[key].label, key, false)
    btn.MouseButton1Click:Connect(function()
        Menu.Settings[CONFIG.PositionKey] = key
        if Menu.SaveSettings then Menu.SaveSettings() end
        for _, b in ipairs(posButtons) do
            b.BackgroundColor3 = T.Tertiary
        end
        btn.BackgroundColor3 = T.Hover
        if _G._posEditorActive then
            _G._posEditorActive = false
            if _G._posEditorGui then _G._posEditorGui:Destroy() end
            Menu:Toggle(true)
        end
        updateStatsDisplay()
        if Menu.UpdateCanvas then Menu.UpdateCanvas() end
    end)
    table.insert(posButtons, btn)
end

local customBtn = makePosButton("✎ Personalizada", nil, true)
customBtn.MouseButton1Click:Connect(function()
    if Menu.Settings[CONFIG.PositionKey] == "Personalizada" then
    end
    startPositionEditor()
end)
table.insert(posButtons, customBtn)

local function startPositionEditor()
    if _G._posEditorActive then return end
    _G._posEditorActive = true

    Menu:Toggle(false)

    local editorGui = Instance.new("ScreenGui")
    editorGui.Name = "PositionEditorGui"
    editorGui.ResetOnSpawn = false
    editorGui.DisplayOrder = 999999
    editorGui.Parent = PlayerGui
    _G._posEditorGui = editorGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.6
    bg.BorderSizePixel = 0
    bg.Parent = editorGui

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 150, 0, 40)
    saveBtn.Position = UDim2.new(1, -170, 1, -60)
    saveBtn.AnchorPoint = Vector2.new(1, 1)
    saveBtn.BackgroundColor3 = T.Green
    saveBtn.TextColor3 = T.Text
    saveBtn.Font = T.FontBold
    saveBtn.TextSize = 16
    saveBtn.Text = "Guardar y Aceptar"
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = editorGui
    roundFrame(saveBtn, 6)

    saveBtn.MouseEnter:Connect(function()
        TweenService:Create(saveBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 220, 120)}):Play()
    end)
    saveBtn.MouseLeave:Connect(function()
        TweenService:Create(saveBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Green}):Play()
    end)

    if StatsGui then
        StatsGui.DisplayOrder = 1000001
    end

    local dragging = false
    local dragStart, startPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local label = StatsGui and StatsGui:FindFirstChild("StatsLabel")
            if label and label.AbsoluteSize.X > 0 then
                local mousePos = input.Position
                local labelPos = label.AbsolutePosition
                local labelSize = label.AbsoluteSize
                if mousePos.X >= labelPos.X and mousePos.X <= labelPos.X + labelSize.X and
                   mousePos.Y >= labelPos.Y and mousePos.Y <= labelPos.Y + labelSize.Y then
                    dragging = true
                    dragStart = input.Position
                    startPos = label.Position
                end
            end
        end
    end

    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local label = StatsGui and StatsGui:FindFirstChild("StatsLabel")
            if label then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                label.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end

    local connections = {}
    connections[1] = game:GetService("UserInputService").InputBegan:Connect(onInputBegan)
    connections[2] = game:GetService("UserInputService").InputChanged:Connect(onInputChanged)
    connections[3] = game:GetService("UserInputService").InputEnded:Connect(onInputEnded)

    saveBtn.MouseButton1Click:Connect(function()
        local label = StatsGui and StatsGui:FindFirstChild("StatsLabel")
        if label then
            local pos = label.Position
            Menu.Settings[CONFIG.CustomXKey] = math.round(pos.X.Offset)
            Menu.Settings[CONFIG.CustomYKey] = math.round(pos.Y.Offset)
            Menu.Settings[CONFIG.PositionKey] = "Personalizada"
            if Menu.SaveSettings then Menu.SaveSettings() end
            for _, b in ipairs(posButtons) do
                b.BackgroundColor3 = T.Tertiary
            end
            customBtn.BackgroundColor3 = T.Hover
            updateStatsDisplay()
        end

        _G._posEditorActive = false
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        if _G._posEditorGui then
            _G._posEditorGui:Destroy()
            _G._posEditorGui = nil
        end
        if StatsGui then
            StatsGui.DisplayOrder = 1000000
        end
        Menu:Toggle(true)
        if Menu.UpdateCanvas then Menu.UpdateCanvas() end
    end)

    editorGui.AncestryChanged:Connect(function()
        if not editorGui.Parent then
            _G._posEditorActive = false
            for _, conn in ipairs(connections) do
                conn:Disconnect()
            end
            if StatsGui then
                StatsGui.DisplayOrder = 1000000
            end
            Menu:Toggle(true)
        end
    end)
end
-- ===== FIN SECCIÓN POSICIÓN =====

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