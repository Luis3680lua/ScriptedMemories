local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cambiamos la carpeta temporalmente para forzar una descarga limpia de los MP3s corruptos
local folderName = ".cache_shop_fix"
if makefolder and not isfolder(folderName) then
    makefolder(folderName)
end

local function getOrDownloadAsset(url, filename)
    if not isfile(filename) then
        local success, audioData = pcall(function()
            return game:HttpGet(url)
        end)
        
        -- Verificamos que se descargó algo y que no es un archivo vacío o un error 404
        if success and audioData and #audioData > 100 then
            writefile(filename, audioData)
            task.wait(0.1) -- Respiro para que el disco guarde el archivo
        else
            warn("Error al descargar el archivo: " .. filename)
            return nil
        end
    end
    return getcustomasset(filename)
end

local ShopMus = ReplicatedStorage
    :WaitForChild("ClientAssets")
    :WaitForChild("Sounds")
    :WaitForChild("mus")
    :WaitForChild("Menu")
    :WaitForChild("ShopMus")

local DATOS_CANCIONES = {
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/Lone.mp3",
        Archivo = folderName .. "/Lone.mp3",
        Creditos = "Lone by ThatGuyRamon"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OfAnotherDreamv2.mp3",
        Archivo = folderName .. "/OfAnotherDreamv2.mp3",
        Creditos = "Of Another Dream v2 by Juno!"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OnceUponRemix.mp3",
        Archivo = folderName .. "/OnceUponRemix.mp3",
        Creditos = "Once Upon (Remix) by Astranova"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/InvoluntariaScore.mp3",
        Archivo = folderName .. "/InvoluntariaScore.mp3",
        Creditos = "Involuntaria Score (Unfinished) by Juno!"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/LostAndFound.mp3",
        Archivo = folderName .. "/LostAndFound.mp3",
        Creditos = "Lost & Found (Unfinished) by Juno!"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/UncannyValley.mp3",
        Archivo = folderName .. "/UncannyValley.mp3",
        Creditos = "Uncanny Valley (Unfinished) by Juno!"
    }
}

local nextIndex = #ShopMus:GetChildren() + 1

for _, datos in ipairs(DATOS_CANCIONES) do
    local soundId = getOrDownloadAsset(datos.Url, datos.Archivo)

    -- Si se descargó y mapeó correctamente, creamos el sonido
    if soundId then
        local nuevoSonido = Instance.new("Sound")
        nuevoSonido.Name = "Mus" .. nextIndex
        nextIndex += 1

        nuevoSonido.SoundId = soundId
        nuevoSonido.Volume = 2
        nuevoSonido:SetAttribute("Title", datos.Creditos)
        nuevoSonido:SetAttribute("Loops", false)
        
        -- Lo asignamos directamente para que el juego pueda leer su SoundId real
        nuevoSonido.Parent = ShopMus
    end
end

local function corregirCreditosOriginales(nombreBusqueda, nuevosCreditos)
    local buscar = string.lower(nombreBusqueda)

    for _, sonido in ipairs(ShopMus:GetChildren()) do
        if sonido:IsA("Sound") then
            local titulo = string.lower(sonido:GetAttribute("Title") or "")
            local nombre = string.lower(sonido.Name)

            if (titulo:find(buscar, 1, true) or nombre:find(buscar, 1, true))
                and not titulo:find("v2", 1, true) then
                sonido:SetAttribute("Title", nuevosCreditos)
            end
        end
    end
end

corregirCreditosOriginales("Of Another Dream", "Of Another Dream v1 by Juno!")
corregirCreditosOriginales("Dissonance", "Dissonance by Juno!")