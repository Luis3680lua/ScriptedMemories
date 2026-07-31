local BASE_AUDIO_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/LMS/"
local BASE_IMAGE_URL = BASE_AUDIO_URL .. "Images/"
local PLACEHOLDER_IMAGE = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"

local CONFIG = {
    Folder = "ScriptedMemories/cache",
    SettingKey = "sonic_lms_song",
    DefaultSong = "dontblink",
    SoundPath = { "ClientAssets", "Sounds", "mus", "Game", "Round", "SoloTheme", "SonicSolo" },
    ListHeight = 300,

    Categories = {
        { Id = "principales", Name = "🎵 Principales" },
        { Id = "beta", Name = "🧪 Beta / Descartadas" },
        { Id = "utility", Name = "🔀 Aleatorio" },
    },

    Songs = {
        { Id = "breakfree", Category = "principales", Name = "Break Free", Url = BASE_AUDIO_URL .. "BreakFree.wav", Image = BASE_IMAGE_URL .. "BreakFree.png" },
        { Id = "dontblink", Category = "principales", Name = "Don't Blink", Url = BASE_AUDIO_URL .. "DontBlink.wav", Image = BASE_IMAGE_URL .. "DontBlink.png" },
        { Id = "hisworld", Category = "principales", Name = "His World", Url = BASE_AUDIO_URL .. "HisWorld.wav", Image = BASE_IMAGE_URL .. "HisWorld.png" },
        { Id = "sodontblink", Category = "principales", Name = "So, Don't Blink", Url = BASE_AUDIO_URL .. "SoDontBlink.wav", Image = BASE_IMAGE_URL .. "SoDontBlink.png" },
        { Id = "speedofsoundround2", Category = "principales", Name = "Speed of Sound Round 2", Url = BASE_AUDIO_URL .. "SpeedofSoundRound2.wav", Image = BASE_IMAGE_URL .. "SpeedofSoundRound2.png" },

        { Id = "dontblinkbeta", Category = "beta", Name = "Don't Blink (Beta)", Url = BASE_AUDIO_URL .. "DontBlinkBeta.wav", Image = BASE_IMAGE_URL .. "DontBlinkBeta.png" },
        { Id = "dontblinkbonusmix", Category = "beta", Name = "Don't Blink (Bonus Mix)", Url = BASE_AUDIO_URL .. "DontBlinkBonusMix.wav", Image = BASE_IMAGE_URL .. "DontBlinkBonusMix.png" },
        { Id = "dontblinkoldlyrics", Category = "beta", Name = "Don't Blink (Old Lyrics)", Url = BASE_AUDIO_URL .. "DontBlinkOldLyrics.wav", Image = BASE_IMAGE_URL .. "DontBlinkOldLyrics.png" },
        { Id = "dontblinkunfinished", Category = "beta", Name = "Don't Blink (Unfinished)", Url = BASE_AUDIO_URL .. "DontBlinkUnfinished.wav", Image = BASE_IMAGE_URL .. "DontBlinkUnfinished.png" },
        { Id = "speedofsoundround1", Category = "beta", Name = "Speed of Sound Round 1", Url = BASE_AUDIO_URL .. "SpeedofSoundRound1.wav", Image = BASE_IMAGE_URL .. "SpeedofSoundRound1.png" },

        { Id = "random", Category = "utility", Name = "Aleatorio", Description = "Reproduce todas las canciones en orden aleatorio (sin repetir la anterior)." },
    }
}

local Menu = _G.Menu
if not Menu then return end
if not Menu.CharacterUI then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local random = math.random

local T = Menu.THEME
local RADIUS = T.Radius or 6

local function roundFrame(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or RADIUS)
    c.Parent = frame
    return c
end

local function getSongById(id)
    for _, song in ipairs(CONFIG.Songs) do
        if song.Id == id then return song end
    end
end

local hasFS = pcall(function() return isfolder end) and isfolder ~= nil
local canAsset = pcall(function() return getcustomasset end) and getcustomasset ~= nil

