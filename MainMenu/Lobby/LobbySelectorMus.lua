local CONFIG = {
    PageName = "Lobby",
    Folder = "ScriptedMemories/cache",
    SettingKey = "lobby_song",
    FavoritesKey = "lobby_favorites",
    SelectListKey = "lobby_random_select_list",
    DefaultSong = "upon_the_hill_v1",
    SoundPath = { "Lobby", "LobbyMus" },

    Categories = {
        { Id = "ost", Name = "🎧 OST" },
        { Id = "extra", Name = "🎼 Extras" },
        { Id = "utility", Name = "🔀 Modos aleatorios" },
    },

    Songs = {
        {
            Id = "upon_the_hill_v1",
            Category = "ost",
            Name = "Upon The Hill",
            Credits = "ThatGuyNamedPanther",
            Description = "Canción actual del lobby.",
            Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
            Image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv1.png",
        },
        {
            Id = "upon_the_hill_v2",
            Category = "ost",
            Name = "Upon The Hill v2",
            Credits = "ThatGuyNamedPanther & CosmicCoffee",
            Description = "Descartada por la salida de ThatGuyNamedPanther.",
            Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
            Image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv2.png",
        },
        {
            Id = "tea_time_waltz",
            Category = "extra",
            Name = "Tea Time Waltz (Lobby-Ver.)",
            Credits = "Juno!",
            Description = "Reemplazada por ser placeholder en el prototipo.",
            Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3",
            Image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/TeaTimeWaltz.png",
        },
        {
            Id = "random",
            Category = "utility",
            Name = "Aleatorio",
            Credits = "Scripted Memories",
            Description = "Reproduce todas las canciones en orden aleatorio.",
        },
        {
            Id = "random_favorites",
            Category = "utility",
            Name = "Aleatorio (Favoritos)",
            Credits = "Scripted Memories",
            Description = "Solo tus canciones favoritas.",
        },
        {
            Id = "random_select",
            Category = "utility",
            Name = "Aleatorio (Selección)",
            Credits = "Scripted Memories",
            Description = "Solo las canciones que elijas.",
        },
    }
}

local Menu = _G.Menu
if not Menu then return end

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local random = math.random

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

local function getSongById(id)
    for _, song in ipairs(CONFIG.Songs) do
        if song.Id == id then
            return song
        end
    end
    return nil
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
        local ok, data = pcall(game.HttpGet, game, url)
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

local SONGS_CACHED = {}
local CACHED_IMAGES = {}

for _, song in ipairs(CONFIG.Songs) do
    if song.Url then
        local name = song.Url:match("([^/]+)%.mp3$") or song.Id
        SONGS_CACHED[song.Id] = getOrDownloadAsset(song.Url, CONFIG.Folder .. "/" .. name .. ".mp3")
    end
    if song.Image then
        local imgName = song.Image:match("([^/]+)$")
        if imgName then
            CACHED_IMAGES[song.Id] = getOrDownloadAsset(song.Image, CONFIG.Folder .. "/img_" .. imgName)
        end
    end
end

local lobbyMusic = nil
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
        table.insert(cachedIds, id)
    end
    return getRandomIndexFromList(cachedIds)
end

local function getFavoriteIndex()
    local favs = Menu.Settings[CONFIG.FavoritesKey] or {}
    local available = {}
    for _, id in ipairs(favs) do
        if SONGS_CACHED[id] then
            table.insert(available, id)
        end
    end
    return getRandomIndexFromList(available)
end

local function getSelectIndex()
    local sel = Menu.Settings[CONFIG.SelectListKey] or {}
    local available = {}
    for _, id in ipairs(sel) do
        if SONGS_CACHED[id] then
            table.insert(available, id)
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

local function initAudio()
    local lobby = Workspace:WaitForChild(CONFIG.SoundPath[1], 10)
    local sound = lobby and lobby:WaitForChild(CONFIG.SoundPath[2], 10)
    if not (sound and sound:IsA("Sound")) then return end
    lobbyMusic = sound
    pcall(function()
        local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
        local sounds = clientAssets:WaitForChild("Sounds", 10)
        local group = sounds:WaitForChild("musg", 10)
        lobbyMusic.SoundGroup = group
    end)
    applySongSetting(savedSong)
