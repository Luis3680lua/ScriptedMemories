-- So Don’t Blink - Menú integrado con selector de canción
local RS = game:GetService("ReplicatedStorage")
local GameProperties = workspace:WaitForChild("GameProperties")
local stateValue = GameProperties:WaitForChild("State")
local folderBlink = ".cache"

if makefolder and not isfolder(folderBlink) then
    makefolder(folderBlink)
end

local HttpGet = game.HttpGet

-- Función para descargar/obtener asset local
local function getOrDownloadAsset(url, filename)
    if not isfile(filename) then
        local ok, data = pcall(HttpGet, game, url)
        if ok and data then
            writefile(filename, data)
        end
    end
    if getcustomasset then
        return getcustomasset(filename)
    end
    return nil
end

-- Lista de canciones disponibles
local songs = {
    { name = "So Don't Blink",         url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3",                     file = "SoDontBlink.mp3" },
    { name = "Don't Blink (Old)",      url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlinkOLD.mp3",                file = "DontBlinkOLD.mp3" },
    { name = "Speed of Sound Round 1", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound1.mp3",          file = "SpeedOfSoundRound1.mp3" },
    { name = "Speed of Sound Round 2", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2.mp3",          file = "SpeedOfSoundRound2.mp3" },
    { name = "Speed of Sound Round 2 (Bonus Mix)", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2BonusMix.mp3", file = "SpeedOfSoundRound2BonusMix.mp3" }
}

-- Variable que guarda el asset ID de la canción actual
local currentMusicId = nil
local sonicSound = nil

-- Función que cambia la canción en el sonido de Sonic
local function applyMusic(newId)
    if not newId then return end
    currentMusicId = newId
    if sonicSound and sonicSound:IsA("Sound") then
        sonicSound.SoundId = newId
        sonicSound.Looped = true
        sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
    end
end

-- Función para cambiar la canción desde el selector
local function changeSong(index)
    local song = songs[index]
    if not song then return end
    local id = getOrDownloadAsset(song.url, folderBlink .. "/" .. song.file)
    if id then
        applyMusic(id)
    end
end

-- Inicializar con la primera canción
changeSong(1)

-- Esperar a que exista el sonido de Sonic
task.spawn(function()
    local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")
    if sonicSolo and sonicSolo:IsA("Sound") then
        sonicSound = sonicSolo
        -- Aplicar la canción actual (por si se descargó después)
        applyMusic(currentMusicId)

        -- Evitar que el juego la cambie
        sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
            if sonicSound.SoundId ~= currentMusicId then
                sonicSound.SoundId = currentMusicId
            end
        end)

        -- Sincronizar volumen con el maestro
        RS.ClientAssets.Sounds.musg:GetPropertyChangedSignal("Volume"):Connect(function()
            if sonicSound then
                sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
            end
        end)
    end
end)

-- Lógica de fin de ronda (detener loop al acabar)
stateValue.Changed:Connect(function(value)
    if value == "RE" and sonicSound and sonicSound.IsPlaying then
        sonicSound.Looped = false
        sonicSound.TimePosition = 289
    end
end)

-- ===== INTEGRACIÓN CON EL MENÚ =====
if _G.Library then
    local section = _G.Library.CreateSection("Sonic")   -- Crea la pestaña "Sonic"
    if section then
        local songNames = {}
        for _, s in ipairs(songs) do
            table.insert(songNames, s.name)
        end
        -- Selector cíclico de canciones
        section:AddDropdown("Canción", songNames, 1, function(selectedName, index)
            changeSong(index)
        end)
    end
end