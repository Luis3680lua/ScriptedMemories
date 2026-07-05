local RS = game:GetService("ReplicatedStorage")
local GameProperties = workspace:WaitForChild("GameProperties")
local stateValue = GameProperties:WaitForChild("State")
local folderBlink = ".cache"

if makefolder and not isfolder(folderBlink) then
    makefolder(folderBlink)
end

local HttpGet = game.HttpGet
local getcustomasset = getcustomasset or function() end

local function downloadFile(url, filepath)
    if not isfile(filepath) then
        local ok, data = pcall(HttpGet, game, url)
        if ok and data then
            writefile(filepath, data)
            return true
        end
        return false
    end
    return true
end

local function getAssetPath(filepath)
    if getcustomasset then
        local ok, asset = pcall(getcustomasset, filepath)
        if ok and asset then
            return asset
        end
    end
    return nil
end

-- Tabla de canciones con secciones
local songs = {
    -- Break Free (nuevo)
    {
        name = "Break Free",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/BreakFree.mp3",
        file = "BreakFree.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder BreakFree",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/BreakFree.png",
        imageFile = "BreakFree.png",
        section = "Official"
    },
    -- Originales con imágenes actualizadas
    {
        name = "Don't Blink",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlink.mp3",
        file = "DontBlink.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder DontBlink",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png", -- mantiene imagen genérica
        imageFile = "Sonic_DontBlink.png",
        section = "Official"
    },
    {
        name = "Don't Blink (Old Lyrics)",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlinkOLD.mp3",
        file = "DontBlinkOLD.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder Old Lyrics",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/DontBlinkOld.png",
        imageFile = "DontBlinkOld.png",
        section = "Official"
    },
    {
        name = "So, Don't Blink",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3",
        file = "SoDontBlink.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder SoDontBlink",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SoDontBlink.png",
        imageFile = "SoDontBlink.png",
        section = "Official"
    },
    {
        name = "Speed of Sound Round 1",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound1.mp3",
        file = "SpeedOfSoundRound1.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder Round1",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound1.png",
        imageFile = "SpeedOfSoundRound1.png",
        section = "Official"
    },
    {
        name = "Speed of Sound Round 2",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2.mp3",
        file = "SpeedOfSoundRound2.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder Round2",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound2.png",
        imageFile = "SpeedOfSoundRound2.png",
        section = "Official"
    },
    {
        name = "Speed of Sound Round 2 (Bonus Mix)",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2BonusMix.mp3",
        file = "SpeedOfSoundRound2BonusMix.mp3",
        endTime = 289,
        credits = "Créditos: Placeholder BonusMix",
        imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound2BonusMix.png",
        imageFile = "SpeedOfSoundRound2BonusMix.png",
        section = "Official"
    }
}

for _, song in ipairs(songs) do
    downloadFile(song.url, folderBlink .. "/" .. song.file)
    song.assetId = getAssetPath(folderBlink .. "/" .. song.file)
    downloadFile(song.imageUrl, folderBlink .. "/" .. song.imageFile)
    song.imageAssetId = getAssetPath(folderBlink .. "/" .. song.imageFile)
end

local currentMusicId = nil
local sonicSound = nil
local activeSongIndex = 1
local selectedSongIndex = 1

local function applyMusic(newId)
    if not newId then return end
    currentMusicId = newId
    if sonicSound and sonicSound:IsA("Sound") then
        sonicSound.SoundId = newId
        sonicSound.Looped = true
        sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
    end
end

local function changeSong(index)
    local song = songs[index]
    if not song or not song.assetId then return end
    applyMusic(song.assetId)
    activeSongIndex = index
end

changeSong(1)

spawn(function()
    local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")
    if sonicSolo and sonicSolo:IsA("Sound") then
        sonicSound = sonicSolo
        applyMusic(currentMusicId)
        sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
            if sonicSound.SoundId ~= currentMusicId then
                sonicSound.SoundId = currentMusicId
            end
        end)
        RS.ClientAssets.Sounds.musg:GetPropertyChangedSignal("Volume"):Connect(function()
            if sonicSound then
                sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
            end
        end)
    end
