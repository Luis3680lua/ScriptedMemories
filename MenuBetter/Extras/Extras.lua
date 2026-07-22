local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Extras", "🛒")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Shop/MusicExtra.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Shop/CreditsCorrection.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Shop/CustomIcons.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Shop/NumberFormat.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end