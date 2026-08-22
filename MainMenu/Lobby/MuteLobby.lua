local CONFIG = {
    Name = "Silenciar el lobby",
    Description = "Mutea la música del lobby",
    SettingKey = "lobby_muted",
    Default = false,
    TargetPage = "Lobby",
    SoundPath = {
        Folder = "Lobby",
        Sound = "LobbyMus"
    }
}

local Menu = _G.Menu
if not Menu then return end

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 20
local KNOB_SIZE = 14
local KNOB_OFFSET = 2

local currentSound = nil
local soundVolumeChangedConn = nil

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
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
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

local function getPage(name)
    for _, page in ipairs(Menu.Pages) do
        if page.Name == name then
            return page
        end
    end
    return nil
end

local function getLobbySound()
    local lobby = Workspace:FindFirstChild(CONFIG.SoundPath.Folder)
    if not lobby then return nil end
    local sound = lobby:FindFirstChild(CONFIG.SoundPath.Sound)
    if sound and sound:IsA("Sound") then
        return sound
    end
    return nil
end

local function setSoundVolume(sound, muted)
    if sound and sound:IsA("Sound") then
        sound.Volume = muted and 0 or 1
    end
end

local function updateCurrentSound()
    local newSound = getLobbySound()
    if newSound ~= currentSound then
        if soundVolumeChangedConn then
            soundVolumeChangedConn:Disconnect()
            soundVolumeChangedConn = nil
        end
        currentSound = newSound
        if currentSound then
            soundVolumeChangedConn = currentSound:GetPropertyChangedSignal("Volume"):Connect(function()
                if Menu.Settings[CONFIG.SettingKey] then
                    currentSound.Volume = 0
                end
            end)
        end
    end
    return currentSound
end

local function applyMuteSetting(muted)
    local sound = updateCurrentSound()
    if sound then
        setSoundVolume(sound, muted)
    end
end

-- Función global para que otros módulos puedan forzar el silencio
function Menu.ForceMuteLobby()
    if Menu.Settings[CONFIG.SettingKey] then
        applyMuteSetting(true)
    end
end

local savedMuted = Menu.Settings[CONFIG.SettingKey]
if savedMuted == nil then
    savedMuted = CONFIG.Default
    Menu.Settings[CONFIG.SettingKey] = savedMuted
end

-- Bucle de vigilancia: revisa cada 0.25s y fuerza el silencio
task.spawn(function()
    while true do
        local sound = updateCurrentSound()
        if sound and Menu.Settings[CONFIG.SettingKey] then
            setSoundVolume(sound, true)
        end
        task.wait(0.25)
    end
end)

-- Detectar el sonido justo cuando aparece (por ejemplo al volver del shop)
local function onDescendantAdded(descendant)
    if descendant:IsA("Sound") and descendant.Name == CONFIG.SoundPath.Sound then
        local lobby = descendant.Parent
        if lobby and lobby.Name == CONFIG.SoundPath.Folder then
            if Menu.Settings[CONFIG.SettingKey] then
                task.wait() -- esperar un frame para que se inicialice
                setSoundVolume(descendant, true)
                updateCurrentSound()
            end
        end
    end
end
Workspace.DescendantAdded:Connect(onDescendantAdded)

-- Limpiar conexión si el sonido actual se destruye
if currentSound then
    currentSound.Destroying:Connect(function()
        if soundVolumeChangedConn then
            soundVolumeChangedConn:Disconnect()
            soundVolumeChangedConn = nil
        end
        currentSound = nil
    end)
end

-- ===== INTERFAZ =====
local page = getPage(CONFIG.TargetPage)
if not page then return end

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

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
switchFrame.BackgroundColor3 = savedMuted and T.Green or T.Red
switchFrame.BorderSizePixel = 0
switchFrame.Parent = optionFrame
roundFrame(switchFrame, SWITCH_HEIGHT / 2)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
switchKnob.Position = savedMuted and
    UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
    UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame
roundFrame(switchKnob, KNOB_SIZE / 2)

local function updateSwitch(muted)
    switchFrame.BackgroundColor3 = muted and T.Green or T.Red
    local targetX = muted and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
    TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
    }):Play()
end

switchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local newState = not (Menu.Settings[CONFIG.SettingKey] or CONFIG.Default)
        Menu.Settings[CONFIG.SettingKey] = newState
        applyMuteSetting(newState)
        updateSwitch(newState)
        if Menu.SaveSettings then Menu.SaveSettings() end
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end