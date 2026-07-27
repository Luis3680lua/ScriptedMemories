local CONFIG = {
    Name = "Íconos descartados (Sobrevivientes)",
    Description = "Muestra los íconos descartados de los sobrevivientes que nunca llegaron a utilizarse.",
    SettingKey = "shop_custom_icons_enabled",
    Default = false,
    Folder = "ScriptedMemories/cache",
    IconScale = { X = 2.2, Y = 1.9 },

    Icons = {
        { Key = "amy", Name = "Amy", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Amy.png" },
        { Key = "blaze", Name = "Blaze", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Blaze.png" },
        { Key = "cream", Name = "Cream", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Cream.png" },
        { Key = "eggman", Name = "Eggman", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Eggman.png" },
        { Key = "knuckles", Name = "Knuckles", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Knuckles.png" },
        { Key = "metalsonic", Name = "Metal Sonic", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/MetalSonic.png" },
        { Key = "silver", Name = "Silver", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Silver.png" },
        { Key = "sonic", Name = "Sonic", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png" },
        { Key = "tails", Name = "Tails", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Tails.png" },
    }
}

local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local HttpGet = game.HttpGet

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 20
local KNOB_SIZE = 14
local KNOB_OFFSET = 2

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

local hasFS = pcall(function() return isfolder end) and isfolder ~= nil
local canCustomAsset = pcall(function() return getcustomasset end) and getcustomasset ~= nil

local function ensureFolder()
    if hasFS and makefolder and not isfolder(CONFIG.Folder) then
        pcall(makefolder, CONFIG.Folder)
    end
end
ensureFolder()

local function getOrDownloadAsset(url, filename)
    if not canCustomAsset then return nil end
    if hasFS and isfile and isfile(filename) then
        local ok, asset = pcall(getcustomasset, filename)
        if ok then return asset end
        return nil
    end
    if hasFS and writefile then
        local ok, data = pcall(HttpGet, game, url)
        if ok and data and #data > 0 then
            local wok = pcall(writefile, filename, data)
            if wok then
                local cok, asset = pcall(getcustomasset, filename)
                if cok then return asset end
            end
        end
    end
    return nil
end

local iconsByKey = {}
local CACHED_ICONS = {}
for _, icon in ipairs(CONFIG.Icons) do
    iconsByKey[icon.Key] = icon
    local filename = CONFIG.Folder .. "/" .. icon.Key .. ".png"
    CACHED_ICONS[icon.Key] = getOrDownloadAsset(icon.Url, filename)
end

if Menu.Settings[CONFIG.SettingKey] == nil then
    Menu.Settings[CONFIG.SettingKey] = CONFIG.Default
end

local iconConnection = nil

local function replaceIconsInContainer(container)
    local name = container.Name:lower()
    local icon = iconsByKey[name] and CACHED_ICONS[name]
    if not icon then return end

    for _, child in ipairs(container:GetDescendants()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            local existing = child:FindFirstChild("CustomShopIcon")
            if existing then existing:Destroy() end

            local img = Instance.new("ImageLabel")
            img.Name = "CustomShopIcon"
            img.BackgroundTransparency = 1
            img.Image = icon
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.Position = UDim2.fromScale(0.5, 0.5)
            img.Size = UDim2.fromScale(CONFIG.IconScale.X, CONFIG.IconScale.Y)
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 999999
            img.Parent = child
        end
    end
end

local function clearCustomIcons()
    for _, obj in ipairs(PlayerGui:GetDescendants()) do
        local icon = obj:FindFirstChild("CustomShopIcon")
        if icon then
            icon:Destroy()
        end
    end
end

local function applyCustomIcons(enabled)
    if iconConnection then
        iconConnection:Disconnect()
        iconConnection = nil
    end

    if not enabled then
        clearCustomIcons()
        return
    end

    local charSelection = PlayerGui:FindFirstChild("CharSelection", true)
    if charSelection then
        for _, obj in ipairs(charSelection:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("ImageButton") then
                replaceIconsInContainer(obj)
            end
        end
    end

    iconConnection = PlayerGui.DescendantAdded:Connect(function(obj)
        if obj:IsA("Frame") or obj:IsA("ImageButton") then
            replaceIconsInContainer(obj)
        end
    end)
end

if Menu.Settings[CONFIG.SettingKey] then
    task.spawn(applyCustomIcons, true)
end

local page = Menu.Pages[#Menu.Pages]
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

local iconsEnabled = Menu.Settings[CONFIG.SettingKey]

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
switchFrame.BackgroundColor3 = iconsEnabled and T.Green or T.Red
switchFrame.BorderSizePixel = 0
switchFrame.Parent = optionFrame
roundFrame(switchFrame, SWITCH_HEIGHT / 2)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
switchKnob.Position = iconsEnabled and
    UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
    UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame
roundFrame(switchKnob, KNOB_SIZE / 2)

local function updateIconsVisual(state)
    switchFrame.BackgroundColor3 = state and T.Green or T.Red
    local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
    TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
    }):Play()
end

switchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local newState = not Menu.Settings[CONFIG.SettingKey]
        Menu.Settings[CONFIG.SettingKey] = newState
        updateIconsVisual(newState)
        if Menu.SaveSettings then Menu.SaveSettings() end
        applyCustomIcons(newState)
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end