if hasFS and makefolder and not isfolder(CONFIG.Folder) then
    pcall(makefolder, CONFIG.Folder)
end

local function getOrDownload(url, filename)
    if not canAsset then return nil end
    if hasFS and isfile and isfile(filename) then
        local ok, asset = pcall(getcustomasset, filename)
        return ok and asset or nil
    end
    if hasFS and writefile then
        local ok, data = pcall(game.HttpGet, game, url)
        if ok and data and #data > 0 and pcall(writefile, filename, data) then
            local ok2, asset = pcall(getcustomasset, filename)
            return ok2 and asset or nil
        end
    end
    return nil
end

local function getCachedOnly(filename)
    if hasFS and canAsset and isfile and isfile(filename) then
        local ok, asset = pcall(getcustomasset, filename)
        if ok then return asset end
    end
    return nil
end

local SONGS_CACHED, cardImageRefs = {}, {}

for _, song in ipairs(CONFIG.Songs) do
    if song.Url then
        SONGS_CACHED[song.Id] = getCachedOnly(CONFIG.Folder .. "/lms_" .. song.Id .. ".wav")
    end
end

local sonicSound = _G.SonicLMSSound
local currentTarget = nil
local currentMode = "fixed"
local isApplying = false
local isRoundActive = true
local endedConn = nil

local function playIfActive(force)
    if not sonicSound or not currentTarget then return end
    isApplying = true
    sonicSound.SoundId = currentTarget
    if isRoundActive then
        if force then sonicSound.TimePosition = 0 end
        sonicSound:Play()
    end
    isApplying = false
end

