local replicatedStorage = game:GetService("ReplicatedStorage")
local folderName = ".cache"

-- (Aquí va tu función getOrDownloadAsset y las URLs, sin cambios)

-- ... tu script de reemplazo de sonidos ...

-- SOLUCIÓN DEFINITIVA: Modificar el LastLifeChase original para que no tenga "Eliminated"
task.spawn(function()
    -- Esperar a que exista la ruta (timeout 15s)
    local chaseThemes = replicatedStorage:WaitForChild("ClientAssets", 15)
    if not chaseThemes then return end
    chaseThemes = chaseThemes:WaitForChild("Sounds", 15)
    if not chaseThemes then return end
    chaseThemes = chaseThemes:WaitForChild("mus", 15)
    if not chaseThemes then return end
    chaseThemes = chaseThemes:WaitForChild("Game", 15)
    if not chaseThemes then return end
    chaseThemes = chaseThemes:WaitForChild("Round", 15)
    if not chaseThemes then return end
    chaseThemes = chaseThemes:WaitForChild("ChaseThemes", 15)
    if not chaseThemes then return end
    local theme2011x = chaseThemes:WaitForChild("2011x", 15)
    if not theme2011x then return end
    -- El juego usa "Default" para todas las variantes (2011x, Retro, Miku, etc.)
    local defaultTheme = theme2011x:FindFirstChild("Default") or theme2011x:WaitForChild("Default", 10)
    if not defaultTheme then return end
    local lastLife = defaultTheme:FindFirstChild("LastLifeChase")
    if lastLife and lastLife:IsA("Sound") then
        lastLife:SetAttribute("Eliminated", nil)       -- Borra el punto de salto final
        lastLife.PlaybackRegionsEnabled = false        -- Evita saltos de región
        lastLife.PlaybackRegion = nil
        lastLife.LoopRegion = nil
        print("[2011x Fix] LastLifeChase original modificado. No más sonido final.")
    end
end)