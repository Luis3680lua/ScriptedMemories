local function loadScript(url)
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

-- Music Lobby Randomizer and Better Ping UI
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua")

-- In-Game music and sound effects
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SoDontBlink.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua")

-- Shop and Icon Customization
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua")

-- Loading the main script to ensure all dependencies are loaded first
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua")