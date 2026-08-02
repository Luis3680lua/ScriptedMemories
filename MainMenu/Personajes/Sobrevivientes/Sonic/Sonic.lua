local CONFIG = {
    Folder = "ScriptedMemories/cache",
    Modules = {
        { name = "LMS", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Personajes/Sobrevivientes/Sonic/LMS.lua", file = "script_lms.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end
if not Menu.CharacterUI then return end

local hasFS = pcall(function() return isfolder end) and isfolder ~= nil

if hasFS and makefolder and not isfolder(CONFIG.Folder) then
    pcall(makefolder, CONFIG.Folder)
end

local function loadCachedModule(url, filename)
    local path = CONFIG.Folder .. "/" .. filename
    local source = nil

    if hasFS and isfile and isfile(path) then
        local ok, data = pcall(readfile, path)
        if ok and data and #data > 0 then
            source = data
        end
    end

    if not source then
        local ok, data = pcall(game.HttpGet, game, url)
        if ok and data and #data > 0 then
            source = data
            if hasFS and writefile then
                pcall(writefile, path, data)
            end
        end
    end

    if not source then return false, "no se pudo obtener el módulo" end

    local fn, compileErr = loadstring(source)
    if not fn then return false, compileErr end

    local ok, runErr = pcall(fn)
    if not ok then return false, runErr end

    return true
end

for _, mod in ipairs(CONFIG.Modules) do
    local ok, err = loadCachedModule(mod.url, mod.file)
    if not ok then
        warn("Error al cargar " .. mod.name .. ": " .. tostring(err))
    end
end

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end