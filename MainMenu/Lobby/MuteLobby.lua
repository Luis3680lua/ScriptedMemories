--//======================================================================
--// Scripted Memories
--// Lobby Mute Option
--//======================================================================

--// Configuration
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

--// Dependencies
local Menu = _G.Menu
if not Menu then return end

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

--// Theme & Constants
local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 18
local KNOB_SIZE = 14
local KNOB_OFFSET = 2
local SWITCH_PADDING = (SWITCH_HEIGHT - KNOB_SIZE) / 2

--// Utility Functions
local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or RADIUS)
    corner.Parent = frame
    return corner
end

local function createFrame(parent, size, pos, color, transparency)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 0, 0)
    frame.Position = pos or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = color or T.Tertiary
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = parent
    return frame
end

local function createLabel(parent, text, font, size, color, height, align)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, height or 18)
    label.BackgroundTransparency = 1
    label.Font = font or T.Font
    label.TextSize = size or 14
    label.TextColor3 = color or T.Text
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = parent
    return label
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

local function applyMuteSetting(muted)
    local sound = getLobbySound()
    if sound then
        sound.Volume = muted and 0 or 1
    end
end

--// State
local savedMuted = Menu.Settings[CONFIG.SettingKey]
if savedMuted == nil then
    savedMuted = CONFIG.Default
    Menu.Settings[CONFIG.SettingKey] = savedMuted
end
applyMuteSetting(savedMuted)

--// Get Target Page
local page = getPage(CONFIG.TargetPage)
if not page then return end

local container = page.Frame:FindFirstChildWhichIsA("Frame") or page.Frame

--// UI Creation
local function createOption()
    -- Root
    local optionFrame = createFrame(container, UDim2.new(1, 0, 0, 0), nil, T.Secondary, 0.15)
    roundFrame(optionFrame, RADIUS)

    local optionPadding = Instance.new("UIPadding")
    optionPadding.PaddingLeft = UDim.new(0, PADDING)
    optionPadding.PaddingRight = UDim.new(0, PADDING)
    optionPadding.PaddingTop = UDim.new(0, 6)
    optionPadding.PaddingBottom = UDim.new(0, 6)
    optionPadding.Parent = optionFrame

    local optionLayout = Instance.new("UIListLayout")
    optionLayout.FillDirection = Enum.FillDirection.Horizontal
    optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionLayout.Padding = UDim.new(0, 8)
    optionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    optionLayout.Parent = optionFrame

    -- Text Container
    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -SWITCH_WIDTH - 20, 0, 0)
    textFrame.BackgroundTransparency = 1
    textFrame.AutomaticSize = Enum.AutomaticSize.Y
    textFrame.Parent = optionFrame

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Padding = UDim.new(0, 0)
    textLayout.Parent = textFrame

    -- Title
    createLabel(textFrame, CONFIG.Name, T.FontBold, 14, T.Text, 18)

    -- Description
    createLabel(textFrame, CONFIG.Description, T.Font, 11, T.TextDim, 14)

    -- Switch
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

    -- Update function
    local function updateSwitch(muted)
        switchFrame.BackgroundColor3 = muted and T.Green or T.Red
        local targetX = muted and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
        TweenService:Create(
            switchKnob,
            TweenInfo.new(0.18, Enum.EasingStyle.Quad),
            { Position = UDim2.new(0, targetX, 0, KNOB_OFFSET) }
        ):Play()
    end

    -- Event
    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newState = not (Menu.Settings[CONFIG.SettingKey] or CONFIG.Default)
            Menu.Settings[CONFIG.SettingKey] = newState
            applyMuteSetting(newState)
            updateSwitch(newState)
            if Menu.SaveSettings then Menu.SaveSettings() end
        end
    end)

    return optionFrame
end

--// Initialize
createOption()

--// Optional: update canvas if needed
task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end