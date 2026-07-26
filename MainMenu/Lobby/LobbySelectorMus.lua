local CONFIG = {
    PageName = "Lobby",
    Folder = "ScriptedMemories/cache",
    SettingKey = "lobby_song",
    FavoritesKey = "lobby_favorites",
    SelectListKey = "lobby_random_select_list",
    DefaultSong = "upon_the_hill_v1",
    SoundPath = { "Lobby", "LobbyMus" }
}

local Menu = _G.Menu
if not Menu then return end

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpGet = game.HttpGet
local random = math.random
local insert = table.insert

local T = Menu.THEME
local RADIUS = T.Radius or 6

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
    local lobby = Workspace:FindFirstChild(CONFIG.SoundPath[1])
    if not lobby then return nil end
    local sound = lobby:FindFirstChild(CONFIG.SoundPath[2])
    if sound and sound:IsA("Sound") then
        return sound
    end
    return nil
end

local writefile, isfile, isfolder, makefolder, getcustomasset
pcall(function()
    writefile = writefile
    isfile = isfile
    isfolder = isfolder
    makefolder = makefolder
    getcustomasset = getcustomasset
end)

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

local SONGS_URLS = {
    upon_the_hill_v1 = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
    upon_the_hill_v2 = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
    tea_time_waltz  = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3"
}

local SONGS_DATA = {
    tea_time_waltz = {
        name = "Tea Time Waltz",
        credits = "Juno!",
        description = "Reemplazado por ser placeholder en el prototipo.",
        image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/TeaTimeWaltz.png"
    },
    upon_the_hill_v1 = {
        name = "Upon The Hill",
        credits = "ThatGuyNamedPanther",
        description = "Canción actual del lobby.",
        image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv1.png"
    },
    upon_the_hill_v2 = {
        name = "Upon The Hill v2",
        credits = "ThatGuyNamedPanther & CosmicCoffee",
        description = "Descartada por la salida de ThatGuyNamedPanther.",
        image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv2.png"
    },
    random = {
        name = "Aleatorio",
        credits = "Scripted Memories",
        description = "Todas las canciones en orden aleatorio.",
        image = ""
    },
    random_favorites = {
        name = "Aleatorio (Favoritos)",
        credits = "Scripted Memories",
        description = "Solo tus canciones favoritas.",
        image = ""
    },
    random_select = {
        name = "Aleatorio (Selección)",
        credits = "Scripted Memories",
        description = "Solo las canciones que elijas.",
        image = ""
    }
}

local SONG_ORDER = {"tea_time_waltz", "upon_the_hill_v1", "upon_the_hill_v2", "random", "random_favorites", "random_select"}

local SONGS_CACHED = {}
for id, url in pairs(SONGS_URLS) do
    local name = url:match("([^/]+)%.mp3$")
    if name then
        local asset = getOrDownloadAsset(url, CONFIG.Folder .. "/" .. name .. ".mp3")
        if asset then
            SONGS_CACHED[id] = asset
        end
    end
end

local CACHED_IMAGES = {}
for id, data in pairs(SONGS_DATA) do
    local imgUrl = data.image
    if imgUrl and imgUrl ~= "" then
        local imgName = imgUrl:match("([^/]+)$")
        if imgName then
            CACHED_IMAGES[id] = getOrDownloadAsset(imgUrl, CONFIG.Folder .. "/img_" .. imgName)
        end
    end
end

local lobbyMusic = getLobbySound()

local masterGroup
pcall(function()
    local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
    local sounds = clientAssets:WaitForChild("Sounds", 10)
    masterGroup = sounds:WaitForChild("musg", 10)
end)

if lobbyMusic and masterGroup then
    lobbyMusic.SoundGroup = masterGroup
end

local endedConnection
local lastIndex = 0