local function playNextRandom(excludeId)
    local pool = {}
    for id in pairs(SONGS_CACHED) do
        if id ~= excludeId then table.insert(pool, id) end
    end
    if #pool == 0 then
        for id in pairs(SONGS_CACHED) do table.insert(pool, id) end
    end
    return pool[random(#pool)]
end

local function applySongSetting(songId)
    if endedConn then endedConn:Disconnect() end

    if songId == "random" then
        currentMode = "random"
        if sonicSound then sonicSound.Looped = false end
        local lastId = nil
        local function playNext()
            local id = playNextRandom(lastId)
            if id then
                lastId = id
                currentTarget = SONGS_CACHED[id]
                playIfActive(true)
            end
        end
        if sonicSound then
            endedConn = sonicSound.Ended:Connect(playNext)
        end
        playNext()
    elseif SONGS_CACHED[songId] then
        currentMode = "fixed"
        if sonicSound then sonicSound.Looped = isRoundActive end
        currentTarget = SONGS_CACHED[songId]
        playIfActive(true)
    end
end

local savedSong = Menu.Settings[CONFIG.SettingKey] or CONFIG.DefaultSong

if not _G.SonicLMSInitialized then
    _G.SonicLMSInitialized = true
    if _G.SonicLMSConnections then
        for _, c in ipairs(_G.SonicLMSConnections) do pcall(function() c:Disconnect() end) end
    end
    _G.SonicLMSConnections = {}

    task.spawn(function()
        local current = ReplicatedStorage
        for _, name in ipairs(CONFIG.SoundPath) do
            current = current:WaitForChild(name, 10)
            if not current then return end
        end
        if not current:IsA("Sound") then return end

        sonicSound = current
        _G.SonicLMSSound = sonicSound

        table.insert(_G.SonicLMSConnections, sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
            if isApplying then return end
            if currentTarget and sonicSound.SoundId ~= currentTarget then
                playIfActive(false)
            end
        end))

        local musg = ReplicatedStorage:WaitForChild("ClientAssets", 5)
        musg = musg and musg:WaitForChild("Sounds", 5)
        musg = musg and musg:WaitForChild("musg", 5)
        if musg then
            sonicSound.Volume = musg.Volume
            table.insert(_G.SonicLMSConnections, musg:GetPropertyChangedSignal("Volume"):Connect(function()
                sonicSound.Volume = musg.Volume
            end))
        end

        local gameProps = workspace:FindFirstChild("GameProperties")
        local stateValue = gameProps and gameProps:FindFirstChild("State")
        if stateValue then
            isRoundActive = stateValue.Value ~= "RE"
            table.insert(_G.SonicLMSConnections, stateValue.Changed:Connect(function(value)
                local wasActive = isRoundActive
                isRoundActive = value ~= "RE"
                if sonicSound then
                    sonicSound.Looped = isRoundActive and currentMode == "fixed"
                end
                if isRoundActive and not wasActive then
                    playIfActive(true)
                end
            end))
        end

        applySongSetting(savedSong)
    end)
else
    isApplying = false
end

task.spawn(function()
    local placeholderAsset = getOrDownload(PLACEHOLDER_IMAGE, CONFIG.Folder .. "/placeholder.png")
    if placeholderAsset then
        for _, imgRef in pairs(cardImageRefs) do
            if imgRef and imgRef.Parent and imgRef.Image == "" then
                imgRef.Image = placeholderAsset
            end
        end
    end

    local ordered = {}
    for _, song in ipairs(CONFIG.Songs) do
        if song.Id == savedSong then
            table.insert(ordered, 1, song)
        else
            table.insert(ordered, song)
        end
    end

    for _, song in ipairs(ordered) do
        if song.Url and not SONGS_CACHED[song.Id] then
            local audio = getOrDownload(song.Url, CONFIG.Folder .. "/lms_" .. song.Id .. ".wav")
            if audio then
                SONGS_CACHED[song.Id] = audio
                if song.Id == savedSong and sonicSound and not currentTarget then
                    applySongSetting(savedSong)
                end
            end
        end
        if song.Image then
            local imgName = song.Image:match("([^/]+)$")
            local ref = cardImageRefs[song.Id]
            if imgName and ref and ref.Parent then
                local asset = getOrDownload(song.Image, CONFIG.Folder .. "/lms_img_" .. imgName)
                if asset then ref.Image = asset end
            end
        end
    end
end)

local container = Menu.CharacterUI.Container
local mainView, selectView
local hiddenSiblings = {}

local function hideOtherCards()
    hiddenSiblings = {}
    for _, child in ipairs(container:GetChildren()) do
        if child ~= mainView and child ~= selectView and child:IsA("GuiObject") then
            hiddenSiblings[child] = child.Visible
            child.Visible = false
        end
    end
end

local function restoreOtherCards()
    for child, was in pairs(hiddenSiblings) do
        if child and child.Parent then child.Visible = was end
    end
    hiddenSiblings = {}
end

mainView = Instance.new("Frame")
mainView.Size = UDim2.new(1, 0, 0, 0)
mainView.BackgroundTransparency = 1
mainView.AutomaticSize = Enum.AutomaticSize.Y
mainView.Parent = container
Instance.new("UIListLayout", mainView).Padding = UDim.new(0, 6)

local optionCard = Instance.new("Frame")
optionCard.Size = UDim2.new(1, 0, 0, 0)
optionCard.BackgroundColor3 = T.Secondary
optionCard.BackgroundTransparency = 0.15
optionCard.BorderSizePixel = 0
optionCard.AutomaticSize = Enum.AutomaticSize.Y
optionCard.Parent = mainView
roundFrame(optionCard, RADIUS)

local optionPadding = Instance.new("UIPadding", optionCard)
optionPadding.PaddingLeft = UDim.new(0, 12)
optionPadding.PaddingRight = UDim.new(0, 12)
optionPadding.PaddingTop = UDim.new(0, 8)
optionPadding.PaddingBottom = UDim.new(0, 8)

local optionRow = Instance.new("Frame")
optionRow.Size = UDim2.new(1, 0, 0, 0)
optionRow.AutomaticSize = Enum.AutomaticSize.Y
optionRow.BackgroundTransparency = 1
optionRow.Parent = optionCard

local optionRowLayout = Instance.new("UIListLayout", optionRow)
optionRowLayout.FillDirection = Enum.FillDirection.Horizontal
optionRowLayout.Padding = UDim.new(0, 10)
optionRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local optionLabel = Instance.new("TextLabel")
optionLabel.Size = UDim2.new(1, -160, 0, 0)
optionLabel.AutomaticSize = Enum.AutomaticSize.Y
optionLabel.BackgroundTransparency = 1
optionLabel.Font = T.FontBold
optionLabel.TextSize = 14
optionLabel.TextColor3 = T.Text
optionLabel.TextXAlignment = Enum.TextXAlignment.Left
optionLabel.TextWrapped = true
optionLabel.Text = "Música de LMS (Last Man Standing)"
optionLabel.Parent = optionRow

local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(0, 150, 0, 32)
songBtn.BackgroundColor3 = T.Tertiary
songBtn.TextColor3 = T.Text
songBtn.Font = T.FontBold
songBtn.TextSize = 13
songBtn.BorderSizePixel = 0
songBtn.AutoButtonColor = false
songBtn.TextTruncate = Enum.TextTruncate.AtEnd
songBtn.Parent = optionRow
roundFrame(songBtn, RADIUS)

local function refreshSongButton()
    local song = getSongById(savedSong)
    songBtn.Text = "🎵 " .. (song and song.Name or "Aleatorio") .. " ▼"
end
refreshSongButton()

songBtn.MouseEnter:Connect(function() TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play() end)
songBtn.MouseLeave:Connect(function() TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play() end)

selectView = Instance.new("Frame")
selectView.Size = UDim2.new(1, 0, 0, 0)
selectView.BackgroundTransparency = 1
selectView.Visible = false
selectView.AutomaticSize = Enum.AutomaticSize.Y
selectView.Parent = container
Instance.new("UIListLayout", selectView).Padding = UDim.new(0, 8)

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
backBtn.Parent = topBar
roundFrame(backBtn, RADIUS)

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
acceptBtn.Parent = topBar
roundFrame(acceptBtn, RADIUS)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0, CONFIG.ListHeight)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = selectView

