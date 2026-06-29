local function loadScript(url)
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet(url))()
		end)
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
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixLastLifeEND2011x.lua"
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua"

}

for _, url in ipairs(scripts) do
	loadScript(url)
end