local function getRandomIndexFromList(list)
    if #list == 0 then return nil end
    if #list == 1 then return list[1] end
    local idx
    repeat
        idx = list[random(#list)]
    until idx ~= lastIndex
    lastIndex = idx
    return idx
end

local function getRandomIndex()
    local cachedIds = {}
    for id, _ in pairs(SONGS_CACHED) do
        insert(cachedIds, id)
    end
    return getRandomIndexFromList(cachedIds)
end

local function getFavoriteIndex()
    local favs = Menu.Settings[CONFIG.FavoritesKey] or {}
    local available = {}
    for _, id in ipairs(favs) do
        if SONGS_CACHED[id] then
            insert(available, id)
        end
    end
    return getRandomIndexFromList(available)
end

local function getSelectIndex()
    local sel = Menu.Settings[CONFIG.SelectListKey] or {}
    local available = {}
    for _, id in ipairs(sel) do
        if SONGS_CACHED[id] then
            insert(available, id)
        end
    end
    return getRandomIndexFromList(available)
end

local function stopRandom()
    if endedConnection then
        endedConnection:Disconnect()
        endedConnection = nil
    end
end

local function startRandom(mode)
    stopRandom()
    if not lobbyMusic then return end
    lobbyMusic.Looped = false
    local function playNext()
        local id
        if mode == "random_favorites" then
            id = getFavoriteIndex()
        elseif mode == "random_select" then
            id = getSelectIndex()
        else
            id = getRandomIndex()
        end
        if id and SONGS_CACHED[id] then
            lobbyMusic.SoundId = SONGS_CACHED[id]
            lobbyMusic.TimePosition = 0
            lobbyMusic:Play()
        end
    end
    endedConnection = lobbyMusic.Ended:Connect(playNext)
    playNext()
end

local function applySongSetting(songId)
    if not lobbyMusic then return end
    stopRandom()
    if songId == "random" then
        startRandom("random")
    elseif songId == "random_favorites" then
        startRandom("random_favorites")
    elseif songId == "random_select" then
        startRandom("random_select")
    elseif SONGS_CACHED[songId] then
        lobbyMusic.SoundId = SONGS_CACHED[songId]
        lobbyMusic.Looped = true
        lobbyMusic.TimePosition = 0
        lobbyMusic:Play()
    else
        startRandom("random")
    end
end

local savedSong = Menu.Settings[CONFIG.SettingKey] or CONFIG.DefaultSong
if not Menu.Settings[CONFIG.FavoritesKey] then
    Menu.Settings[CONFIG.FavoritesKey] = {}
end
if not Menu.Settings[CONFIG.SelectListKey] then
    Menu.Settings[CONFIG.SelectListKey] = {}
end
applySongSetting(savedSong)

local page = getPage(CONFIG.PageName)
if not page then return end

local container = page.Frame

local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(1, 0, 0, 36)
songBtn.BackgroundColor3 = T.Tertiary
songBtn.TextColor3 = T.Text
songBtn.Font = T.FontBold
songBtn.TextSize = 14
songBtn.BorderSizePixel = 0
songBtn.Text = "🎵 " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
songBtn.AutoButtonColor = false
roundFrame(songBtn, 6)
songBtn.Parent = container

songBtn.MouseEnter:Connect(function()
    TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
end)
songBtn.MouseLeave:Connect(function()
    TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end)

local selectView = Instance.new("Frame")
selectView.Size = UDim2.new(1, 0, 0, 0)
selectView.BackgroundColor3 = T.Secondary
selectView.BackgroundTransparency = 0.15
selectView.BorderSizePixel = 0
selectView.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(selectView, RADIUS)
selectView.Visible = false
selectView.Parent = container

local selectPadding = Instance.new("UIPadding")
selectPadding.PaddingLeft = UDim.new(0, 12)
selectPadding.PaddingRight = UDim.new(0, 12)
selectPadding.PaddingTop = UDim.new(0, 8)
selectPadding.PaddingBottom = UDim.new(0, 8)
selectPadding.Parent = selectView

local selectLayout = Instance.new("UIListLayout")
selectLayout.Padding = UDim.new(0, 6)
selectLayout.SortOrder = Enum.SortOrder.LayoutOrder
selectLayout.Parent = selectView

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundTransparency = 1
topBar.Parent = selectView

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 100, 0, 32)
backBtn.Position = UDim2.new(0, 0, 0, 0)
backBtn.BackgroundColor3 = T.Tertiary
backBtn.TextColor3 = T.Text
backBtn.Font = T.FontBold
backBtn.TextSize = 14
backBtn.BorderSizePixel = 0
backBtn.Text = "← Volver"
backBtn.AutoButtonColor = false
roundFrame(backBtn, 6)
backBtn.Parent = topBar

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0, 120, 0, 32)
acceptBtn.Position = UDim2.new(1, -120, 0, 0)
acceptBtn.BackgroundColor3 = T.Green
acceptBtn.TextColor3 = T.Text
acceptBtn.Font = T.FontBold
acceptBtn.TextSize = 14
acceptBtn.BorderSizePixel = 0
acceptBtn.Text = "Aceptar"
acceptBtn.AutoButtonColor = false
roundFrame(acceptBtn, 6)
acceptBtn.Parent = topBar

