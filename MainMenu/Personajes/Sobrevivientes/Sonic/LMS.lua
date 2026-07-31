local BASE_AUDIO_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/LMS/"
local BASE_IMAGE_URL = BASE_AUDIO_URL .. "Images/"
local PLACEHOLDER_IMAGE = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"

local CONFIG = {
    Folder = "ScriptedMemories/cache",
    SettingKey = "sonic_lms_song",
    DefaultSong = "dontblink",
    SoundPath = { "ClientAssets", "Sounds", "mus", "Game", "Round", "SoloTheme", "SonicSolo" },

    -- ══════════════════════════════════════════════════════
    -- ZONA DE ORDEN — agrega, quita o reordena canciones aquí.
    -- ══════════════════════════════════════════════════════

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

    -- ══════════════════════════════════════════════════════
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

local SONGS_CACHED, IMAGE_CACHE = {}, {}

local function resolveImage(song)
    if IMAGE_CACHE[song.Id] ~= nil then return IMAGE_CACHE[song.Id] or nil end
    local asset = song.Image and getOrDownload(song.Image, CONFIG.Folder .. "/lms_img_" .. song.Image:match("([^/]+)$"))
    if not asset then
        if IMAGE_CACHE.__placeholder == nil then
            IMAGE_CACHE.__placeholder = getOrDownload(PLACEHOLDER_IMAGE, CONFIG.Folder .. "/lms_placeholder.png") or false
        end
        asset = IMAGE_CACHE.__placeholder or nil
    end
    IMAGE_CACHE[song.Id] = asset or false
    return asset
end

for _, song in ipairs(CONFIG.Songs) do
    if song.Url then
        SONGS_CACHED[song.Id] = getOrDownload(song.Url, CONFIG.Folder .. "/lms_" .. song.Id .. ".wav")
    end
end

-- ══════════════════════════════════════════════════════
-- AUDIO: aplica el SoundId elegido y lo "fuerza" de vuelta
-- si algo externo (el propio juego) intenta cambiarlo.
-- ══════════════════════════════════════════════════════

local sonicSound = _G.SonicLMSSound
local currentTarget = nil
local isApplying = false
local endedConn = nil

local function forceTarget(id)
    if not sonicSound or not id then return end
    isApplying = true
    sonicSound.SoundId = id
    sonicSound.TimePosition = 0
    sonicSound:Play()
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
    if not sonicSound then return end
    if endedConn then endedConn:Disconnect() end

    if songId == "random" then
        sonicSound.Looped = false
        local function playNext()
            local id = playNextRandom(currentTarget)
            if id then
                currentTarget = SONGS_CACHED[id]
                forceTarget(currentTarget)
            end
        end
        endedConn = sonicSound.Ended:Connect(playNext)
        playNext()
    elseif SONGS_CACHED[songId] then
        sonicSound.Looped = true
        currentTarget = SONGS_CACHED[songId]
        forceTarget(currentTarget)
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
                forceTarget(currentTarget)
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

        applySongSetting(Menu.Settings[CONFIG.SettingKey] or CONFIG.DefaultSong)
    end)
end

-- ══════════════════════════════════════════════════════
-- UI
-- ══════════════════════════════════════════════════════

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

local cardsContainer = Instance.new("Frame")
cardsContainer.Size = UDim2.new(1, 0, 0, 0)
cardsContainer.BackgroundTransparency = 1
cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
cardsContainer.Parent = selectView
Instance.new("UIListLayout", cardsContainer).Padding = UDim.new(0, 8)

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
    img.BackgroundTransparency = 1
    img.Image = (not isUtility) and (resolveImage(song) or "") or ""
    img.ScaleType = Enum.ScaleType.Crop
    img.ZIndex = 3
    img.Parent = card

    local offset = isUtility and 16 or 86
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -(offset + 20), 1, -20)
    textContainer.Position = UDim2.new(0, offset, 0, 10)
    textContainer.BackgroundTransparency = 1
    textContainer.ZIndex = 3
    textContainer.Parent = card
    Instance.new("UIListLayout", textContainer).Padding = UDim.new(0, 2)

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
        descLabel.ZIndex = 3
        descLabel.Parent = textContainer
    end

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
        header.TextXAlignment = Enum.TextXAlignment.Left
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
    Menu.Settings[CONFIG.SettingKey] = pendingSong
    savedSong = pendingSong
    if Menu.SaveSettings then Menu.SaveSettings() end
    applySongSetting(savedSong)
    refreshSongButton()
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