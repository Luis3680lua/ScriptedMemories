local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folderName = ".cache"

if makefolder and not isfolder(folderName) then
	makefolder(folderName)
end

local function getOrDownloadAsset(url, filename)
	if not isfile(filename) then
		local success, data = pcall(game.HttpGet, game, url)
		if success then
			writefile(filename, data)
			print("Descargado: " .. filename)
		else
			warn("Fallo descarga: " .. url)
			return nil
		end
	end
	return getcustomasset(filename)
end

local overriddenSounds = {}
local masterMusicSound = nil

local function updateAllVolumes()
	if not masterMusicSound then return end
	local vol = masterMusicSound.Volume
	for sound, _ in pairs(overriddenSounds) do
		if sound and sound.Parent then
			sound.Volume = vol
		else
			overriddenSounds[sound] = nil
		end
	end
end

local function forceCustomSound(soundObj, customId, shouldLoop)
	if not soundObj or not soundObj:IsA("Sound") or not customId then return end

	soundObj.SoundId = customId
	soundObj.Looped = shouldLoop

	if masterMusicSound then
		soundObj.Volume = masterMusicSound.Volume
	end
	overriddenSounds[soundObj] = true
	print("Forzado: " .. soundObj.Name .. " -> " .. customId)

	if shouldLoop then
		soundObj.Ended:Connect(function()
			if soundObj.SoundId == customId and soundObj.Parent then
				soundObj:Play()
			end
		end)
	end
end

local function waitForSoundAtPath(root, ...)
	local current = root
	for _, name in ipairs({...}) do
		current = current and current:FindFirstChild(name)
		if not current then
			current = root and root:WaitForChild(name, 30)
			if not current then
				warn("No se encontró: " .. name)
				return nil
			end
		end
	end
	if current and current:IsA("Sound") then
		return current
	end
	warn("El objeto final no es Sound:", current and current.Name)
	return nil
end

local function overrideSoundTask(url, filename, root, shouldLoop, ...)
	local customId = getOrDownloadAsset(url, filename)
	if not customId then return end
	local sound = waitForSoundAtPath(root, ...)
	if sound then
		forceCustomSound(sound, customId, shouldLoop)
	else
		warn("No se encontró sonido en ruta:", ...)
	end
end

-- URLs
local WIN_MUSIC_URL       = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/TryHarder.mp3"
local TERROR_MUSIC_URL    = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Default/NOW.mp3"
local CHASE_MUSIC_URL     = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Default/YOU.mp3"
local LAST_LIFE_MUSIC_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Default/DIE.mp3"
local RETRO_CHASE_URL     = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Classic/TimeOver.mp3"
local HERE_I_COME_URL     = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Classic/HereICome.mp3"
local RETRO_LAST_LIFE_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Classic/OverTime.mp3"
local MIKU_TERROR_URL     = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Miku/NOW.mp3"
local MIKU_RAGE_URL       = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Miku/ReadyOrNot.mp3"
local FOREST_CHASE_URL    = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Kolossos/Forest/DangerousForestv2.mp3"
local FOREST_LAST_LIFE_URL= "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Kolossos/Forest/DeadlyFlowerv2.mp3"

local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 30)
if not clientAssets then return end

local winScreens = clientAssets:WaitForChild("WinScreens", 30)
local soundsFolder = clientAssets:WaitForChild("Sounds", 30)
local musFolder = soundsFolder:WaitForChild("mus", 30)
local gameFolder = musFolder:WaitForChild("Game", 30)
local roundFolder = gameFolder:WaitForChild("Round", 30)
local chaseThemes = roundFolder:WaitForChild("ChaseThemes", 30)
if not chaseThemes then return end

masterMusicSound = soundsFolder:FindFirstChild("musg")
if not masterMusicSound then
	masterMusicSound = soundsFolder:WaitForChild("musg", 30)
end

if masterMusicSound then
	masterMusicSound:GetPropertyChangedSignal("Volume"):Connect(updateAllVolumes)
