-- ==============================
-- CONFIGURATION
-- ==============================
local CONFIG = {
    General = {
        PageName = "Lobby",
        PageIcon = "🏠",
        Folder = "ScriptedMemories/cache",
        SettingKey = "lobby_song",
        FavoritesKey = "lobby_favorites",
        SelectListKey = "lobby_random_select_list",
        DefaultSong = "upon_the_hill_v1",
        SoundPath = { "Lobby", "LobbyMus" }
    },
    Songs = {
        tea_time_waltz = {
            url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3",
            name = "Tea Time Waltz",
            credits = "Juno!",
            description = "Reemplazado por ser placeholder en el prototipo.",
            image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/TeaTimeWaltz.png",
            duration = "3:41"
        },
        upon_the_hill_v1 = {
            url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
            name = "Upon The Hill",
            credits = "ThatGuyNamedPanther",
            description = "Canción actual del lobby tras la polémica con CosmicCoffee.",
            image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv1.png",
            duration = "2:58"
        },
        upon_the_hill_v2 = {
            url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
            name = "Upon The Hill v2",
            credits = "ThatGuyNamedPanther & CosmicCoffee",
            description = "Descartada por la salida de ThatGuyNamedPanther.",
            image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv2.png",
            duration = "3:12"
        }
    },
    SpecialModes = {
        random = { name = "Aleatorio", credits = "Scripted Memories", description = "Todas las canciones en orden aleatorio.", duration = "∞" },
        random_favorites = { name = "Aleatorio (Favoritos)", credits = "Scripted Memories", description = "Solo tus canciones favoritas.", duration = "∞" },
        random_select = { name = "Aleatorio (Selección)", credits = "Scripted Memories", description = "Solo las canciones que elijas.", duration = "∞" }
    },
    Order = { "tea_time_waltz", "upon_the_hill_v1", "upon_the_hill_v2", "random", "random_favorites", "random_select" }
}

-- ==============================
-- DEPENDENCIES
-- ==============================
local Menu = _G.Menu
if not Menu then return end

local Workspace = game:GetService("Workspace")
local HttpGet = game.HttpGet

-- ==============================
-- THEME & CONSTANTS
-- ==============================
local T = Menu.THEME
local RADIUS = T.Radius or 6
local UI = {
    SectionPadding = 12,
    RowHeight = 36,
    ImageSize = 36,
    ButtonSize = 24,
    IndicatorWidth = 4,
    HeaderHeight = 24
}

-- ==============================
-- UTILITY FUNCTIONS
-- ==============================
local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or RADIUS)
    corner.Parent = frame
    return corner
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
    local lobby = Workspace:FindFirstChild(CONFIG.General.SoundPath[1])
    if not lobby then return nil end
    local sound = lobby:FindFirstChild(CONFIG.General.SoundPath[2])
    if sound and sound:IsA("Sound") then
        return sound
    end
    return nil
end

-- ==============================
-- ASSET FUNCTIONS
-- ==============================
local writefile, isfile, isfolder, makefolder, getcustomasset
pcall(function()
    writefile = writefile
    isfile = isfile
    isfolder = isfolder
    makefolder = makefolder
    getcustomasset = getcustomasset
end)

local function ensureFolder()
    if makefolder and isfolder and not isfolder(CONFIG.General.Folder) then
        pcall(makefolder, CONFIG.General.Folder)
    end
end
ensureFolder()

local function getOrDownloadAsset(url, filename)
    if isfile and getcustomasset and isfile(filename) then
        return getcustomasset(filename)
    end
    if writefile and getcustomasset then
        local ok, data = pcall(HttpGet, game, url)
        if ok and data then
            writefile(filename, data)
            return getcustomasset(filename)
        end
    end
    return nil
end

local function getCachedSong(id)
    local data = CONFIG.Songs[id]
    if not data then return nil end
    local filename = CONFIG.General.Folder .. "/" .. id .. ".mp3"
    return getOrDownloadAsset(data.url, filename)
end

local function getCachedImage(id)
    local data = CONFIG.Songs[id]
    if not data then return nil end
    local imageUrl = data.image
    local imgName = imageUrl:match("([^/]+)$")
    if imgName then
        return getOrDownloadAsset(imageUrl, CONFIG.General.Folder .. "/" .. imgName)
    end
    return nil
end

-- ==============================
-- SOUND FUNCTIONS
-- ==============================
local lobbyMusic = getLobbySound()

local function applySongSetting(songId)
    if not lobbyMusic then return end
    if songId == "random" or songId == "random_favorites" or songId == "random_select" then
        return
    end
    local asset = getCachedSong(songId)
    if asset then
        lobbyMusic.SoundId = asset
        lobbyMusic.Looped = true
        lobbyMusic.TimePosition = 0
        lobbyMusic:Play()
    end
end

local currentSong = Menu.Settings[CONFIG.General.SettingKey] or CONFIG.General.DefaultSong
applySongSetting(currentSong)

-- ==============================
-- UI HELPERS
-- ==============================
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

local function createFrame(parent, size, color, transparency, autoSize)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 0, 0)
    frame.BackgroundColor3 = color or T.Tertiary
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    if autoSize ~= false then
        frame.AutomaticSize = Enum.AutomaticSize.Y
    end
    frame.Parent = parent
    return frame
end

local function createButton(parent, text, size, pos, color, textColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0, 24, 0, 24)
    btn.Position = pos or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    btn.Font = T.Font
    btn.TextSize = 16
    btn.Text = text or ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

local function createImage(parent, image, size, pos)
    local img = Instance.new("ImageLabel")
    img.Size = size or UDim2.new(0, UI.ImageSize, 0, UI.ImageSize)
    img.Position = pos or UDim2.new(0, 4, 0, 0)
    img.BackgroundTransparency = 1
    img.Image = image or ""
    img.ScaleType = Enum.ScaleType.Crop
    img.Parent = parent
    return img
end

-- ==============================
-- UI - SECTION
-- ==============================
local page = getPage(CONFIG.General.PageName)
if not page then return end

local container = page.Frame:FindFirstChildWhichIsA("Frame") or page.Frame

local sectionFrame = createFrame(container, UDim2.new(1, 0, 0, 0), T.Secondary, 0.15)
roundFrame(sectionFrame, RADIUS)

local sectionPadding = Instance.new("UIPadding")
sectionPadding.PaddingLeft = UDim.new(0, UI.SectionPadding)
sectionPadding.PaddingRight = UDim.new(0, UI.SectionPadding)
sectionPadding.PaddingTop = UDim.new(0, 8)
sectionPadding.PaddingBottom = UDim.new(0, 8)
sectionPadding.Parent = sectionFrame

local sectionLayout = Instance.new("UIListLayout")
sectionLayout.Padding = UDim.new(0, 6)
sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
sectionLayout.Parent = sectionFrame

local header = createLabel(sectionFrame, "🎶 Canción del lobby", T.FontBold, 15, T.Text, UI.HeaderHeight)

local listContainer = createFrame(sectionFrame, UDim2.new(1, 0, 0, 0), Color3.new(1, 1, 1), 1, true)
listContainer.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listContainer

-- ==============================
-- UI - SONG ROW
-- ==============================
local selectedRow = nil

local function createSongRow(id, data, isSpecial)
    local row = createFrame(listContainer, UDim2.new(1, 0, 0, UI.RowHeight), T.Tertiary, 0.5)
    roundFrame(row, 4)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.BorderSizePixel = 0
    clickBtn.Parent = row

    local image = createImage(row, getCachedImage(id) or "", UDim2.new(0, UI.ImageSize, 0, UI.ImageSize), UDim2.new(0, 4, 0, 0))

    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, -(UI.ImageSize + UI.ButtonSize * 2 + 20), 0, UI.RowHeight)
    info.Position = UDim2.new(0, UI.ImageSize + 8, 0, 0)
    info.BackgroundTransparency = 1
    info.Parent = row

    local infoLayout = Instance.new("UIListLayout")
    infoLayout.FillDirection = Enum.FillDirection.Horizontal
    infoLayout.Padding = UDim.new(0, 4)
    infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    infoLayout.Parent = info

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0, 0, 1, 0)
    name.BackgroundTransparency = 1
    name.Font = T.FontBold
    name.TextSize = 14
    name.TextColor3 = T.Text
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.AutomaticSize = Enum.AutomaticSize.X
    name.Text = data.name
    name.Parent = info

    local favBtn = createButton(info, "🤍", UDim2.new(0, UI.ButtonSize, 0, UI.ButtonSize))
    if isSpecial then
        favBtn.Visible = false
    end

    local selectCheck = createButton(info, "⬜", UDim2.new(0, UI.ButtonSize, 0, UI.ButtonSize))
    selectCheck.Visible = false

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, UI.IndicatorWidth, 1, -(UI.IndicatorWidth * 2))
    indicator.Position = UDim2.new(1, -(UI.IndicatorWidth + 4), 0, UI.IndicatorWidth)
    indicator.BackgroundColor3 = T.Accent
    indicator.BackgroundTransparency = 0.8
    indicator.BorderSizePixel = 0
    roundFrame(indicator, 2)
    indicator.Parent = row

    local function updateSelection()
        if selectedRow then
            local prev = selectedRow:FindFirstChild("Indicator")
            if prev then prev.BackgroundTransparency = 0.8 end
        end
        selectedRow = row
        indicator.BackgroundTransparency = 0.2
    end

    clickBtn.MouseButton1Click:Connect(function()
        if id == "random_select" then
            return
        end
        Menu.Settings[CONFIG.General.SettingKey] = id
        applySongSetting(id)
        if Menu.SaveSettings then Menu.SaveSettings() end
        updateSelection()
    end)

    favBtn.MouseButton1Click:Connect(function()
        local favs = Menu.Settings[CONFIG.General.FavoritesKey] or {}
        local found = false
        for i, v in ipairs(favs) do
            if v == id then
                table.remove(favs, i)
                found = true
                break
            end
        end
        if not found then
            table.insert(favs, id)
        end
        Menu.Settings[CONFIG.General.FavoritesKey] = favs
        if Menu.SaveSettings then Menu.SaveSettings() end
        favBtn.Text = found and "🤍" or "❤️"
    end)

    row:SetAttribute("SongId", id)
    return row
end

-- ==============================
-- INITIALIZATION
-- ==============================
for _, id in ipairs(CONFIG.Order) do
    local data = CONFIG.Songs[id] or CONFIG.SpecialModes[id]
    if data then
        local isSpecial = CONFIG.SpecialModes[id] ~= nil
        createSongRow(id, data, isSpecial)
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end