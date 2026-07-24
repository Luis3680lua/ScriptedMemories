local Menu = _G.Menu
if not Menu then return end

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/AjustesDeMenu/AjustesDeMenu.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/Extras.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Informacion/Informacion.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Visuales/Visuales.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end