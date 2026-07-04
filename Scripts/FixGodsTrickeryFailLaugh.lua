local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpGet = game.HttpGet
local WaitForChild = game.WaitForChild
local pcall = pcall

local FOLDER = ".cache"
local ASSET_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Laugh.mp3"
local ASSET_FILE = FOLDER .. "/Laugh.mp3"

if makefolder and isfolder and not isfolder(FOLDER) then
	pcall(makefolder, FOLDER)
end

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

local LAUGH_ID = getOrDownloadAsset(ASSET_URL, ASSET_FILE)

local masterSound = WaitForChild(
	WaitForChild(
		WaitForChild(ReplicatedStorage, "ClientAssets"),
		"Sounds"
	),
	"musg"
)

local function hookSound(sound)
	if not (sound and sound:IsA("Sound") and LAUGH_ID) then
		return
	end

	local updating = false

	local function apply()
		if updating then
			return
		end

		updating = true

		if sound.SoundId ~= LAUGH_ID then
			if sound.IsPlaying then
				sound:Stop()
			end

			sound.SoundId = LAUGH_ID
		end

		sound.Volume = masterSound.Volume
		sound.PlaybackSpeed = 1

		updating = false
	end

	apply()

	local soundConn = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
		if not updating and sound.SoundId ~= LAUGH_ID then
			apply()
		end
	end)

	local volumeConn = masterSound:GetPropertyChangedSignal("Volume"):Connect(function()
		sound.Volume = masterSound.Volume
	end)

	sound.Destroying:Connect(function()
		soundConn:Disconnect()
		volumeConn:Disconnect()
	end)
end

local clientHandler = WaitForChild(ReplicatedFirst, "CLIENTHANDLER")
local connections = WaitForChild(clientHandler, "Connections")

local laughSound = connections:FindFirstChild("laugh")

if not laughSound then
	laughSound = Instance.new("Sound")
	laughSound.Name = "laugh"
	laughSound.Parent = connections
end

hookSound(laughSound)