local CONFIG = {
    PageName = "Shop",
    PageIcon = "🏠",
    Modules = {
        { name = "SurvivorIconosDescartados", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Shop/SurvivorIconosDescartados.lua" },
        { name = "ShopMusicExtra", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Shop/ShopMusicExtra.lua" },
        { name = "CorrecionDeJuno", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Shop/CorrecionDeJuno.lua" },
        { name = "Comas", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Shop/Comas.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local V = tostring(os.time())

for _, mod in ipairs(CONFIG.Modules) do
    local success, err = pcall(function()
        Menu:LoadRemoteModule(mod.url .. "?v=" .. V)
    end)
    if not success then
        warn("Error al cargar " .. mod.name .. ": " .. tostring(err))
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end