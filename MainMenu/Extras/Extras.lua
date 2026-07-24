local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Extras", "🛒")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

-- Tienda omaiga
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/ShopMusicExtra.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/CorrecionDeJuno.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/Comas.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/SurvivorIconosDescartados.lua")

--Lobby xdxdx
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/LobbySelectorMus.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/MuteLobby.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end