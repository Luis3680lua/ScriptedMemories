local function loadScript(url)
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua")
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua")