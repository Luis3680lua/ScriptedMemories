local CONFIG = {
    PageName = "Lobby",
    PageIcon = "🏠",
    Folder = "ScriptedMemories/cache",
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
    Order = {"tea_time_waltz", "upon_the_hill_v1", "upon_the_hill_v2", "random", "random_favorites", "random_select"},
    SettingKey = "lobby_song",
    FavoritesKey = "lobby_favorites",
    SelectListKey = "lobby_random_select_list",
    DefaultSong = "upon_the_hill_v1",
    SoundPath = { "Lobby", "LobbyMus" }
}

local Menu = _G.Menu
if not Menu then return end

local T = Menu.THEME
local HttpGet = game.HttpGet
local writefile, readfile, isfile, isfolder, makefolder, listfiles, getcustomasset
pcall(function() writefile = writefile end)
pcall(function() readfile = readfile end)
pcall(function() isfile = isfile end)
pcall(function() isfolder = isfolder end)
pcall(function() makefolder = makefolder end)
pcall(function() listfiles = listfiles end)
pcall(function() getcustomasset = getcustomasset end)

local function ensureFolder()
    if makefolder and isfolder and not isfolder(CONFIG.Folder) then
        pcall(makefolder, CONFIG.Folder)
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
    local filename = CONFIG.Folder .. "/" .. id .. ".mp3"
    return getOrDownloadAsset(data.url, filename)
end

local function getCachedImage(id)
    local data = CONFIG.Songs[id]
    if not data then return nil end
    local imageUrl = data.image
    local imgName = imageUrl:match("([^/]+)$")
    if imgName then
        return getOrDownloadAsset(imageUrl, CONFIG.Folder .. "/" .. imgName)
    end
    return nil
end

local targetPage
for _, p in ipairs(Menu.Pages) do
    if p.Name == CONFIG.PageName then
        targetPage = p
        break
    end
end
if not targetPage then return end

local container = targetPage.Frame:FindFirstChildWhichIsA("Frame") or targetPage.Frame

local workspace = game:GetService("Workspace")
local lobby = workspace:FindFirstChild(CONFIG.SoundPath[1])
local lobbyMus = lobby and lobby:FindFirstChild(CONFIG.SoundPath[2])
if lobbyMus and not lobbyMus:IsA("Sound") then
    lobbyMus = nil
end

local function applySongSetting(songId)
    if not lobbyMus then return end
    if songId == "random" then
        -- implement random logic
    elseif songId == "random_favorites" then
        -- implement favorites random
    elseif songId == "random_select" then
        -- implement select random
    else
        local asset = getCachedSong(songId)
        if asset then
            lobbyMus.SoundId = asset
            lobbyMus.Looped = true
            lobbyMus.TimePosition = 0
            lobbyMus:Play()
        end
    end
end

local currentSong = Menu.Settings[CONFIG.SettingKey] or CONFIG.DefaultSong
applySongSetting(currentSong)

local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or T.Radius or 6)
    corner.Parent = frame
    return corner
end

local sectionFrame = Instance.new("Frame")
sectionFrame.Size = UDim2.new(1, 0, 0, 0)
sectionFrame.BackgroundColor3 = T.Secondary
sectionFrame.BackgroundTransparency = 0.15
sectionFrame.BorderSizePixel = 0
sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(sectionFrame, T.Radius or 6)
sectionFrame.Parent = container

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = sectionFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = sectionFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 24)
header.BackgroundTransparency = 1
header.Font = T.FontBold
header.TextSize = 15
header.TextColor3 = T.Text
header.TextXAlignment = Enum.TextXAlignment.Left
header.Text = "🎶 Canción del lobby"
header.Parent = sectionFrame

local listContainer = Instance.new("Frame")
listContainer.Size = UDim2.new(1, 0, 0, 0)
listContainer.BackgroundTransparency = 1
listContainer.AutomaticSize = Enum.AutomaticSize.Y
listContainer.Parent = sectionFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = listContainer

local selectedRow = nil
local function createRow(id, data, isSpecial)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = T.Tertiary
    row.BackgroundTransparency = 0.5
    row.BorderSizePixel = 0
    row.AutomaticSize = Enum.AutomaticSize.Y
    roundFrame(row, 4)
    row.Parent = listContainer

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.BorderSizePixel = 0
    clickBtn.Parent = row

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 36, 0, 36)
    img.Position = UDim2.new(0, 4, 0, 0)
    img.BackgroundTransparency = 1
    img.Image = getCachedImage(id) or ""
    img.ScaleType = Enum.ScaleType.Crop
    img.Parent = row

    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, -120, 0, 36)
    info.Position = UDim2.new(0, 44, 0, 0)
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

    local favBtn = Instance.new("TextButton")
    favBtn.Size = UDim2.new(0, 24, 0, 24)
    favBtn.BackgroundTransparency = 1
    favBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    favBtn.Font = T.Font
    favBtn.TextSize = 16
    favBtn.Text = "🤍"
    favBtn.Parent = info
    if isSpecial then favBtn.Visible = false end

    local selectCheck = Instance.new("TextButton")
    selectCheck.Size = UDim2.new(0, 24, 0, 24)
    selectCheck.BackgroundTransparency = 1
    selectCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectCheck.Font = T.Font
    selectCheck.TextSize = 16
    selectCheck.Text = "⬜"
    selectCheck.Visible = false
    selectCheck.Parent = info

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, -8)
    indicator.Position = UDim2.new(1, -8, 0, 4)
    indicator.BackgroundColor3 = T.Accent
    indicator.BackgroundTransparency = 0.8
    indicator.BorderSizePixel = 0
    roundFrame(indicator, 2)
    indicator.Parent = row

    local function updateSelection(songId)
        if selectedRow then
            local prev = selectedRow:FindFirstChild("Indicator")
            if prev then prev.BackgroundTransparency = 0.8 end
        end
        selectedRow = row
        indicator.BackgroundTransparency = 0.2
    end

    clickBtn.MouseButton1Click:Connect(function()
        if id == "random_select" then
            -- expand selection view
        else
            Menu.Settings[CONFIG.SettingKey] = id
            applySongSetting(id)
            if Menu.SaveSettings then Menu.SaveSettings() end
            updateSelection(id)
        end
    end)

    favBtn.MouseButton1Click:Connect(function()
        local favs = Menu.Settings[CONFIG.FavoritesKey] or {}
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
        Menu.Settings[CONFIG.FavoritesKey] = favs
        if Menu.SaveSettings then Menu.SaveSettings() end
        favBtn.Text = found and "🤍" or "❤️"
    end)

    row:SetAttribute("SongId", id)
    return row
end

for _, id in ipairs(CONFIG.Order) do
    local data = CONFIG.Songs[id] or CONFIG.SpecialModes[id]
    if data then
        local isSpecial = CONFIG.SpecialModes[id] ~= nil
        createRow(id, data, isSpecial)
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end