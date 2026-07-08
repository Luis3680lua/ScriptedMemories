repeat task.wait() until _G.MemoryMenu

if _G.SonicPanelInitialized then
    return
end
_G.SonicPanelInitialized = true

local FOLDER = ".cache"
if makefolder and not isfolder(FOLDER) then
    makefolder(FOLDER)
end

local getAsset = getsynasset or getcustomasset or function() end

local sonicIconPath = FOLDER .. "/Sonic.png"
local sonicIconAsset = nil

local function getSonicIcon()
    if sonicIconAsset then return sonicIconAsset end
    if isfile(sonicIconPath) then
        local ok, asset = pcall(function() return getAsset(sonicIconPath) end)
        if ok and asset then
            sonicIconAsset = asset
            return asset
        end
    end
    task.spawn(function()
        local ok, data = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png?t=" .. tick())
        if ok and data and #data > 100 then
            writefile(sonicIconPath, data)
            local ok2, asset = pcall(function() return getAsset(sonicIconPath) end)
            if ok2 and asset then
                sonicIconAsset = asset
            end
        end
    end)
    return nil
end

getSonicIcon()

_G.RebuildCharactersPanel = function(parentFrame)
    for _, child in ipairs(parentFrame:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -10, 0, 30)
    tabBar.Position = UDim2.new(0, 5, 0, 5)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = parentFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabBar

    local survTab = Instance.new("TextButton")
    survTab.Text = "Sobrevivientes"
    survTab.Size = UDim2.new(0, 200, 1, 0)
    survTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    survTab.TextColor3 = Color3.new(1, 1, 1)
    survTab.Font = Enum.Font.GothamBold
    survTab.TextSize = 14
    survTab.BorderSizePixel = 0
    survTab.Parent = tabBar

    local killTab = Instance.new("TextButton")
    killTab.Text = "Asesinos"
    killTab.Size = UDim2.new(0, 200, 1, 0)
    killTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    killTab.TextColor3 = Color3.new(1, 1, 1)
    killTab.Font = Enum.Font.GothamBold
    killTab.TextSize = 14
    killTab.BorderSizePixel = 0
    killTab.Parent = tabBar

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 0, 200)
    contentFrame.Position = UDim2.new(0, 5, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = parentFrame

    local survFrame = Instance.new("Frame")
    survFrame.Size = UDim2.new(1, 0, 1, 0)
    survFrame.BackgroundTransparency = 1
    survFrame.Visible = true
    survFrame.Parent = contentFrame

    local killFrame = Instance.new("Frame")
    killFrame.Size = UDim2.new(1, 0, 1, 0)
    killFrame.BackgroundTransparency = 1
    killFrame.Visible = false
    killFrame.Parent = contentFrame

    local killerPlaceholder = Instance.new("TextLabel")
    killerPlaceholder.Text = "Placeholder..."
    killerPlaceholder.Size = UDim2.new(0, 200, 0, 30)
    killerPlaceholder.Position = UDim2.new(0.5, -100, 0.5, -15)
    killerPlaceholder.BackgroundTransparency = 1
    killerPlaceholder.TextColor3 = Color3.new(1, 1, 1)
    killerPlaceholder.Font = Enum.Font.Gotham
    killerPlaceholder.TextSize = 16
    killerPlaceholder.Parent = killFrame

    local function switchTab(active)
        if active == "Sobrevivientes" then
            survTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            killTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            survFrame.Visible = true
            killFrame.Visible = false
        else
            killTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            survTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            survFrame.Visible = false
            killFrame.Visible = true
        end
    end

    survTab.MouseButton1Click:Connect(function() switchTab("Sobrevivientes") end)
    killTab.MouseButton1Click:Connect(function() switchTab("Asesinos") end)

    local sonicBtn = Instance.new("TextButton")
    sonicBtn.Text = ""
    sonicBtn.Size = UDim2.new(0, 220, 0, 80)
    sonicBtn.Position = UDim2.new(0.5, -110, 0, 20)
    sonicBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sonicBtn.BorderSizePixel = 0
    sonicBtn.Parent = survFrame

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 60, 0, 60)
    icon.Position = UDim2.new(0, 10, 0.5, -30)
    icon.BackgroundTransparency = 1
    icon.Image = getSonicIcon() or ""
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = sonicBtn

    if not sonicIconAsset then
        task.spawn(function()
            repeat task.wait(0.5) until getSonicIcon()
            icon.Image = getSonicIcon()
        end)
    end

    local btnLabel = Instance.new("TextLabel")
    btnLabel.Text = "Sonic the Hedgehog"
    btnLabel.Size = UDim2.new(1, -80, 1, 0)
    btnLabel.Position = UDim2.new(0, 80, 0, 0)
    btnLabel.BackgroundTransparency = 1
    btnLabel.TextColor3 = Color3.new(1, 1, 1)
    btnLabel.Font = Enum.Font.GothamBold
    btnLabel.TextSize = 16
    btnLabel.Parent = sonicBtn

    sonicBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local ok, src = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Characters/Survivors/Sonic/Sonic.lua")
            if ok and src then
                local f, err = loadstring(src)
                if f then
                    pcall(f)
                end
            end
        end)
    end)

    -- Ajustar el tamaño del frame de la sección para que contenga todo
    parentFrame.Size = UDim2.new(1, -10, 0, 250)
end

_G.MemoryMenu:SetCustomCategoryBuilder("Characters", _G.RebuildCharactersPanel)
_G.MemoryMenu:TryBuildUI()