end

task.spawn(function()
	local old = waitForSoundAtPath(winScreens, "2011x", "Theme")
	if old and old.IsPlaying then old:Stop() end
	overrideSoundTask(WIN_MUSIC_URL, folderName.."/TryHarder.mp3", winScreens, true, "2011x", "Theme")
end)

task.spawn(function()
	local defaultFolder = chaseThemes:FindFirstChild("2011x")
	if defaultFolder then
		defaultFolder = defaultFolder:FindFirstChild("Default")
	end
	if defaultFolder then
		overrideSoundTask(TERROR_MUSIC_URL,    folderName.."/NOW.mp3", defaultFolder, true, "TerrorRadius")
		overrideSoundTask(CHASE_MUSIC_URL,     folderName.."/YOU.mp3", defaultFolder, true, "NormalChase")
		overrideSoundTask(LAST_LIFE_MUSIC_URL, folderName.."/DIE.mp3", defaultFolder, true, "LastLifeChase")
	else
		warn("No se encontró 2011x/Default")
	end
end)

task.spawn(function()
	local retroFolder = chaseThemes:FindFirstChild("2011x")
	if retroFolder then
		retroFolder = retroFolder:FindFirstChild("RETRO")
	end
	if retroFolder then
		print("=== RETRO encontrado, hijos: ===")
		for _, child in retroFolder:GetChildren() do
			print(" -", child.Name, child.ClassName)
		end
		overrideSoundTask(RETRO_CHASE_URL,     folderName.."/TimeOver.mp3", retroFolder, true, "NormalChase")
		overrideSoundTask(HERE_I_COME_URL,     folderName.."/HereICome.mp3", retroFolder, false, "Rage")
		overrideSoundTask(RETRO_LAST_LIFE_URL, folderName.."/OverTime.mp3", retroFolder, true, "LastLifeChase")
	else
		warn("No se encontró 2011x/RETRO")
	end
end)

task.spawn(function()
	local folder2011x = chaseThemes:FindFirstChild("2011x")
	if not folder2011x then
		warn("No se encontró 2011x")
		return
	end

	-- Buscar carpeta "miku" (minúsculas) de forma insensible
	local mikuFolder = nil
	for _, child in folder2011x:GetChildren() do
		if string.lower(child.Name) == "miku" and child:IsA("Folder") then
			mikuFolder = child
			break
		end
	end

	if mikuFolder then
		print("=== miku (minúsculas) encontrado, hijos: ===")
		for _, child in mikuFolder:GetChildren() do
			print(" -", child.Name, child.ClassName)
		end

		local terror = mikuFolder:FindFirstChild("TerrorRadius")
		if terror and terror:IsA("Sound") then
			local customId = getOrDownloadAsset(MIKU_TERROR_URL, folderName.."/Miku_NOW.mp3")
			if customId then forceCustomSound(terror, customId, true) end
		end

		local rage = mikuFolder:FindFirstChild("Rage")
		if rage and rage:IsA("Sound") then
			local customId = getOrDownloadAsset(MIKU_RAGE_URL, folderName.."/ReadyOrNot.mp3")
			if customId then forceCustomSound(rage, customId, false) end
		end
	else
		warn("No se encontró carpeta 'miku' en 2011x")
	end
end)

task.spawn(function()
	local kolossosFolder = chaseThemes:FindFirstChild("Kolossos")
	if kolossosFolder then
		local forestFolder = kolossosFolder:FindFirstChild("Forest")
		if forestFolder then
			overrideSoundTask(FOREST_CHASE_URL,     folderName.."/DangerousForestv2.mp3", forestFolder, true, "NormalChase")
			overrideSoundTask(FOREST_LAST_LIFE_URL, folderName.."/DeadlyFlowerv2.mp3", forestFolder, true, "LastLifeChase")
		else
			warn("No se encontró Kolossos/Forest")
		end
	else
		warn("No se encontró Kolossos")
	end
end)