local function loadScript(url)
	pcall(function()
		local source = game:HttpGet(url)

		assert(source and #source > 0)

		local compiled = assert(loadstring(source))
		compiled()
	end)
end

local scripts = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SoDontBlink.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixLastLifeEND2011x.lua",
	--- "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/MetalLastLife.lua"
}

local finalScript = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua"

for _, url in ipairs(scripts) do
	loadScript(url)
	task.wait(0.1)
end

task.wait(1)

loadScript(finalScript)