local CONFIG = {
    Name = "Atajo de Control",
    Description = "Cambia el botón del control que abre y cierra el menú.",
    SettingKey = "menu_controller_keybind",
    Default = "ButtonL3",
    ButtonWidth = 150,
    ButtonHeight = 40
}

local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12

local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or RADIUS)
    corner.Parent = frame
    return corner
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
    l.Parent = parent
    return l
end

local function gamepadButtonToName(buttonEnum)
    if not buttonEnum then return "Desconocido" end
    local name = tostring(buttonEnum):gsub("^Enum%.KeyCode%.", "")
    local map = {
        ButtonA = "A", ButtonB = "B", ButtonX = "X", ButtonY = "Y",
        ButtonL1 = "LB", ButtonR1 = "RB", ButtonL2 = "LT", ButtonR2 = "RT",
        ButtonL3 = "L3", ButtonR3 = "R3",
        DPadUp = "D-Pad Arriba", DPadDown = "D-Pad Abajo",
        DPadLeft = "D-Pad Izquierda", DPadRight = "D-Pad Derecha",
        Start = "Start", Select = "Select"
    }
    if map[name] then return map[name] end
    name = name:gsub("Button", "Botón ")
    name = name:gsub("DPad", "D-Pad ")
    return name
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local currentKeyName = Menu.Settings[CONFIG.SettingKey] or CONFIG.Default
local currentKeyCode = Enum.KeyCode[currentKeyName] or Enum.KeyCode[CONFIG.Default]

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
textFrame.Size = UDim2.new(1, -(CONFIG.ButtonWidth + 10), 0, 0)
textFrame.AutomaticSize = Enum.AutomaticSize.Y
textFrame.BackgroundTransparency = 1
textFrame.Parent = optionFrame

local textLayout = Instance.new("UIListLayout")
textLayout.Padding = UDim.new(0, 2)
textLayout.SortOrder = Enum.SortOrder.LayoutOrder
textLayout.Parent = textFrame

infoText(textFrame, CONFIG.Name, T.FontBold, 14, T.Text)
infoText(textFrame, CONFIG.Description, T.Font, 12, T.TextDim)

local controllerBtn = Instance.new("TextButton")
controllerBtn.Size = UDim2.new(0, CONFIG.ButtonWidth, 0, CONFIG.ButtonHeight)
controllerBtn.BackgroundColor3 = T.Tertiary
controllerBtn.BorderSizePixel = 0
controllerBtn.AutoButtonColor = false
controllerBtn.Font = T.FontBold
controllerBtn.TextSize = 15
controllerBtn.TextColor3 = T.Text
controllerBtn.Text = gamepadButtonToName(currentKeyCode)
controllerBtn.Parent = optionFrame
roundFrame(controllerBtn, RADIUS)

local capturingController = false
local captureControllerConn
local dotsTask = nil

local function stopControllerCapture()
    capturingController = false
    Menu._capturingKey = false
    if captureControllerConn then
        captureControllerConn:Disconnect()
        captureControllerConn = nil
    end
    if dotsTask then
        task.cancel(dotsTask)
        dotsTask = nil
    end
    local activeKeyName = Menu.Settings[CONFIG.SettingKey] or CONFIG.Default
    local activeKeyCode = Enum.KeyCode[activeKeyName] or Enum.KeyCode[CONFIG.Default]
    controllerBtn.Text = gamepadButtonToName(activeKeyCode)
    TweenService:Create(controllerBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end

local function startControllerCapture()
    if capturingController then return end
    capturingController = true
    Menu._capturingKey = true
    TweenService:Create(controllerBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Accent}):Play()

    dotsTask = task.spawn(function()
        local dots = 0
        while capturingController do
            dots = (dots % 3) + 1
            controllerBtn.Text = "Presiona..." .. string.rep(".", dots - 1)
            task.wait(0.4)
        end
    end)

    captureControllerConn = UIS.InputBegan:Connect(function(input)
        if not capturingController then return end

        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
            stopControllerCapture()
            return
        end

        if input.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
        local btn = input.KeyCode
        if btn == Enum.KeyCode.Unknown then return end

        local newKey = tostring(btn):gsub("^Enum%.KeyCode%.", "")
        Menu.Settings[CONFIG.SettingKey] = newKey
        if Menu.SaveSettings then Menu.SaveSettings() end
        stopControllerCapture()
    end)
end

controllerBtn.MouseButton1Down:Connect(function()
    if not capturingController then
        startControllerCapture()
    end
end)

controllerBtn.MouseEnter:Connect(function()
    if not capturingController then
        TweenService:Create(controllerBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
    end
end)
controllerBtn.MouseLeave:Connect(function()
    if not capturingController then
        TweenService:Create(controllerBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end