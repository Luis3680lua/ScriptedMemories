local BASE_AUDIO_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/LMS/"
local BASE_IMAGE_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/"
local PLACEHOLDER_IMAGE = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"

local function imageUrlFor(audioUrl)
    local name = audioUrl and audioUrl:match("([^/]+)%.wav$")
    return name and (BASE_IMAGE_URL .. name .. ".png") or nil
end

local CONFIG = {
    Folder = "ScriptedMemories/cache",
    SettingKey = "sonic_lms_song",
    FavoritesKey = "sonic_lms_favorites",
    SelectListKey = "sonic_lms_select_list",
    DefaultSong = "dontblink",
    SoundPath = { "ClientAssets", "Sounds", "mus", "Game", "Round", "SoloTheme", "SonicSolo" },
    VolumeMultiplier = 4,

    -- ══════════════════════════════════════════════════════
    -- ZONA DE ORDEN — agrega, quita o reordena canciones aquí.
    -- ══════════════════════════════════════════════════════

    Categories = {
        { Id = "actual", Name = "🔥 Actual" },
        { Id = "scrapped", Name = "🧪 Descartadas" },
        { Id = "unused", Name = "🧪 Sin Usar" },
        { Id = "mix", Name = "🎵 Mix" },
        { Id = "utility", Name = "🔀 Aleatorio" },
    },

    Songs = {
        { Id = "dontblink", Category = "actual", Name = "Don't Blink", EndTime = 245.92, Url = BASE_AUDIO_URL .. "DontBlink.wav" },

        { Id = "dontblinkunfinished", Category = "scrapped", Name = "Don't Blink (Unfinished)", EndTime = 246.23, Url = BASE_AUDIO_URL .. "DontBlinkUnfinished.wav" },
        { Id = "speedofsoundround2", Category = "scrapped", Name = "Speed of Sound Round 2", EndTime = 211.46, Url = BASE_AUDIO_URL .. "SpeedofSoundRound2.wav" },
        { Id = "breakfree", Category = "scrapped", Name = "Break Free", EndTime = 262.37, Url = BASE_AUDIO_URL .. "BreakFree.wav" },
        { Id = "hisworld", Category = "scrapped", Name = "His World", EndTime = 204.96, Url = BASE_AUDIO_URL .. "HisWorld.wav" },

        { Id = "dontblinkoldlyrics", Category = "unused", Name = "Don't Blink (Old Lyrics)", EndTime = 245.57, Url = BASE_AUDIO_URL .. "DontBlinkOldLyrics.wav" },
        { Id = "dontblinkbeta", Category = "unused", Name = "Don't Blink (Beta)", EndTime = 246.24, Url = BASE_AUDIO_URL .. "DontBlinkBeta.wav" },
        { Id = "speedofsoundround1", Category = "unused", Name = "Speed of Sound Round 1", EndTime = 189.43, Url = BASE_AUDIO_URL .. "SpeedofSoundRound1.wav" },

        { Id = "sodontblink", Category = "mix", Name = "So, Don't Blink", EndTime = 289.06, Url = BASE_AUDIO_URL .. "SoDontBlink.wav" },
        { Id = "dontblinkbonusmix", Category = "mix", Name = "Don't Blink (Bonus Mix)", EndTime = 253.62, Url = BASE_AUDIO_URL .. "DontBlinkBonusMix.wav" },

        { Id = "random", Category = "utility", Name = "Aleatorio", Description = "Reproduce todas las canciones en orden aleatorio (sin repetir la anterior)." },
        { Id = "random_favorites", Category = "utility", Name = "Aleatorio (Favoritos)", Description = "Solo tus canciones favoritas." },
        { Id = "random_select", Category = "utility", Name = "Aleatorio (Selección)", Description = "Solo las canciones que elijas." },
    }

    -- ══════════════════════════════════════════════════════
}

for _, song in ipairs(CONFIG.Songs) do
    if song.Url then
        song.Image = imageUrlFor(song.Url)
        song.Credits = song.Credits or (song.Id .. "PlaceholderCredito")
        song.Description = song.Description or (song.Id .. "PlaceholderDescripcion")
    end
end

