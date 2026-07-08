local pcall = pcall
local loadstring = loadstring
local wait = task.wait
local spawn = task.spawn
local floor = math.floor

local HttpGet = game.HttpGet

local function limpiarCache()
	if not (isfolder and delfolder) then
		return
	end

	for _, folder in ipairs({".cache", "workspace"}) do
		local ok, exists = pcall(isfolder, folder)
		if ok and exists then
			pcall(delfolder, folder)
		end
	end
end

local function loadScript(url)
	local ok, source = pcall(HttpGet, game, url)
	if not ok or source == "" then
		return false
	end

	local okFunc, func = pcall(loadstring, source)
	if not okFunc or not func then
		return false
	end

	spawn(function()
		pcall(func)
	end)

	return true
end

limpiarCache()

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua")

repeat
	wait()
until _G.LoadingScreen

local LoadingScreen = _G.LoadingScreen


loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Info.lua")

local scripts = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/MetalLastLife.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Rings.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixLastLifeEND2011x.lua",
}

local total = #scripts

for i = 1, total do
	loadScript(scripts[i])

	if LoadingScreen then
		LoadingScreen.SetProgress(floor(i * 100 / total))
	end
end

if LoadingScreen then
	LoadingScreen.Finish("Scripted Memories", "✔️ Cargo correctamente.", 2)
end