local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folderName = ".cache"
if makefolder and not isfolder(folderName) then makefolder(folderName) end

local function getOrDownloadAsset(url, filename)
	if isfile(filename) then return getcustomasset(filename) end
	local ok, data = pcall(game.HttpGet, game, url)
	if ok then writefile(filename, data) return getcustomasset(filename) end
end

local overridden = {}
local masterSound = nil

local function updateAllVolumes()
	if not masterSound then return end
	local vol = masterSound.Volume
	local toRemove = nil
	for sound, _ in pairs(overridden) do
		if sound and sound.Parent then sound.Volume = vol
		else
			if not toRemove then toRemove = {} end
			toRemove[sound] = true
		end
	end
	if toRemove then
		for sound in pairs(toRemove) do overridden[sound] = nil end
	end
end

local function forceCustomSound(sound, customId, loop)
	if not sound or not sound:IsA("Sound") or not customId then return end
	sound.SoundId = customId
	sound.Looped = loop
	if masterSound then sound.Volume = masterSound.Volume end
	overridden[sound] = true
	if loop then
		local conn = sound.Ended:Connect(function()
			if sound.SoundId == customId and sound.Parent then sound:Play() end
		end)
		local ancConn = sound.AncestryChanged:Connect(function()
			if not sound.Parent then conn:Disconnect() ancConn:Disconnect() end
		end)
	end
end

local function waitForSound(root, ...)
	local obj = root
	for _, name in ipairs({...}) do
		obj = obj:FindFirstChild(name) or obj:WaitForChild(name, 5)
		if not obj then return nil end
	end
	return obj:IsA("Sound") and obj or nil
end

local configs = {
	{ base = {"WinScreens"}, soundPath = {"2011x", "Theme"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/TryHarder.mp3",
	  file = "TryHarder.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x","Default"},
	  soundPath = {"TerrorRadius"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Default/NOW.mp3",
	  file = "NOW.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x","Default"},
	  soundPath = {"NormalChase"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Default/YOU.mp3",
	  file = "YOU.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x","Default"},
	  soundPath = {"LastLifeChase"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Default/DIE.mp3",
	  file = "DIE.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x","RETRO"},
	  soundPath = {"NormalChase"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Classic/TimeOver.mp3",
	  file = "TimeOver.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x","RETRO"},
	  soundPath = {"Rage"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Classic/HereICome.mp3",
	  file = "HereICome.mp3", loop = false },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x","RETRO"},
	  soundPath = {"LastLifeChase"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Classic/OverTime.mp3",
	  file = "OverTime.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","Kolossos","Forest"},
	  soundPath = {"NormalChase"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Kolossos/Forest/DangerousForestv2.mp3",
	  file = "DangerousForestv2.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","Kolossos","Forest"},
	  soundPath = {"LastLifeChase"},
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Kolossos/Forest/DeadlyFlowerv2.mp3",
	  file = "DeadlyFlowerv2.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x"},
	  mikuSpecial = true,
	  soundName = "TerrorRadius",
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Miku/NOW.mp3",
	  file = "Miku_NOW.mp3", loop = true },
	{ base = {"Sounds","mus","Game","Round","ChaseThemes","2011x"},
	  mikuSpecial = true,
	  soundName = "Rage",
	  url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Miku/ReadyOrNot.mp3",
	  file = "ReadyOrNot.mp3", loop = false },
}

local rootCache = {}
local function getBaseFolder(clientAssets, baseArray)
	local key = table.concat(baseArray, "\0")
	local folder = rootCache[key]
	if folder then return folder end
	folder = clientAssets
	for _, name in ipairs(baseArray) do
		folder = folder:FindFirstChild(name)
		if not folder then return nil end
	end
	rootCache[key] = folder
	return folder
end

local function applyConfig(cfg, clientAssets)
	local baseFolder
	if cfg.mikuSpecial then
		baseFolder = getBaseFolder(clientAssets, cfg.base)
		if not baseFolder then return end
		local mikuFolder = nil
		for _, child in ipairs(baseFolder:GetChildren()) do
			if child.Name:lower() == "miku" and child:IsA("Folder") then
				mikuFolder = child; break
			end
		end
		if not mikuFolder then return end
		local soundObj = mikuFolder:FindFirstChild(cfg.soundName)
		if soundObj and soundObj:IsA("Sound") then
			local customId = getOrDownloadAsset(cfg.url, folderName.."/"..cfg.file)
			if customId then forceCustomSound(soundObj, customId, cfg.loop) end
		end
	else
		baseFolder = getBaseFolder(clientAssets, cfg.base)
		if not baseFolder then return end
		local sound = waitForSound(baseFolder, unpack(cfg.soundPath))
		if sound then
			local customId = getOrDownloadAsset(cfg.url, folderName.."/"..cfg.file)
			if customId then forceCustomSound(sound, customId, cfg.loop) end
		end
	end
end

local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 5)
if not clientAssets then return end

local soundsFolder = clientAssets:FindFirstChild("Sounds") or clientAssets:WaitForChild("Sounds", 5)
if not soundsFolder then return end

masterSound = soundsFolder:FindFirstChild("musg") or soundsFolder:WaitForChild("musg", 5)
if masterSound then
	masterSound:GetPropertyChangedSignal("Volume"):Connect(updateAllVolumes)
end

task.spawn(function()
	local old = waitForSound(clientAssets:FindFirstChild("WinScreens") or clientAssets:WaitForChild("WinScreens", 5), "2011x", "Theme")
	if old and old.IsPlaying then old:Stop() end
end)

for _, cfg in ipairs(configs) do
	task.spawn(function()
		applyConfig(cfg, clientAssets)
	end)
end