local Menu = _G.Menu
if not Menu then return end
if not Menu.CharacterUI then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RNG = Random.new()

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
    if not canAsset or not url then return nil end
    local ok, result = pcall(function()
        if hasFS and isfile and isfile(filename) then
            return getcustomasset(filename)
        end
        if hasFS and writefile then
            local dok, data = pcall(game.HttpGet, game, url)
            if dok and data and #data > 0 then
                writefile(filename, data)
                return getcustomasset(filename)
            end
        end
        return nil
    end)
    return ok and result or nil
end

local function getCachedOnly(filename)
    if not (hasFS and canAsset and isfile and isfile(filename)) then return nil end
    local ok, asset = pcall(getcustomasset, filename)
    return ok and asset or nil
end

local SONGS_CACHED, cardImageRefs = {}, {}

for _, song in ipairs(CONFIG.Songs) do
    if song.Url then
        SONGS_CACHED[song.Id] = getCachedOnly(CONFIG.Folder .. "/lms_" .. song.Id .. ".wav")
    end
end

-- ══════════════════════════════════════════════════════
-- AUDIO
-- ══════════════════════════════════════════════════════

local sonicSound = _G.SonicLMSSound
local currentTarget, currentSongId = nil, nil
local currentMode = "fixed"
local isApplying = false
local roundActive = true
local endedConn = nil

local function setTarget(id)
    if not sonicSound or not id then return end
    isApplying = true
    sonicSound.SoundId = id
    isApplying = false
end

local function isFavorite(id)
    local favs = Menu.Settings[CONFIG.FavoritesKey] or {}
    for _, fid in ipairs(favs) do
        if fid == id then return true end
    end
    return false
end

local function isSelected(id)
    local sel = Menu.Settings[CONFIG.SelectListKey] or {}
    for _, sid in ipairs(sel) do
        if sid == id then return true end
    end
    return false
end

local function buildPool(filterFn, excludeId)
    local pool = {}
    for id in pairs(SONGS_CACHED) do
        if id ~= excludeId and (not filterFn or filterFn(id)) then
            table.insert(pool, id)
        end
    end
    if #pool == 0 and filterFn then
        for id in pairs(SONGS_CACHED) do
            if id ~= excludeId then table.insert(pool, id) end
        end
    end
    if #pool == 0 then
        for id in pairs(SONGS_CACHED) do table.insert(pool, id) end
    end
    return pool
end

local function pickRandom(pool)
    if #pool == 0 then return nil end
    return pool[RNG:NextInteger(1, #pool)]
end

local function disarmRandomRotation()
    if endedConn then
        endedConn:Disconnect()
        endedConn = nil
    end
end

local function armRandomRotation(filterFn)
    disarmRandomRotation()
    if not sonicSound then return end
    endedConn = sonicSound.Ended:Connect(function()
        if not roundActive then return end
        local id = pickRandom(buildPool(filterFn, currentSongId))
        if not id then return end
        currentSongId = id
        currentTarget = SONGS_CACHED[id]
        setTarget(currentTarget)
        sonicSound:Play()
    end)
end

local function filterForMode(mode)
    if mode == "random_favorites" then return isFavorite end
    if mode == "random_select" then return isSelected end
    return nil
end

local function applySongSetting(songId)
    if songId == "random" or songId == "random_favorites" or songId == "random_select" then
        currentMode = songId
        local filterFn = filterForMode(songId)
        local id = pickRandom(buildPool(filterFn, currentSongId))
        if id then
            currentSongId = id
            currentTarget = SONGS_CACHED[id]
            setTarget(currentTarget)
        end
        if sonicSound then sonicSound.Looped = false end
        if roundActive then
            armRandomRotation(filterFn)
        else
            disarmRandomRotation()
        end
    elseif SONGS_CACHED[songId] then
        currentMode = "fixed"
        currentSongId = songId
        currentTarget = SONGS_CACHED[songId]
        setTarget(currentTarget)
        disarmRandomRotation()
        if sonicSound then sonicSound.Looped = roundActive end
    end
end

local savedSong = Menu.Settings[CONFIG.SettingKey] or CONFIG.DefaultSong
if not Menu.Settings[CONFIG.FavoritesKey] then
    Menu.Settings[CONFIG.FavoritesKey] = {}
end
if not Menu.Settings[CONFIG.SelectListKey] then
    Menu.Settings[CONFIG.SelectListKey] = {}
end

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
                setTarget(currentTarget)
            end
        end))

        local function updateVolume(musg)
            sonicSound.Volume = math.clamp(musg.Volume * CONFIG.VolumeMultiplier, 0, 10)
        end

        local musg = ReplicatedStorage:WaitForChild("ClientAssets", 5)
        musg = musg and musg:WaitForChild("Sounds", 5)
        musg = musg and musg:WaitForChild("musg", 5)
        if musg then
            updateVolume(musg)
            table.insert(_G.SonicLMSConnections, musg:GetPropertyChangedSignal("Volume"):Connect(function()
                updateVolume(musg)
            end))
        else
            sonicSound.Volume = math.clamp(CONFIG.VolumeMultiplier, 0, 10)
        end

        local gameProps = workspace:FindFirstChild("GameProperties")
        local stateValue = gameProps and gameProps:FindFirstChild("State")

        if stateValue then
            roundActive = stateValue.Value ~= "RE"
            table.insert(_G.SonicLMSConnections, stateValue.Changed:Connect(function(value)
                if value == "RE" then
                    if roundActive then
                        roundActive = false
                        disarmRandomRotation()
                        if sonicSound then
                            sonicSound.Looped = false
                            local song = currentSongId and getSongById(currentSongId)
                            if song and song.EndTime then
                                sonicSound.TimePosition = song.EndTime
                            end
                        end
                    end
                else
                    if not roundActive then
                        roundActive = true
                        applySongSetting(savedSong)
                    end
                end
            end))
        end

        applySongSetting(savedSong)
    end)
