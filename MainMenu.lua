-- mainmenu.lua
if not _G.OutcomeSections then _G.OutcomeSections = {} end

_G.OutcomeSections.Characters = function(ControlsFrame)
    local Survivors = {"Sonic","Tails","Knuckles","Amy","Cream","Blaze","Silver","Eggman","MetalSonic"}
    local Killers   = {"2011x","Kolossos","Tripwire","Fleetway"}

    -- Carga única del módulo Characters.lua
    local charMod = nil
    local function getCharMod()
        if charMod then return charMod end
        local ok, code = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/sections/Characters.lua")
        end)
        if ok and code then
            local func, err = loadstring(code)
            if func then
                local res = func()
                if type(res) == "table" and res.ShowDetail then
                    charMod = res
                    return res
                end
            end
        end
        return nil
    end

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1,0,1,0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = ControlsFrame

    -- Barra superior
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1,0,0,40)
    topBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
    topBar.Parent = mainFrame

    local survivorsBtn = Instance.new("TextButton")
    survivorsBtn.Size = UDim2.new(0,120,1,-10)
    survivorsBtn.Position = UDim2.new(0,5,0,5)
    survivorsBtn.BackgroundTransparency = 1
    survivorsBtn.Text = "Survivors"
    survivorsBtn.TextColor3 = Color3.new(1,1,1)
    survivorsBtn.Font = Enum.Font.GothamBold
    survivorsBtn.TextSize = 14
    survivorsBtn.Parent = topBar

    local killersBtn = Instance.new("TextButton")
    killersBtn.Size = UDim2.new(0,120,1,-10)
    killersBtn.Position = UDim2.new(0,130,0,5)
    killersBtn.BackgroundTransparency = 1
    killersBtn.Text = "Killers"
    killersBtn.TextColor3 = Color3.fromRGB(200,200,200)
    killersBtn.Font = Enum.Font.GothamBold
    killersBtn.TextSize = 14
    killersBtn.Parent = topBar

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1,0,1,-45)
    contentArea.Position = UDim2.new(0,0,0,45)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    local currentGroup = "Survivors"

    local function clearContent()
        for _, child in ipairs(contentArea:GetChildren()) do
            child:Destroy()
        end
    end

    local function showList(group)
        topBar.Visible = true
        clearContent()
        local listFrame = Instance.new("ScrollingFrame")
        listFrame.Size = UDim2.new(1,0,1,0)
        listFrame.BackgroundTransparency = 1
        listFrame.BorderSizePixel = 0
        listFrame.ScrollBarThickness = 4
        listFrame.Parent = contentArea

        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.fromOffset(160,200)
        grid.CellPadding = UDim2.fromOffset(10,10)
        grid.FillDirection = Enum.FillDirection.Horizontal
        grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
        grid.VerticalAlignment = Enum.VerticalAlignment.Top
        grid.StartCorner = Enum.StartCorner.TopLeft
        grid.Parent = listFrame

        local charList = group == "Survivors" and Survivors or Killers
        for _, name in ipairs(charList) do
            local charName = name
            local card = Instance.new("TextButton")
            card.Size = UDim2.fromOffset(160,200)
            card.BackgroundColor3 = Color3.fromRGB(40,40,40)
            card.Text = charName
            card.TextColor3 = Color3.new(1,1,1)
            card.Font = Enum.Font.GothamBold
            card.TextSize = 16
            card.Parent = listFrame
            Instance.new("UICorner", card).CornerRadius = UDim.new(0,8)

            card.MouseButton1Click:Connect(function()
                showDetail(charName)
            end)
        end

        listFrame.CanvasSize = UDim2.fromOffset(grid.AbsoluteContentSize.X + 20, grid.AbsoluteContentSize.Y + 20)
        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            listFrame.CanvasSize = UDim2.fromOffset(grid.AbsoluteContentSize.X + 20, grid.AbsoluteContentSize.Y + 20)
        end)
    end

    local function showDetail(characterName)
        topBar.Visible = false
        clearContent()

        -- Contenedor que se pasa al módulo externo
        local detailContainer = Instance.new("Frame")
        detailContainer.Size = UDim2.new(1,0,1,0)
        detailContainer.BackgroundTransparency = 1
        detailContainer.Parent = contentArea

        local mod = getCharMod()
        if mod and mod.ShowDetail then
            pcall(mod.ShowDetail, characterName, detailContainer)
        else
            local errLabel = Instance.new("TextLabel")
            errLabel.Size = UDim2.new(1,0,1,0)
            errLabel.BackgroundTransparency = 1
            errLabel.Text = "Settings module not available"
            errLabel.TextColor3 = Color3.fromRGB(255,80,80)
            errLabel.Font = Enum.Font.Gotham
            errLabel.TextSize = 14
            errLabel.Parent = detailContainer
        end
    end

    -- Botón de retroceso global para que el módulo vuelva a la lista
    _G.ReturnToCharacterList = function()
        showList(currentGroup)
    end

    local function setGroup(group)
        currentGroup = group
        if group == "Survivors" then
            survivorsBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
            survivorsBtn.BackgroundTransparency = 0.5
            survivorsBtn.TextColor3 = Color3.new(1,1,1)
            killersBtn.BackgroundColor3 = Color3.new(0,0,0)
            killersBtn.BackgroundTransparency = 1
            killersBtn.TextColor3 = Color3.fromRGB(200,200,200)
        else
            killersBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
            killersBtn.BackgroundTransparency = 0.5
            killersBtn.TextColor3 = Color3.new(1,1,1)
            survivorsBtn.BackgroundColor3 = Color3.new(0,0,0)
            survivorsBtn.BackgroundTransparency = 1
            survivorsBtn.TextColor3 = Color3.fromRGB(200,200,200)
        end
        showList(group)
    end

    survivorsBtn.MouseButton1Click:Connect(function() setGroup("Survivors") end)
    killersBtn.MouseButton1Click:Connect(function() setGroup("Killers") end)

    setGroup("Survivors")
end