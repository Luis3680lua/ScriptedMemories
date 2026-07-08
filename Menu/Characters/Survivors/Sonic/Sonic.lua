repeat task.wait() until _G.MemoryMenu

-- Registrar el módulo "Sonic"
_G.MemoryMenu:RegisterModule("Sonic", "Characters", {
    {id = "SelectedSongIndex", type = "slider", text = "Selected Song Index", default = 3, min = 1, max = 10},
    {id = "RandomMode", type = "dropdown", text = "Random Mode", default = "none", options = {"none", "section", "all"}},
    {id = "OpenPicker", type = "button", text = "Open Music Picker", callback = function()
        if _G.OpenSonicPicker then
            _G.OpenSonicPicker()
        end
    end}
})

-- Crear un proxy para compatibilidad con el antiguo _G.MemoryMenu.Settings
local modSonic = _G.MemoryMenu.Modules["Sonic"]
local legacySettings = _G.MemoryMenu.Settings
local keysMap = {
    ["Sonic_SelectedSongIndex"] = "SelectedSongIndex",
    ["Sonic_RandomMode"] = "RandomMode"
}

-- Redirigir lecturas/escrituras del antiguo Settings al módulo
local originalIndex = nil
setmetatable(_G.MemoryMenu, {
    __index = function(_, k)
        if k == "Settings" then
            -- Devolver una tabla proxy que sincroniza con el módulo
            local proxy = {}
            local moduleValues = modSonic.values
            for legacyKey, moduleKey in pairs(keysMap) do
                -- Al leer, usar el valor del módulo
                proxy[legacyKey] = moduleValues[moduleKey]
            end
            -- Permitir también acceso directo a las claves antiguas si se usa rawget
            setmetatable(proxy, {
                __index = function(_, key)
                    if keysMap[key] then
                        return moduleValues[keysMap[key]]
                    else
                        return legacySettings[key]
                    end
                end,
                __newindex = function(_, key, value)
                    if keysMap[key] then
                        local modKey = keysMap[key]
                        if moduleValues[modKey] ~= value then
                            moduleValues[modKey] = value
                            _G.MemoryMenu:MarkDirty("Sonic")
                        end
                    else
                        legacySettings[key] = value
                        -- Si es una clave que no mapeamos, guardar en el viejo settings también
                        _G.MemoryMenu.SaveSettings = function() end -- evitar doble guardado? mejor omitir
                    end
                end
            })
            return proxy
        end
        return rawget(_G.MemoryMenu, k)
    end
})

-- A partir de aquí, el código original de Sonic.lua (sin cambios)
local section = _G.MemoryMenu.Sections["Characters"]
if not section then return end

local songNames = {
    "Break Free",
    "Speed of Sound Round 2",
    "Don't Blink",
    "Speed of Sound Round 1",
    "Speed of Sound Round 2 (Bonus Mix)",
    "Don't Blink (Old Lyrics)",
    "So, Don't Blink"
}

local function buildSonicMenu()
    for _, child in ipairs(section.Frame:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local backFrame = Instance.new("Frame")
    backFrame.Size = UDim2.new(1, -10, 0, 0)
    backFrame.Position = UDim2.new(0, 5, 0, 5)
    backFrame.BackgroundTransparency = 1
    backFrame.Parent = section.Frame

    local backButton = Instance.new("TextButton")
    backButton.Text = "Volver"
    backButton.Size = UDim2.new(0, 200, 0, 30)
    backButton.Position = UDim2.new(0, 0, 0, 0)
    backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    backButton.TextColor3 = Color3.new(1, 1, 1)
    backButton.Font = Enum.Font.GothamBold
    backButton.TextSize = 14
    backButton.BorderSizePixel = 0
    backButton.Parent = backFrame

    backButton.MouseButton1Click:Connect(function()
        if _G.RebuildCharactersPanel then
            _G.RebuildCharactersPanel()
        end
    end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -45)
    contentFrame.Position = UDim2.new(0, 5, 0, 40)
    contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = section.Frame

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, 5)
    uiPadding.PaddingBottom = UDim.new(0, 5)
    uiPadding.PaddingLeft = UDim.new(0, 5)
    uiPadding.PaddingRight = UDim.new(0, 5)
    uiPadding.Parent = contentFrame

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 5)
    uiList.Parent = contentFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Sonic the Hedgehog"
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = contentFrame

    local currentSongLabel = Instance.new("TextLabel")
    currentSongLabel.Size = UDim2.new(1, -10, 0, 20)
    currentSongLabel.BackgroundTransparency = 1
    currentSongLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    currentSongLabel.Font = Enum.Font.Gotham
    currentSongLabel.TextSize = 14
    currentSongLabel.Parent = contentFrame

    local function updateCurrentSongLabel()
        local index = _G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] or 3  -- ahora se obtiene del módulo
        local name = songNames[index] or songNames[3]
        currentSongLabel.Text = "LMS seleccionado: " .. name
    end
    updateCurrentSongLabel()

    local lmsButton = Instance.new("TextButton")
    lmsButton.Text = "Last Man Standing"
    lmsButton.Size = UDim2.new(1, -10, 0, 36)
    lmsButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    lmsButton.TextColor3 = Color3.new(1, 1, 1)
    lmsButton.Font = Enum.Font.GothamBold
    lmsButton.TextSize = 14
    lmsButton.BorderSizePixel = 0
    lmsButton.Parent = contentFrame

    lmsButton.MouseButton1Click:Connect(function()
        task.spawn(function()
            local ok, src = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Characters/Survivors/Sonic/LMS.lua")
            if ok and src then
                local f, err = loadstring(src)
                if f then
                    pcall(f)
                end
            end
        end)
    end)

    section.Frame.Size = UDim2.new(1, -10, 0, 130)
    local contentFrameParent = section.Frame.Parent
    if contentFrameParent and contentFrameParent:IsA("ScrollingFrame") then
        contentFrameParent.CanvasSize = UDim2.new(0, 0, 0, section.Frame.Size.Y.Offset + 30)
    end
end

_G.SonicRebuild = buildSonicMenu
buildSonicMenu()