end

task.spawn(function()
    pcall(function()
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
end)

-- ══════════════════════════════════════════════════════
-- UI
-- ══════════════════════════════════════════════════════

local container = Menu.CharacterUI.Container
local mainView, selectView
local hiddenSiblings = {}

local function hideOtherSections()
    hiddenSiblings = {}
    for _, child in ipairs(container:GetChildren()) do
        if child ~= mainView and child ~= selectView and child:IsA("GuiObject") then
            hiddenSiblings[child] = child.Visible
            child.Visible = false
        end
    end
end

local function restoreOtherSections()
    for child, wasVisible in pairs(hiddenSiblings) do
        if child and child.Parent then
            child.Visible = wasVisible
        end
    end
    hiddenSiblings = {}
end

mainView = Instance.new("Frame")
mainView.Name = "LMSMain"
mainView.Size = UDim2.new(1, 0, 0, 0)
mainView.BackgroundTransparency = 1
mainView.Visible = true
mainView.AutomaticSize = Enum.AutomaticSize.Y
mainView.Parent = container

local mainViewLayout = Instance.new("UIListLayout")
mainViewLayout.Padding = UDim.new(0, 6)
mainViewLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainViewLayout.Parent = mainView

local optionCard = Instance.new("Frame")
optionCard.Size = UDim2.new(1, 0, 0, 0)
optionCard.BackgroundColor3 = T.Secondary
optionCard.BackgroundTransparency = 0.15
optionCard.BorderSizePixel = 0
optionCard.AutomaticSize = Enum.AutomaticSize.Y
optionCard.Parent = mainView
roundFrame(optionCard, RADIUS)

local optionPadding = Instance.new("UIPadding")
optionPadding.PaddingLeft = UDim.new(0, 12)
optionPadding.PaddingRight = UDim.new(0, 12)
optionPadding.PaddingTop = UDim.new(0, 6)
optionPadding.PaddingBottom = UDim.new(0, 6)
optionPadding.Parent = optionCard

local optionRow = Instance.new("Frame")
optionRow.Size = UDim2.new(1, 0, 0, 0)
optionRow.AutomaticSize = Enum.AutomaticSize.Y
optionRow.BackgroundTransparency = 1
optionRow.Parent = optionCard

local optionRowLayout = Instance.new("UIListLayout")
optionRowLayout.FillDirection = Enum.FillDirection.Horizontal
optionRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionRowLayout.Padding = UDim.new(0, 10)
optionRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionRowLayout.Parent = optionRow

local optionLabelFrame = Instance.new("Frame")
optionLabelFrame.Size = UDim2.new(1, -160, 0, 0)
optionLabelFrame.AutomaticSize = Enum.AutomaticSize.Y
optionLabelFrame.BackgroundTransparency = 1
optionLabelFrame.Parent = optionRow

local optionLabel = Instance.new("TextLabel")
optionLabel.Size = UDim2.new(1, 0, 0, 0)
optionLabel.AutomaticSize = Enum.AutomaticSize.Y
optionLabel.BackgroundTransparency = 1
optionLabel.Font = T.FontBold
optionLabel.TextSize = 14
optionLabel.TextColor3 = T.Text
optionLabel.TextXAlignment = Enum.TextXAlignment.Left
optionLabel.TextWrapped = true
optionLabel.Text = "Música de LMS (Last Man Standing)"
optionLabel.Parent = optionLabelFrame

local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(0, 150, 0, 32)
songBtn.BackgroundColor3 = T.Tertiary
songBtn.TextColor3 = T.Text
songBtn.Font = T.FontBold
songBtn.TextSize = 13
songBtn.BorderSizePixel = 0
songBtn.AutoButtonColor = false
songBtn.TextTruncate = Enum.TextTruncate.AtEnd
roundFrame(songBtn, RADIUS)
songBtn.Parent = optionRow

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

selectView = Instance.new("Frame")
selectView.Name = "LMSSelect"
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

local function clearHighlights()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card:IsA("Frame") and card.Name == "SongCard" then
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

local function updateFavoriteHearts()
    for _, card in ipairs(cardsContainer:GetChildren()) do
        if card:IsA("Frame") and card.Name == "SongCard" then
            local heart = card:FindFirstChild("HeartBtn")
            if heart then
                heart.Text = isFavorite(card:GetAttribute("SongId")) and "❤️" or "🤍"
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

    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.BorderSizePixel = 0
    clickButton.ZIndex = 2
    clickButton.Parent = card

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 70, 0, 70)
    img.Position = UDim2.new(0, 8, 0, 10)
    img.BackgroundTransparency = 1
    if not isUtility then
        img.Image = getCachedOnly(CONFIG.Folder .. "/lms_img_" .. (song.Image and song.Image:match("([^/]+)$") or "")) or ""
        cardImageRefs[song.Id] = img
    end
    img.ScaleType = Enum.ScaleType.Crop
    img.ZIndex = 3
    img.Parent = card

    local textOffset = isUtility and 16 or 86
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(1, -(textOffset + 60), 1, -20)
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

    if not isUtility and song.Credits then
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
    end

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

    if not isUtility then
        local heartBtn = Instance.new("TextButton")
        heartBtn.Name = "HeartBtn"
        heartBtn.Size = UDim2.new(0, 30, 0, 30)
        heartBtn.Position = UDim2.new(1, -46, 0, 4)
        heartBtn.BackgroundTransparency = 1
        heartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        heartBtn.Font = T.Font
        heartBtn.TextSize = 18
        heartBtn.Text = isFavorite(song.Id) and "❤️" or "🤍"
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
    restoreOtherSections()
    pendingSong = savedSong
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

