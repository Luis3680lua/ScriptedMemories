local CONFIG = {
    OptionName = "Silenciar el lobby",
    OptionDescription = "Mutea la música del lobby",
    SettingKey = "lobby_muted",
    DefaultValue = false,
    SoundPath = { "Lobby", "LobbyMus" }
}

local Menu = _G.Menu
if not Menu then return end

local T = Menu.THEME

local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or T.Radius or 6)
    corner.Parent = frame
    return corner
end

local workspace = game:GetService("Workspace")
local lobby = workspace:FindFirstChild(CONFIG.SoundPath[1])
local lobbyMus = lobby and lobby:FindFirstChild(CONFIG.SoundPath[2])
if lobbyMus and not lobbyMus:IsA("Sound") then
    lobbyMus = nil
end

local function applyMuteSetting(muted)
    if lobbyMus then
        lobbyMus.Volume = muted and 0 or 1
    end
end

local savedMuted = Menu.Settings[CONFIG.SettingKey]
if savedMuted == nil then
    savedMuted = CONFIG.DefaultValue
    Menu.Settings[CONFIG.SettingKey] = savedMuted
end
applyMuteSetting(savedMuted)

local page = Menu.ActivePage or Menu.Pages[#Menu.Pages]
if not page then return end

local container = page.Frame:FindFirstChildWhichIsA("Frame") or page.Frame

local function createToggle(title, description, settingKey, defaultValue)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = T.Secondary
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.Y
    roundFrame(frame, T.Radius or 6)
    frame.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = T.FontBold
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = T.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 18)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = T.Font
    descLabel.TextSize = 12
    descLabel.TextColor3 = T.TextDim
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Text = description
    descLabel.Parent = frame

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 36)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = frame

    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -56, 0, 7)
    switchBg.BackgroundColor3 = defaultValue and T.Green or T.Red
    switchBg.BorderSizePixel = 0
    roundFrame(switchBg, 11)
    switchBg.Parent = toggleFrame

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = defaultValue and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    roundFrame(knob, 9)
    knob.Parent = switchBg

    local function updateSwitch(muted)
        switchBg.BackgroundColor3 = muted and T.Green or T.Red
        local targetX = muted and 24 or 2
        knob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
    end

    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newState = not (Menu.Settings[settingKey] or defaultValue)
            Menu.Settings[settingKey] = newState
            applyMuteSetting(newState)
            updateSwitch(newState)
            if Menu.SaveSettings then Menu.SaveSettings() end
        end
    end)

    return frame
end

createToggle(
    CONFIG.OptionName,
    CONFIG.OptionDescription,
    CONFIG.SettingKey,
    savedMuted
)