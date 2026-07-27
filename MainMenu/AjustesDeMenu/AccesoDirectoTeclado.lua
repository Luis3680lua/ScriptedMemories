local CONFIG = {
    Name = "Atajo de Teclado",
    Description = "Cambia la tecla que abre y cierra el menú.",
    SettingKey = "menu_keybind",
    Default = "M",
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

local function keyCodeToName(keyCode)
    if not keyCode then return "Desconocida" end
    local name = tostring(keyCode):gsub("^Enum%.KeyCode%.", "")
    name = name:gsub("RightControl", "Ctrl Der.")
    name = name:gsub("LeftControl", "Ctrl Izq.")
    name = name:gsub("RightShift", "Shift Der.")
    name = name:gsub("LeftShift", "Shift Izq.")
    name = name:gsub("RightAlt", "Alt Der.")
    name = name:gsub("LeftAlt", "Alt Izq.")
    name = name:gsub("Backspace", "Retroceso")
    name = name:gsub("Return", "Enter")
    name = name:gsub("Space", "Espacio")
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

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(0, CONFIG.ButtonWidth, 0, CONFIG.ButtonHeight)
keybindBtn.BackgroundColor3 = T.Tertiary
keybindBtn.BorderSizePixel = 0
keybindBtn.AutoButtonColor = false
keybindBtn.Font = T.FontBold
keybindBtn.TextSize = 15
keybindBtn.TextColor3 = T.Text
keybindBtn.Text = keyCodeToName(currentKeyCode)
keybindBtn.Parent = optionFrame
roundFrame(keybindBtn, RADIUS)

local capturingKeyboard = false
local captureKeyboardConn
local dotsTask = nil

local function stopKeyboardCapture(cancelled)
    capturingKeyboard = false
    Menu._capturingKey = false
    if captureKeyboardConn then
        captureKeyboardConn:Disconnect()
        captureKeyboardConn = nil
    end
    if dotsTask then
        task.cancel(dotsTask)
        dotsTask = nil
    end
    local activeKeyName = Menu.Settings[CONFIG.SettingKey] or CONFIG.Default
    local activeKeyCode = Enum.KeyCode[activeKeyName] or Enum.KeyCode[CONFIG.Default]
    keybindBtn.Text = keyCodeToName(activeKeyCode)
    TweenService:Create(keybindBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end

local function startKeyboardCapture()
    if capturingKeyboard then return end
    capturingKeyboard = true
    Menu._capturingKey = true
    TweenService:Create(keybindBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Accent}):Play()

    dotsTask = task.spawn(function()
        local dots = 0
        while capturingKeyboard do
            dots = (dots % 3) + 1
            keybindBtn.Text = "Presiona..." .. string.rep(".", dots - 1)
            task.wait(0.4)
        end
    end)

    captureKeyboardConn = UIS.InputBegan:Connect(function(input)
        if not capturingKeyboard then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.Unknown then return end

        if input.KeyCode == Enum.KeyCode.Escape then
            stopKeyboardCapture(true)
            return
        end

        local newKey = tostring(input.KeyCode):gsub("^Enum%.KeyCode%.", "")
        Menu.Settings[CONFIG.SettingKey] = newKey
        if Menu.SaveSettings then Menu.SaveSettings() end
        stopKeyboardCapture(false)
    end)
end

keybindBtn.MouseButton1Down:Connect(function()
    if not capturingKeyboard then
        startKeyboardCapture()
    end
end)

keybindBtn.MouseEnter:Connect(function()
    if not capturingKeyboard then
        TweenService:Create(keybindBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
    end
end)
keybindBtn.MouseLeave:Connect(function()
    if not capturingKeyboard then
        TweenService:Create(keybindBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end