acceptBtn.MouseButton1Click:Connect(function()
    if not sonicSound then
        if Menu.Notify then Menu:Notify("Aún cargando el audio del juego, intenta de nuevo en un momento.", "error") end
        return
    end

    local song = getSongById(pendingSong)
    if song and song.Url and not SONGS_CACHED[pendingSong] then
        SONGS_CACHED[pendingSong] = getOrDownload(song.Url, CONFIG.Folder .. "/lms_" .. song.Id .. ".wav")
    end

    Menu.Settings[CONFIG.SettingKey] = pendingSong
    savedSong = pendingSong

    if savedSong == "random_select" then
        local newList = {}
        for id, checked in pairs(selectedSongs) do
            if checked then table.insert(newList, id) end
        end
        Menu.Settings[CONFIG.SelectListKey] = newList
    else
        Menu.Settings[CONFIG.SelectListKey] = {}
    end

    if Menu.SaveSettings then Menu.SaveSettings() end
    applySongSetting(savedSong)
    refreshSongButton()

    if song and song.Url and not SONGS_CACHED[pendingSong] and Menu.Notify then
        Menu:Notify("No se pudo cargar la canción. Verifica tu conexión.", "error")
    end

    selectView.Visible = false
    mainView.Visible = true
    restoreOtherSections()
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

songBtn.MouseButton1Click:Connect(function()
    mainView.Visible = false
    selectView.Visible = true
    hideOtherSections()
    pendingSong = savedSong
    selectedSongs = {}
    local currentSelectList = Menu.Settings[CONFIG.SelectListKey] or {}
    for _, id in ipairs(currentSelectList) do
        selectedSongs[id] = true
    end
    clearHighlights()
    updateSelectionHighlight()
    updateFavoriteHearts()
    updateSelectCheckboxes()
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end