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
local SWITCH_HEIGHT = 18
local KNOB_SIZE = 14
local KNOB_OFFSET = 2

local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or RADIUS)
    corner.Parent = frame
    return corner
end

local function createLabel(parent, text, font, size, color, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, height or 18)
    label.BackgroundTransparency = 1
    label.Font = font or T.Font
    label.TextSize = size or 14
    label.TextColor3 = color or T.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
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

local savedMuted = Menu.Settings[CONFIG.SettingKey]
if savedMuted == nil then
    savedMuted = CONFIG.Default
    Menu.Settings[CONFIG.SettingKey] = savedMuted
end
applyMuteSetting(savedMuted)

local page = getPage(CONFIG.TargetPage)
if not page then return end

local container = page.Frame

local sectionFrame = Instance.new("Frame")
sectionFrame.Size = UDim2.new(1, 0, 0, 0)
sectionFrame.BackgroundColor3 = T.Secondary
sectionFrame.BackgroundTransparency = 0.15
sectionFrame.BorderSizePixel = 0
sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
sectionFrame.Parent = container
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
optionFrame.Size = UDim2.new(1, 0, 0, 0)
optionFrame.BackgroundColor3 = T.Secondary
optionFrame.BackgroundTransparency = 0.15
optionFrame.BorderSizePixel = 0
optionFrame.AutomaticSize = Enum.AutomaticSize.Y
optionFrame.Parent = sectionFrame
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

createLabel(textFrame, CONFIG.Name, T.FontBold, 14, T.Text, 18)
createLabel(textFrame, CONFIG.Description, T.Font, 11, T.TextDim, 14)

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
    TweenService:Create(
        switchKnob,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad),
        { Position = UDim2.new(0, targetX, 0, KNOB_OFFSET) }
    ):Play()
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