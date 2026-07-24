local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Ajustes del Menú", "⚙️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/AjustesDeMenu/AccesoDirectoTeclado.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/AjustesDeMenu/AccesoDirectoControl.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end