end)

stateValue.Changed:Connect(function(value)
    if value == "RE" and sonicSound and sonicSound.IsPlaying then
        sonicSound.Looped = false
        sonicSound.TimePosition = songs[activeSongIndex].endTime
    end
end)

if _G.Library then
    local section = _G.Library.CreateSection("Sonic")
    if section then
        local openPickerButton = Instance.new("TextButton")
        openPickerButton.Text = "Last Man Standing"
        openPickerButton.Size = UDim2.new(1, -10, 0, 30)
        openPickerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        openPickerButton.TextColor3 = Color3.new(1, 1, 1)
        openPickerButton.Font = Enum.Font.GothamBold
        openPickerButton.TextSize = 14
        openPickerButton.BorderSizePixel = 0
        openPickerButton.Parent = section.Frame

        local pickerOpen = false
        local pickerGui
        local pickerFrame
        local itemFrames = {}   -- ahora solo guarda los frames de los ítems (sin cabeceras)

        local function closePicker()
            if pickerGui then
                pickerGui:Destroy()
                pickerGui = nil
            end
            pickerOpen = false
        end

        local function highlightItem(index)
            for i, frame in ipairs(itemFrames) do
                frame.BackgroundColor3 = (i == index) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(45, 45, 45)
            end
            selectedSongIndex = index
            -- ya no actualizamos un label de créditos externo
        end

        local function createPicker()
            if pickerOpen then return end
            pickerOpen = true

            pickerGui = Instance.new("ScreenGui")
            pickerGui.Name = "SonicPicker"
            pickerGui.ResetOnSpawn = false
            pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            pickerGui.DisplayOrder = 100
            pickerGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

            local background = Instance.new("Frame")
            background.Size = UDim2.new(1, 0, 1, 0)
            background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            background.BackgroundTransparency = 0.5
            background.Parent = pickerGui

            pickerFrame = Instance.new("Frame")
            pickerFrame.Size = UDim2.new(0, 350, 0, 480)
            pickerFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
            pickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            pickerFrame.BorderSizePixel = 0
            pickerFrame.Parent = pickerGui

            local title = Instance.new("TextLabel")
            title.Text = "Last Man Standing"
            title.Size = UDim2.new(1, 0, 0, 30)
            title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 18
            title.Parent = pickerFrame

            local scrollFrame = Instance.new("ScrollingFrame")
            scrollFrame.Size = UDim2.new(1, -10, 1, -70)  -- dejamos espacio para botones
            scrollFrame.Position = UDim2.new(0, 5, 0, 35)
            scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            scrollFrame.BorderSizePixel = 0
            scrollFrame.ScrollBarThickness = 4
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollFrame.Parent = pickerFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 5)
            listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = scrollFrame

            -- Eliminamos el creditsLabel inferior

            table.clear(itemFrames)

            local lastSection = nil
            local itemIndex = 0   -- índice real entre todos los ítems, ignorando cabeceras

            for i, song in ipairs(songs) do
                -- Insertar cabecera de sección si cambia
                if song.section ~= lastSection then
                    local sectionHeader = Instance.new("TextLabel")
                    sectionHeader.Text = song.section
                    sectionHeader.Size = UDim2.new(1, -10, 0, 25)
                    sectionHeader.BackgroundTransparency = 1
                    sectionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sectionHeader.Font = Enum.Font.GothamBold
                    sectionHeader.TextSize = 16
                    sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
                    sectionHeader.Parent = scrollFrame
                    lastSection = song.section
                end

                itemIndex = itemIndex + 1

                -- Frame del ítem (altura 80 para nombre + créditos)
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, -10, 0, 80)
                itemFrame.BackgroundColor3 = (itemIndex == selectedSongIndex) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(45, 45, 45)
                itemFrame.BorderSizePixel = 0
                itemFrame.Parent = scrollFrame

                -- Miniatura
                local image = Instance.new("ImageLabel")
                image.Size = UDim2.new(0, 50, 0, 50)
                image.Position = UDim2.new(0, 5, 0.5, -25)
                image.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                image.Image = song.imageAssetId or "rbxasset://textures/ui/GuiImagePlaceholder.png"
                image.ScaleType = Enum.ScaleType.Fit
                image.Parent = itemFrame

                -- Nombre (arriba)
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = song.name
                nameLabel.Size = UDim2.new(1, -120, 0, 20)
                nameLabel.Position = UDim2.new(0, 60, 0, 5)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 14
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Parent = itemFrame

                -- Créditos (debajo del nombre)
                local creditsLabel = Instance.new("TextLabel")
                creditsLabel.Text = song.credits
                creditsLabel.Size = UDim2.new(1, -120, 0, 20)
                creditsLabel.Position = UDim2.new(0, 60, 0, 30)
                creditsLabel.BackgroundTransparency = 1
                creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                creditsLabel.Font = Enum.Font.Gotham
                creditsLabel.TextSize = 12
                creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
                creditsLabel.Parent = itemFrame

                -- Botón Select (centrado verticalmente)
                local selectButton = Instance.new("TextButton")
                selectButton.Text = "Select"
                selectButton.Size = UDim2.new(0, 50, 0, 25)
                selectButton.Position = UDim2.new(1, -60, 0.5, -12)
                selectButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
                selectButton.TextColor3 = Color3.new(1, 1, 1)
                selectButton.Font = Enum.Font.GothamBold
                selectButton.TextSize = 14
                selectButton.BorderSizePixel = 0
                selectButton.Parent = itemFrame

                selectButton.MouseButton1Click:Connect(function()
                    highlightItem(itemIndex)
                end)

                -- También permitir seleccionar al hacer clic en cualquier parte del ítem
                itemFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        highlightItem(itemIndex)
                    end
                end)

                itemFrames[itemIndex] = itemFrame
            end

            -- Ajustar tamaño del canvas sumando cabeceras e ítems
            local numHeaders = #songs > 0 and (#{@songs.map(function(s) return s.section end)}) or 0  -- cuenta secciones únicas
            local totalItems = #itemFrames
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, numHeaders * 30 + totalItems * 85)  -- 25 altura header + 5 padding, 80 altura item + 5 padding

            -- Botones Aceptar / Cancelar
            local acceptButton = Instance.new("TextButton")
            acceptButton.Text = "Accept"
            acceptButton.Size = UDim2.new(0, 100, 0, 30)
            acceptButton.Position = UDim2.new(0.5, -120, 1, -40)
            acceptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            acceptButton.TextColor3 = Color3.new(1, 1, 1)
            acceptButton.Font = Enum.Font.GothamBold
            acceptButton.TextSize = 14
            acceptButton.BorderSizePixel = 0
            acceptButton.Parent = pickerFrame

            acceptButton.MouseButton1Click:Connect(function()
                changeSong(selectedSongIndex)
                closePicker()
            end)

            local cancelButton = Instance.new("TextButton")
            cancelButton.Text = "Cancel"
            cancelButton.Size = UDim2.new(0, 100, 0, 30)
            cancelButton.Position = UDim2.new(0.5, 20, 1, -40)
            cancelButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            cancelButton.TextColor3 = Color3.new(1, 1, 1)
            cancelButton.Font = Enum.Font.GothamBold
            cancelButton.TextSize = 14
            cancelButton.BorderSizePixel = 0
            cancelButton.Parent = pickerFrame

            cancelButton.MouseButton1Click:Connect(function()
                closePicker()
            end)

            background.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    closePicker()
                end
            end)

            highlightItem(selectedSongIndex)
        end

        openPickerButton.MouseButton1Click:Connect(function()
            createPicker()
        end)
    end
end