end
task.spawn(initAudio)

local page = getPage(CONFIG.PageName)
if not page then return end

local container = page.Frame

local mainView = Instance.new("Frame")
mainView.Size = UDim2.new(1, 0, 0, 0)
mainView.BackgroundTransparency = 1
mainView.Visible = true
mainView.AutomaticSize = Enum.AutomaticSize.Y
mainView.Parent = container

local mainViewLayout = Instance.new("UIListLayout")
mainViewLayout.Padding = UDim.new(0, 6)
mainViewLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainViewLayout.Parent = mainView

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Font = T.FontBold
title.TextSize = T.TitleSize and (T.TitleSize - 2) or 20
title.TextColor3 = T.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎵 Música del lobby"
title.Parent = mainView

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0, 0)
desc.AutomaticSize = Enum.AutomaticSize.Y
desc.BackgroundTransparency = 1
desc.Font = T.Font
desc.TextSize = T.SmallSize or 13
desc.TextWrapped = true
desc.TextColor3 = T.TextDim
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.Text = "Selecciona una canción para el lobby o deja que Scripted Memories elija aleatoriamente."
desc.Parent = mainView

local div1 = Instance.new("Frame")
div1.Size = UDim2.new(1, 0, 0, 1)
div1.BorderSizePixel = 0
div1.BackgroundColor3 = T.Border
div1.Parent = mainView

local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(1, 0, 0, 52)
songBtn.BackgroundColor3 = T.Tertiary
songBtn.TextColor3 = T.Text
songBtn.Font = T.FontBold
songBtn.TextSize = 14
songBtn.BorderSizePixel = 0
songBtn.AutoButtonColor = false
roundFrame(songBtn, RADIUS)
songBtn.Parent = mainView

local function refreshSongButton()
    local song = getSongById(savedSong)
    songBtn.Text = "🎵 " .. (song and song.Name or "Aleatorio") .. " ▼"
end
refreshSongButton()

songBtn.MouseEnter:Connect(function()
    TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
end)
songBtn.MouseLeave:Connect(function()
    TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end)

local selectView = Instance.new("Frame")
selectView.Size = UDim2.new(1, 0, 0, 0)
selectView.BackgroundTransparency = 1
selectView.Visible = false
selectView.AutomaticSize = Enum.AutomaticSize.Y
selectView.Parent = container

local selectListLayout = Instance.new("UIListLayout")
selectListLayout.Padding = UDim.new(0, 8)
selectListLayout.SortOrder = Enum.SortOrder.LayoutOrder
selectListLayout.Parent = selectView

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundTransparency = 1
topBar.Parent = selectView

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 100, 0, 32)
backBtn.BackgroundColor3 = T.Tertiary
backBtn.TextColor3 = T.Text
backBtn.Font = T.FontBold
backBtn.TextSize = 14
backBtn.BorderSizePixel = 0
backBtn.AutoButtonColor = false
backBtn.Text = "← Volver"
roundFrame(backBtn, RADIUS)
backBtn.Parent = topBar

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0, 120, 0, 32)
acceptBtn.Position = UDim2.new(1, -120, 0, 0)
acceptBtn.BackgroundColor3 = T.Green
acceptBtn.TextColor3 = T.Text
acceptBtn.Font = T.FontBold
acceptBtn.TextSize = 14
acceptBtn.BorderSizePixel = 0
acceptBtn.AutoButtonColor = false
acceptBtn.Text = "Aceptar"
roundFrame(acceptBtn, RADIUS)
acceptBtn.Parent = topBar

local cardsContainer = Instance.new("Frame")
cardsContainer.Size = UDim2.new(1, 0, 0, 0)
cardsContainer.BackgroundTransparency = 1
cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
cardsContainer.Parent = selectView

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.Padding = UDim.new(0, 8)
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Parent = cardsContainer

local pendingSong = savedSong
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
    card.BackgroundColor3 = T.Hover
    local stroke = card:FindFirstChild("SelectBorder")
    if stroke then stroke.Enabled = true end
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
                checkbox.Visible = (pendingSong == "random_select")
                if checkbox.Visible then
                    checkbox.Text = selectedSongs[id] and "✅" or "⬜"
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

