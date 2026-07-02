local function limpiarCache()
    local carpetas = {".cache", "workspace"}
    for _, carpeta in ipairs(carpetas) do
        pcall(function()
            if delfolder and isfolder and isfolder(carpeta) then
                delfolder(carpeta)
            end
        end)
    end
end
limpiarCache()
task.wait(0.1)

local function loadScript(url)
	pcall(function()
		local source = game:HttpGet(url)
		assert(source and #source > 0)
		local compiled = assert(loadstring(source))
		compiled()
	end)
end

local infoUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Info.lua"
loadScript(infoUrl)
task.wait(0.2)

local scripts = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Rings.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SoDontBlink.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixLastLifeEND2011x.lua",
}

local finalScript = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua"

for _, url in ipairs(scripts) do
	loadScript(url)
	task.wait(0.1)
end

task.wait(1)

loadScript(finalScript)