local cardsContainer = Instance.new("Frame")
cardsContainer.Size = UDim2.new(1, -6, 0, 0)
cardsContainer.BackgroundTransparency = 1
cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
cardsContainer.Parent = scrollFrame

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.Padding = UDim.new(0, 8)
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Parent = cardsContainer

cardsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, cardsLayout.AbsoluteContentSize.Y + 12)
end)

local pendingSong = savedSong

local function clearHighlights()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "SongCard" then
            card.BackgroundColor3 = T.Tertiary
            local stroke = card:FindFirstChild("SelectBorder")
            if stroke then stroke.Enabled = false end
        end
    end
end

local function highlightCard(card)
    clearHighlights()
    card.BackgroundColor3 = T.Hover
    local stroke = card:FindFirstChild("SelectBorder")
    if stroke then stroke.Enabled = true end
    pendingSong = card:GetAttribute("SongId")
end

local function createSongCard(song)
    local isUtility = song.Category == "utility"

    local card = Instance.new("Frame")
    card.Name = "SongCard"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = T.Tertiary
    card.BorderSizePixel = 0
    card.AutomaticSize = Enum.AutomaticSize.Y
    card:SetAttribute("SongId", song.Id)
    card.Parent = cardsContainer
    roundFrame(card, RADIUS)

    local stroke = Instance.new("UIStroke")
    stroke.Name = "SelectBorder"
    stroke.Color = T.Accent
    stroke.Thickness = 2
    stroke.Enabled = false
    stroke.Parent = card

    local cardPadding = Instance.new("UIPadding", card)
    cardPadding.PaddingLeft = UDim.new(0, 10)
    cardPadding.PaddingRight = UDim.new(0, 10)
    cardPadding.PaddingTop = UDim.new(0, 8)
    cardPadding.PaddingBottom = UDim.new(0, 8)

    local rowLayout = Instance.new("UIListLayout", card)
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 10)
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    if not isUtility then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, 54, 0, 54)
        img.BackgroundColor3 = T.Secondary
        img.BackgroundTransparency = 0.2
        img.Image = getCachedOnly(CONFIG.Folder .. "/lms_img_" .. (song.Image:match("([^/]+)$") or "")) or ""
        img.ScaleType = Enum.ScaleType.Crop
        img.Parent = card
        roundFrame(img, RADIUS)
        cardImageRefs[song.Id] = img
    end

    local textColumn = Instance.new("Frame")
    textColumn.Size = UDim2.new(1, isUtility and 0 or -64, 0, 0)
    textColumn.AutomaticSize = Enum.AutomaticSize.Y
    textColumn.BackgroundTransparency = 1
    textColumn.Parent = card
    Instance.new("UIListLayout", textColumn).Padding = UDim.new(0, 2)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = T.Text
    nameLabel.Font = T.FontBold
    nameLabel.TextSize = 15
    nameLabel.Text = song.Name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = textColumn

    if song.Description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.BackgroundTransparency = 1
        descLabel.TextColor3 = T.TextDim
        descLabel.Font = T.Font
        descLabel.TextSize = 11
        descLabel.Text = song.Description
        descLabel.TextWrapped = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.Parent = textColumn
    end

    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.ZIndex = 2
    clickButton.Parent = card
    clickButton.MouseButton1Click:Connect(function()
        highlightCard(card)
    end)
