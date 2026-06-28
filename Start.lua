local function loadScript(url)
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua")

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua")

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SoDontBlink.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua")

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua")