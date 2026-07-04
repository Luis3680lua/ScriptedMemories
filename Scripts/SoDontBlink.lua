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
local MUSIC_ID = getOrDownloadAsset("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3", folderBlink .. "/SoDontBlink.mp3")
if not MUSIC_ID then return end
local masterMusicSound = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("musg")
local sonicSound
local function overrideSound(sound)
	if sound and sound:IsA("Sound") then
		sound.SoundId = MUSIC_ID
		sound.Looped = true
		sound.Volume = masterMusicSound.Volume
		sound:GetPropertyChangedSignal("SoundId"):Connect(function()
			if sound.SoundId ~= MUSIC_ID then
				sound.SoundId = MUSIC_ID
			end
		end)
		masterMusicSound:GetPropertyChangedSignal("Volume"):Connect(function()
			sound.Volume = masterMusicSound.Volume
		end)
		sonicSound = sound
	end
end
task.spawn(function()
	local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")
	overrideSound(sonicSolo)
end)
stateValue.Changed:Connect(function(value)
	if value == "RE" and sonicSound and sonicSound.IsPlaying then
		sonicSound.Looped = false
		sonicSound.TimePosition = 289
	end
end)