local function createSongCard(song)
    local card = Instance.new("Frame")
    card.Name = "SongCard"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = T.Tertiary
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card:SetAttribute("SongId", song.Id)
    roundFrame(card, RADIUS)

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

    local isUtility = song.Category == "utility"

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 70, 0, 70)
    img.Position = UDim2.new(0, 8, 0, 10)
    img.BackgroundTransparency = isUtility and 1 or 1
    img.Image = CACHED_IMAGES[song.Id] or ""
    img.ScaleType = Enum.ScaleType.Crop
    img.ZIndex = 3
    img.Parent = card

    local textOffset = 86
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -(textOffset + 50), 1, -20)
    textContainer.Position = UDim2.new(0, textOffset, 0, 10)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = card

    local textList = Instance.new("UIListLayout")
    textList.Padding = UDim.new(0, 2)
    textList.SortOrder = Enum.SortOrder.LayoutOrder
    textList.Parent = textContainer

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = T.Text
    nameLabel.Font = T.FontBold
    nameLabel.TextSize = 16
    nameLabel.Text = song.Name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 3
    nameLabel.Parent = textContainer

    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Size = UDim2.new(1, 0, 0, 18)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.TextColor3 = T.TextDim
    creditsLabel.Font = T.Font
    creditsLabel.TextSize = 12
    creditsLabel.Text = "Por " .. song.Credits
    creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditsLabel.ZIndex = 3
    creditsLabel.Parent = textContainer

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = T.TextDim
    descLabel.Font = T.Font
    descLabel.TextSize = 11
    descLabel.Text = song.Description
    descLabel.TextWrapped = true
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.AutomaticSize = Enum.AutomaticSize.Y
    descLabel.ZIndex = 3
    descLabel.Parent = textContainer

    if not isUtility then
        local heartBtn = Instance.new("TextButton")
        heartBtn.Name = "HeartBtn"
        heartBtn.Size = UDim2.new(0, 30, 0, 30)
        heartBtn.Position = UDim2.new(1, -46, 0, 4)
        heartBtn.BackgroundTransparency = 1
        heartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        heartBtn.Font = T.Font
        heartBtn.TextSize = 18
        heartBtn.Text = "🤍"
        heartBtn.ZIndex = 4
        heartBtn.Parent = card

        heartBtn.MouseButton1Click:Connect(function()
            toggleFavorite(song.Id)
        end)

        local selectCheck = Instance.new("TextButton")
        selectCheck.Name = "SelectCheck"
        selectCheck.Size = UDim2.new(0, 30, 0, 30)
        selectCheck.Position = UDim2.new(1, -82, 0, 4)
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
                selectedSongs[song.Id] = not selectedSongs[song.Id]
                selectCheck.Text = selectedSongs[song.Id] and "✅" or "⬜"
            end
        end)
    end

    clickButton.MouseButton1Click:Connect(function()
        highlightCard(card)
        updateSelectCheckboxes()
    end)

    card.Parent = cardsContainer
    return card
end

local function renderSongList()
    for _, cat in ipairs(CONFIG.Categories) do
        local songsInCat = {}
        for _, song in ipairs(CONFIG.Songs) do
            if song.Category == cat.Id then
                table.insert(songsInCat, song)
            end
        end
        if #songsInCat > 0 then
            local header = Instance.new("TextLabel")
            header.Size = UDim2.new(1, 0, 0, 22)
            header.BackgroundTransparency = 1
            header.Font = T.FontBold
            header.TextSize = 14
            header.TextColor3 = T.Accent
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Text = cat.Name
            header.Parent = cardsContainer

            for _, song in ipairs(songsInCat) do
                createSongCard(song)
            end
        end
    end
end
renderSongList()

updateFavoriteHearts()
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
    mainView.Visible = true
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
    refreshSongButton()
    selectView.Visible = false
    mainView.Visible = true
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

songBtn.MouseButton1Click:Connect(function()
    mainView.Visible = false
    selectView.Visible = true
    pendingSong = savedSong
    selectedSongs = {}
    local currentSelectList = Menu.Settings[CONFIG.SelectListKey] or {}
    for _, id in ipairs(currentSelectList) do
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
        mainView.Visible = true
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end