local RS = game:GetService("ReplicatedStorage")
local GameProperties = workspace:WaitForChild("GameProperties")
local stateValue = GameProperties:WaitForChild("State")
local folderBlink = ".cache"

if makefolder and not isfolder(folderBlink) then
    makefolder(folderBlink)
end

local HttpGet = game.HttpGet

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

local songs = {
    { name = "So, Don't Blink", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3", file = "SoDontBlink.mp3" },
    { name = "Don't Blink (Old Lyrics)", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlinkOLD.mp3", file = "DontBlinkOLD.mp3" },
    { name = "Speed of Sound Round 1", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound1.mp3", file = "SpeedOfSoundRound1.mp3" },
    { name = "Speed of Sound Round 2", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2.mp3", file = "SpeedOfSoundRound2.mp3" },
    { name = "Speed of Sound Round 2 (Bonus Mix)", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2BonusMix.mp3", file = "SpeedOfSoundRound2BonusMix.mp3" }
}

local currentMusicId = nil
local sonicSound = nil

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
    if not song then return end
    local id = getOrDownloadAsset(song.url, folderBlink .. "/" .. song.file)
    if id then
        applyMusic(id)
    end
end

changeSong(1)

task.spawn(function()
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
        sonicSound.TimePosition = 289
    end
end)

if _G.Library then
    local section = _G.Library.CreateSection("Characters")
    if section then
        local sonicLabel = Instance.new("TextLabel")
        sonicLabel.Text = "Sonic"
        sonicLabel.Size = UDim2.new(1, -10, 0, 25)
        sonicLabel.BackgroundTransparency = 1
        sonicLabel.TextColor3 = Color3.new(1, 1, 1)
        sonicLabel.Font = Enum.Font.GothamBold
        sonicLabel.TextSize = 16
        sonicLabel.Parent = section.Frame

        local songNames = {}
        for _, s in ipairs(songs) do
            table.insert(songNames, s.name)
        end

        section:AddDropdown("Last Man Standing", songNames, 1, function(selectedName, index)
            changeSong(index)
        end)
    end
end