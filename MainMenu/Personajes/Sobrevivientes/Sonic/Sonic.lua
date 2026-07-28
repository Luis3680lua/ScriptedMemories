local CONFIG = {
    Modules = {
        { name = "LMS", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Personajes/Sobrevivientes/Sonic/LMS.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end
if not Menu.CharacterUI then return end

local V = tostring(os.time())

for _, mod in ipairs(CONFIG.Modules) do
    local ok, err = pcall(function()
        Menu:LoadRemoteModule(mod.url .. "?v=" .. V)
    end)
    if not ok then
        warn("Error al cargar " .. mod.name .. ": " .. tostring(err))
    end
end

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end