local CONFIG = {
    Name = "Ocultar aviso de servidor",
    Description = "Elimina el mensaje de 'SERVER VERSION' o 'OUTDATED SERVER' que aparece en pantalla.",
    SettingKey = "hide_server_version",
    DefaultEnabled = false,
    TargetPage = nil,
}

local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Palabras clave que detectan el mensaje
local KEYWORDS = { "server version", "outdated server" }

local hiddenElements = {}
local descendantConnections = {}

local function containsKeyword(text)
    local lower = string.lower(text or "")
    for _, kw in ipairs(KEYWORDS) do
        if string.find(lower, kw) then
            return true
        end
    end
    return false
end

-- ✅ Ahora respeta los elementos protegidos (menú incluido)
local function hideElement(element)
    if element:GetAttribute("SM_Protected") then return end
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        if containsKeyword(element.Text) then
            if not hiddenElements[element] then
                hiddenElements[element] = true
                element.Visible = false
            end
        end
    end
end

local function scanContainer(container)
    for _, child in ipairs(container:GetDescendants()) do
        hideElement(child)
    end
end

local function connectContainer(container)
    if descendantConnections[container] then return end
    local conn = container.DescendantAdded:Connect(function(descendant)
        hideElement(descendant)
    end)
    descendantConnections[container] = conn
end

local function disconnectAll()
    for container, conn in pairs(descendantConnections) do
        if conn then
            conn:Disconnect()
        end
        descendantConnections[container] = nil
    end
end

local function restoreElements()
    for element, _ in pairs(hiddenElements) do
        pcall(function() element.Visible = true end)
    end
    hiddenElements = {}
end

local function applyState()
    disconnectAll()
    restoreElements()

    if Menu.Settings[CONFIG.SettingKey] then
        scanContainer(PlayerGui)
        connectContainer(PlayerGui)

        scanContainer(CoreGui)
        connectContainer(CoreGui)
    end
end

if Menu.Settings[CONFIG.SettingKey] == nil then
    Menu.Settings[CONFIG.SettingKey] = CONFIG.DefaultEnabled
end

local page
if CONFIG.TargetPage then
    for _, p in ipairs(Menu.Pages) do
        if p.Name == CONFIG.TargetPage then
            page = p
            break
        end
    end
else
    page = Menu.Pages[#Menu.Pages]
end

if not page then
    return
end

Menu:RegisterDefault(page, CONFIG.SettingKey, CONFIG.DefaultEnabled)

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

-- Crear tarjeta principal
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

-- Descripción simple (visible solo al pasar el cursor)
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

-- Mostrar/ocultar descripción al pasar el cursor
optionFrame.MouseEnter:Connect(function()
    descLabel.Visible = true
end)
optionFrame.MouseLeave:Connect(function()
    descLabel.Visible = false
end)

switchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local newState = not Menu.Settings[CONFIG.SettingKey]
        Menu.Settings[CONFIG.SettingKey] = newState
        enabled = newState
        updateToggleVisual(newState)
        if Menu.SaveSettings then Menu.SaveSettings() end
        applyState()
        if page.RefreshResetButton then page.RefreshResetButton() end
        if Menu.UpdateCanvas then Menu.UpdateCanvas() end
    end
end)

applyState()

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end