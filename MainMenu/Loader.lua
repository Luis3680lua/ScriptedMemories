local Menu = _G.Menu
if not Menu then return end

local urls = {
    Info = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Informacion/Informacion.lua",
    Visuales = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Visuales/Visuales.lua",
    Extras = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/Extras.lua",
    Ajustes = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/AjustesDeMenu/AjustesDeMenu.lua",
}

for name, url in pairs(urls) do
    local success, err = pcall(function()
        Menu:LoadRemoteModule(url)
    end)
    if not success then
        warn("Error al cargar " .. name .. ": " .. tostring(err))
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end