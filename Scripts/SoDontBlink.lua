local RS = game:GetService("ReplicatedStorage")
local GameProperties = workspace:WaitForChild("GameProperties")
local stateValue = GameProperties:WaitForChild("State")

local folderBlink = ".cache"

if makefolder and not isfolder(folderBlink) then
	makefolder(folderBlink)
end

local function getOrDownloadAsset(url, filename)
	if not isfile(filename) then
		writefile(filename, game:HttpGet(url))
	end
	return getcustomasset(filename)
end

local MUSIC_ID = getOrDownloadAsset(
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3",
	folderBlink .. "/SoDontBlink.mp3"
)

local masterMusicSound = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("musg")

local sonicSound
local soundConnection
local volumeConnection

local function applyOverride(sound)
	if not sound or not sound:IsA("Sound") then return end
	if sound.SoundId ~= MUSIC_ID then
		sound.SoundId = MUSIC_ID
	end
	sound.Looped = true
	sound.Volume = masterMusicSound.Volume
end

local function hookSound(sound)
	if not sound or not sound:IsA("Sound") then return end

	if soundConnection then
		soundConnection:Disconnect()
	end
	if volumeConnection then
		volumeConnection:Disconnect()
	end

	local updating = false

	local function apply()
		if updating then return end
		updating = true
		applyOverride(sound)
		updating = false
	end

	apply()

	soundConnection = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
		if not updating and sound.SoundId ~= MUSIC_ID then
			task.defer(apply)
		end
	end)

	volumeConnection = masterMusicSound:GetPropertyChangedSignal("Volume"):Connect(function()
		sound.Volume = masterMusicSound.Volume
	end)

	sonicSound = sound
end

task.spawn(function()
	local sonicSolo = RS
		:WaitForChild("ClientAssets")
		:WaitForChild("Sounds")
		:WaitForChild("mus")
		:WaitForChild("Game")
		:WaitForChild("Round")
		:WaitForChild("SoloTheme")
		:WaitForChild("SonicSolo")

	hookSound(sonicSolo)
end)

stateValue.Changed:Connect(function(value)
	if value == "RE" and sonicSound and sonicSound.IsPlaying then
		sonicSound.Looped = false
		sonicSound.TimePosition = 289
	end
end)