local sectionHeader = Instance.new("TextLabel")
sectionHeader.Size = UDim2.new(1, 0, 0, 22)
sectionHeader.BackgroundTransparency = 1
sectionHeader.Font = T.FontBold
sectionHeader.TextSize = 15
sectionHeader.TextColor3 = T.Text
sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
sectionHeader.Text = "🎧 Seleccionar canción"
sectionHeader.Parent = selectView

local cardsContainer = Instance.new("Frame")
cardsContainer.Size = UDim2.new(1, 0, 0, 0)
cardsContainer.BackgroundTransparency = 1
cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
cardsContainer.Parent = selectView

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.Padding = UDim.new(0, 4)
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Parent = cardsContainer

local pendingSong = savedSong
local selectedCard = nil
local selectedSongs = {}

local function clearCardHighlights()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card:IsA("Frame") and card.Name == "SongCard" then
            card.BackgroundColor3 = T.Tertiary
            local stroke = card:FindFirstChild("SelectBorder")
            if stroke then stroke.Enabled = false end
        end
    end
end

local function highlightCard(card)
    clearCardHighlights()
    card.BackgroundColor3 = Color3.fromRGB(65, 70, 85)
    local stroke = card:FindFirstChild("SelectBorder")
    if stroke then stroke.Enabled = true end
    selectedCard = card
    pendingSong = card:GetAttribute("SongId")
end

local function updateFavoriteHearts()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card:IsA("Frame") and card.Name == "SongCard" then
            local heart = card:FindFirstChild("HeartBtn")
            if heart then
                local favs = Menu.Settings[CONFIG.FavoritesKey] or {}
                local isFav = false
                for _, id in ipairs(favs) do
                    if id == card:GetAttribute("SongId") then
                        isFav = true
                        break
                    end
                end
                heart.Text = isFav and "❤️" or "🤍"
            end
        end
    end
end

local function updateSelectCheckboxes()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card:IsA("Frame") and card.Name == "SongCard" then
            local checkbox = card:FindFirstChild("SelectCheck")
            if checkbox then
                local id = card:GetAttribute("SongId")
                if id == "random" or id == "random_favorites" or id == "random_select" then
                    checkbox.Visible = false
                else
                    checkbox.Visible = (pendingSong == "random_select")
                    if checkbox.Visible then
                        checkbox.Text = selectedSongs[id] and "✅" or "⬜"
                    end
                end
            end
        end
    end
end

local function toggleFavorite(songId)
    local favs = Menu.Settings[CONFIG.FavoritesKey] or {}
    local found = false
    for i, id in ipairs(favs) do
        if id == songId then
            table.remove(favs, i)
            found = true
            break
        end
    end
    if not found then
        table.insert(favs, songId)
    end
    Menu.Settings[CONFIG.FavoritesKey] = favs
    if Menu.SaveSettings then Menu.SaveSettings() end
    updateFavoriteHearts()
end

