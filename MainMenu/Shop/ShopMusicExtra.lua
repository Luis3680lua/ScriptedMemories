local CONFIG = {
    Name = "Canciones extra a la tienda",
    Description = "Añade canciones adicionales a la tienda",
    SettingKey = "shop_extra_music_enabled",
    Default = {},
    Folder = "ScriptedMemories/cache",
    ShopMusPath = { "ClientAssets", "Sounds", "mus", "Menu", "ShopMus" },
    MusicGroupPath = { "ClientAssets", "Sounds", "musg" },

    Songs = {
        { Key = "Lone", Name = "Lone", Credits = "ThatGuyRamon", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/Lone.mp3" },
        { Key = "OfAnotherDreamv2", Name = "Of Another Dream v2", Credits = "Juno!", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OfAnotherDreamv2.mp3" },
        { Key = "OnceUponRemix", Name = "Once Upon (Remix)", Credits = "Astranova", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OnceUponRemix.mp3" },
        { Key = "InvoluntariaScore", Name = "Involuntaria Score (Unfinished)", Credits = "Juno!", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/InvoluntariaScore.mp3" },
        { Key = "LostAndFound", Name = "Lost & Found (Unfinished)", Credits = "Juno!", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/LostAndFound.mp3" },
        { Key = "UncannyValley", Name = "Uncanny Valley (Unfinished)", Credits = "Juno!", Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/UncannyValley.mp3" },
    }
}

local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
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

local CACHED_SONGS = {}
for _, song in ipairs(CONFIG.Songs) do
    local filename = CONFIG.Folder .. "/" .. song.Key .. ".mp3"
    CACHED_SONGS[song.Key] = getOrDownloadAsset(song.Url, filename)
end

if not Menu.Settings[CONFIG.SettingKey] then
    Menu.Settings[CONFIG.SettingKey] = CONFIG.Default
end

local shopMusFolder = nil
local musicGroup = nil
local activeCustomSounds = {}

local function resolvePath(root, path)
    local current = root
    for _, name in ipairs(path) do
        current = current:WaitForChild(name, 10)
        if not current then return nil end
    end
    return current
end

local function getSongById(key)
    for _, song in ipairs(CONFIG.Songs) do
        if song.Key == key then return song end
    end
    return nil
end

local function applyMusicToggle(key, enabled)
    if not shopMusFolder then return end

    local song = getSongById(key)
    if not song then return end

    local soundName = "Custom_" .. key
    local soundTitle = song.Name .. " by " .. song.Credits

    if enabled then
        if not activeCustomSounds[key] and CACHED_SONGS[key] then
            local s = Instance.new("Sound")
            s.Name = soundName
            s.SoundId = CACHED_SONGS[key]
            s.Volume = 2
            if musicGroup then s.SoundGroup = musicGroup end
            s:SetAttribute("Title", soundTitle)
            s:SetAttribute("Loops", false)
            s.Parent = shopMusFolder
            activeCustomSounds[key] = s
        end
    else
        local s = activeCustomSounds[key]
        if s then
            s:Destroy()
            activeCustomSounds[key] = nil
        end
    end
end

local function initShopMusic()
    shopMusFolder = resolvePath(ReplicatedStorage, CONFIG.ShopMusPath)
    musicGroup = resolvePath(ReplicatedStorage, CONFIG.MusicGroupPath)
    if not shopMusFolder then return end

    for _, song in ipairs(CONFIG.Songs) do
        if Menu.Settings[CONFIG.SettingKey][song.Key] then
            applyMusicToggle(song.Key, true)
        end
    end
end
task.spawn(initShopMusic)

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local sectionFrame = card(page.Frame)

local sectionHeader = Instance.new("TextLabel")
sectionHeader.Size = UDim2.new(1, 0, 0, 0)
sectionHeader.AutomaticSize = Enum.AutomaticSize.Y
sectionHeader.BackgroundTransparency = 1
sectionHeader.Font = T.FontBold
sectionHeader.TextSize = 15
sectionHeader.TextColor3 = T.Accent
sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
sectionHeader.TextWrapped = true
sectionHeader.Text = CONFIG.Name
sectionHeader.Parent = sectionFrame

infoText(sectionFrame, CONFIG.Description, T.Font, 12, T.TextDim)

local div = Instance.new("Frame")
div.Size = UDim2.new(1, 0, 0, 1)
div.BorderSizePixel = 0
div.BackgroundColor3 = T.Border
div.Parent = sectionFrame

for _, song in ipairs(CONFIG.Songs) do
    local songKey = song.Key
    local enabled = Menu.Settings[CONFIG.SettingKey][songKey] or false

    local songCard = Instance.new("Frame")
    songCard.Size = UDim2.new(1, 0, 0, 0)
    songCard.BackgroundColor3 = T.Tertiary
    songCard.BackgroundTransparency = 0.3
    songCard.BorderSizePixel = 0
    songCard.AutomaticSize = Enum.AutomaticSize.Y
    roundFrame(songCard, RADIUS)
    songCard.Parent = sectionFrame

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingLeft = UDim.new(0, PADDING)
    cardPadding.PaddingRight = UDim.new(0, PADDING)
    cardPadding.PaddingTop = UDim.new(0, 6)
    cardPadding.PaddingBottom = UDim.new(0, 6)
    cardPadding.Parent = songCard

    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 0)
    rowFrame.AutomaticSize = Enum.AutomaticSize.Y
    rowFrame.BackgroundTransparency = 1
    rowFrame.Parent = songCard

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Padding = UDim.new(0, 10)
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Parent = rowFrame

    local songTextFrame = Instance.new("Frame")
    songTextFrame.Size = UDim2.new(1, -(SWITCH_WIDTH + 10), 0, 0)
    songTextFrame.AutomaticSize = Enum.AutomaticSize.Y
    songTextFrame.BackgroundTransparency = 1
    songTextFrame.Parent = rowFrame

    local songTextLayout = Instance.new("UIListLayout")
    songTextLayout.Padding = UDim.new(0, 2)
    songTextLayout.SortOrder = Enum.SortOrder.LayoutOrder
    songTextLayout.Parent = songTextFrame

    infoText(songTextFrame, song.Name, T.FontBold, 14, T.Text)
    infoText(songTextFrame, "Hecho por " .. song.Credits, T.Font, 12, T.TextDim)

    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
    switchFrame.BackgroundColor3 = enabled and T.Green or T.Red
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = rowFrame
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

    local function updateVisual(state)
        switchFrame.BackgroundColor3 = state and T.Green or T.Red
        local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
        TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
        }):Play()
    end

    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newState = not (Menu.Settings[CONFIG.SettingKey][songKey] or false)
            Menu.Settings[CONFIG.SettingKey][songKey] = newState
            updateVisual(newState)
            if Menu.SaveSettings then Menu.SaveSettings() end
            applyMusicToggle(songKey, newState)
        end
    end)
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end