end

for _, cat in ipairs(CONFIG.Categories) do
    local songsInCat = {}
    for _, song in ipairs(CONFIG.Songs) do
        if song.Category == cat.Id then table.insert(songsInCat, song) end
    end
    if #songsInCat > 0 then
        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundTransparency = 1
        header.Font = T.FontBold
        header.TextSize = 14
        header.TextColor3 = T.Accent
        header.TextXAlignment = Enum.TextXAlignment.Center
        header.Text = cat.Name
        header.Parent = cardsContainer

        for _, song in ipairs(songsInCat) do createSongCard(song) end
    end
end

backBtn.MouseButton1Click:Connect(function()
    selectView.Visible = false
    mainView.Visible = true
    restoreOtherCards()
    pendingSong = savedSong
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

acceptBtn.MouseButton1Click:Connect(function()
    if not sonicSound then
        if Menu.Notify then Menu:Notify("Aún cargando el audio del juego, intenta de nuevo en un momento.", "error") end
        return
    end

    local song = getSongById(pendingSong)
    if pendingSong ~= "random" and song and song.Url and not SONGS_CACHED[pendingSong] then
        acceptBtn.Text = "Cargando..."
        acceptBtn.Active = false
        SONGS_CACHED[pendingSong] = getOrDownload(song.Url, CONFIG.Folder .. "/lms_" .. song.Id .. ".wav")
        acceptBtn.Text = "Aceptar"
        acceptBtn.Active = true
    end

    Menu.Settings[CONFIG.SettingKey] = pendingSong
    savedSong = pendingSong
    if Menu.SaveSettings then Menu.SaveSettings() end
    applySongSetting(savedSong)
    refreshSongButton()

    if pendingSong ~= "random" and not SONGS_CACHED[pendingSong] and Menu.Notify then
        Menu:Notify("No se pudo cargar la canción. Verifica tu conexión.", "error")
    end

    selectView.Visible = false
    mainView.Visible = true
    restoreOtherCards()
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

songBtn.MouseButton1Click:Connect(function()
    mainView.Visible = false
    selectView.Visible = true
    hideOtherCards()
    pendingSong = savedSong
    clearHighlights()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card.Name == "SongCard" and card:GetAttribute("SongId") == pendingSong then
            highlightCard(card)
            break
        end
    end
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end