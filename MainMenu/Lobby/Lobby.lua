local CONFIG = {
    PageName = "Lobby",
    PageIcon = "🏠",
    Modules = {
        "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/MuteLobby.lua",
     ---   "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/LobbySelectorMus.lua"
    }
}

local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

for _, url in ipairs(CONFIG.Modules) do
    Menu:LoadRemoteModule(url)
end

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end