local function createSongCard(id, data)
    local card = Instance.new("Frame")
    card.Name = "SongCard"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = T.Tertiary
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card:SetAttribute("SongId", id)
    roundFrame(card, 6)

    local stroke = Instance.new("UIStroke")
    stroke.Name = "SelectBorder"
    stroke.Color = T.Accent
    stroke.Thickness = 2
    stroke.Enabled = false
    stroke.Parent = card

    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.BorderSizePixel = 0
    clickButton.ZIndex = 2
    clickButton.Parent = card

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 48, 0, 48)
    img.Position = UDim2.new(0, 6, 0, 6)
    img.BackgroundTransparency = 1
    img.Image = CACHED_IMAGES[id] or ""
    img.ScaleType = Enum.ScaleType.Crop
    img.ZIndex = 3
    img.Parent = card

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -120, 1, 0)
    textContainer.Position = UDim2.new(0, 60, 0, 6)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = card

    local textList = Instance.new("UIListLayout")
    textList.Padding = UDim.new(0, 2)
    textList.SortOrder = Enum.SortOrder.LayoutOrder
    textList.Parent = textContainer

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = T.Text
    nameLabel.Font = T.FontBold
    nameLabel.TextSize = 15
    nameLabel.Text = data.name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 3
    nameLabel.Parent = textContainer

    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Size = UDim2.new(1, 0, 0, 16)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.TextColor3 = T.TextDim
    creditsLabel.Font = T.Font
    creditsLabel.TextSize = 11
    creditsLabel.Text = "Por " .. data.credits
    creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditsLabel.ZIndex = 3
    creditsLabel.Parent = textContainer

    if id ~= "random" and id ~= "random_favorites" and id ~= "random_select" then
        local heartBtn = Instance.new("TextButton")
        heartBtn.Name = "HeartBtn"
        heartBtn.Size = UDim2.new(0, 30, 0, 30)
        heartBtn.Position = UDim2.new(1, -40, 0, 4)
        heartBtn.BackgroundTransparency = 1
        heartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        heartBtn.Font = T.Font
        heartBtn.TextSize = 18
        heartBtn.Text = "🤍"
        heartBtn.ZIndex = 4
        heartBtn.Parent = card

        heartBtn.MouseButton1Click:Connect(function()
            toggleFavorite(id)
        end)

        local selectCheck = Instance.new("TextButton")
        selectCheck.Name = "SelectCheck"
        selectCheck.Size = UDim2.new(0, 30, 0, 30)
        selectCheck.Position = UDim2.new(1, -72, 0, 4)
        selectCheck.BackgroundTransparency = 1
        selectCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectCheck.Font = T.Font
        selectCheck.TextSize = 18
        selectCheck.Text = "⬜"
        selectCheck.ZIndex = 4
        selectCheck.Visible = false
        selectCheck.Parent = card

        selectCheck.MouseButton1Click:Connect(function()
            if pendingSong == "random_select" then
                local songId = card:GetAttribute("SongId")
                selectedSongs[songId] = not selectedSongs[songId]
                selectCheck.Text = selectedSongs[songId] and "✅" or "⬜"
            end
        end)
    end

    clickButton.MouseButton1Click:Connect(function()
        highlightCard(card)
        updateSelectCheckboxes()
        if card:GetAttribute("SongId") ~= "random_select" then
            pendingSong = card:GetAttribute("SongId")
        else
            pendingSong = "random_select"
        end
    end)

    card.Parent = cardsContainer
    return card
end

for _, id in ipairs(SONG_ORDER) do
    createSongCard(id, SONGS_DATA[id])
end
updateFavoriteHearts()
selectedSongs = {}
local savedSelectList = Menu.Settings[CONFIG.SelectListKey] or {}
for _, id in ipairs(savedSelectList) do
    selectedSongs[id] = true
end
updateSelectCheckboxes()

local function updateSelectionHighlight()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card:IsA("Frame") and card.Name == "SongCard" and card:GetAttribute("SongId") == pendingSong then
            highlightCard(card)
            break
        end
    end
end

backBtn.MouseButton1Click:Connect(function()
    selectView.Visible = false
    songBtn.Visible = true
    pendingSong = savedSong
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

acceptBtn.MouseButton1Click:Connect(function()
    Menu.Settings[CONFIG.SettingKey] = pendingSong
    savedSong = pendingSong
    if savedSong == "random_select" then
        local newList = {}
        for id, checked in pairs(selectedSongs) do
            if checked then
                table.insert(newList, id)
            end
        end
        Menu.Settings[CONFIG.SelectListKey] = newList
    else
        Menu.Settings[CONFIG.SelectListKey] = {}
    end
    if Menu.SaveSettings then Menu.SaveSettings() end
    applySongSetting(savedSong)
    songBtn.Text = "🎵 " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
    selectView.Visible = false
    songBtn.Visible = true
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

songBtn.MouseButton1Click:Connect(function()
    songBtn.Visible = false
    selectView.Visible = true
    pendingSong = savedSong
    selectedSongs = {}
    local savedSelectList = Menu.Settings[CONFIG.SelectListKey] or {}
    for _, id in ipairs(savedSelectList) do
        selectedSongs[id] = true
    end
    clearCardHighlights()
    updateSelectionHighlight()
    updateFavoriteHearts()
    updateSelectCheckboxes()
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

page.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not page.Frame.Visible then
        selectView.Visible = false
        songBtn.Visible = true
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end