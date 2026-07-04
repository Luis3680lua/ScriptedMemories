-- Characters.lua
local FOLDER = ".cache"
if makefolder and not isfolder(FOLDER) then pcall(makefolder, FOLDER) end
local getAsset = getsynasset or getcustomasset or function() return "" end

local icons = {
    amy        = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Amy.png",        file="Amy.png"},
    blaze      = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Blaze.png",      file="Blaze.png"},
    cream      = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Cream.png",      file="Cream.png"},
    eggman     = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Eggman.png",     file="Eggman.png"},
    knuckles   = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Knuckles.png",   file="Knuckles.png"},
    metalsonic = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/MetalSonic.png", file="MetalSonic.png"},
    silver     = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Silver.png",     file="Silver.png"},
    sonic      = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png",      file="Sonic.png"},
    tails      = {url="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Tails.png",      file="Tails.png"}
}

local iconCache = {}
local function getIcon(name)
    name = name:lower()
    if iconCache[name] then return iconCache[name] end
    local data = icons[name]
    if not data then return nil end
    local path = FOLDER .. "/" .. data.file
    if not isfile(path) then
        local ok, body = pcall(function() return game:HttpGet(data.url .. "?t=" .. tick()) end)
        if not (ok and body and #body > 100) then return nil end
        pcall(writefile, path, body)
    end
    local ok, asset = pcall(function() return getAsset(path) end)
    if ok and asset then iconCache[name] = asset; return asset end
    return nil
end

local tagColors = {
    Official = Color3.fromRGB(80,200,120),
    Fanmade = Color3.fromRGB(70,130,255),
    UST = Color3.fromRGB(255,205,50),
    Unused = Color3.fromRGB(255,80,80)
}

local HttpService = game:GetService("HttpService")
local SETTINGS_PATH = FOLDER .. "/lms_settings.json"

local function loadSettings()
    if not isfile(SETTINGS_PATH) then return {} end
    local ok, data = pcall(function() return readfile(SETTINGS_PATH) end)
    if ok and data then
        local decoded = HttpService:JSONDecode(data)
        return type(decoded) == "table" and decoded or {}
    end
    return {}
end

local function saveSettings(settings)
    pcall(writefile, SETTINGS_PATH, HttpService:JSONEncode(settings))
end

local sonicLmsModule = nil
local function getSonicLms()
    if sonicLmsModule then return sonicLmsModule end
    local ok, code = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/sections/SonicLMS.lua")
    end)
    if ok and code then
        local func, err = loadstring(code)
        if func then
            local mod = func()
            if type(mod) == "table" and mod.Apply then
                sonicLmsModule = mod
                return mod
            end
        end
    end
    return nil
end

local module = {}

function module.ShowDetail(characterName, parentFrame)
    -- Limpiar por si acaso
    for _, child in ipairs(parentFrame:GetChildren()) do child:Destroy() end

    -- Botón Back (llama a la función global que define el menú principal)
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0,100,0,30)
    backBtn.Position = UDim2.new(0,10,0,10)
    backBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    backBtn.Text = "< Back"
    backBtn.TextColor3 = Color3.new(1,1,1)
    backBtn.Font = Enum.Font.Gotham
    backBtn.TextSize = 12
    backBtn.Parent = parentFrame
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0,6)
    backBtn.MouseButton1Click:Connect(function()
        if _G.ReturnToCharacterList then
            _G.ReturnToCharacterList()
        end
    end)

    -- Imagen del personaje
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0,150,0,150)
    img.Position = UDim2.new(0,20,0,50)
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Image = getIcon(characterName) or getIcon("sonic") or ""
    img.Parent = parentFrame

    -- Nombre
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0,200,0,30)
    nameLabel.Position = UDim2.new(0,180,0,90)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = characterName
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 24
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.Parent = parentFrame

    -- Si es Sonic, mostramos las opciones LMS
    if characterName == "Sonic" then
        local lmsLabel = Instance.new("TextLabel")
        lmsLabel.Size = UDim2.new(1,-10,0,25)
        lmsLabel.Position = UDim2.new(0,10,0,220)
        lmsLabel.BackgroundTransparency = 1
        lmsLabel.Text = "Last Man Standing"
        lmsLabel.TextXAlignment = Enum.TextXAlignment.Left
        lmsLabel.Font = Enum.Font.GothamBold
        lmsLabel.TextSize = 16
        lmsLabel.TextColor3 = Color3.new(1,1,1)
        lmsLabel.Parent = parentFrame

        local lmsScroll = Instance.new("ScrollingFrame")
        lmsScroll.Size = UDim2.new(1,-20,1,-290)
        lmsScroll.Position = UDim2.new(0,10,0,250)
        lmsScroll.BackgroundColor3 = Color3.fromRGB(40,40,40)
        lmsScroll.BackgroundTransparency = 0.5
        lmsScroll.BorderSizePixel = 0
        lmsScroll.ScrollBarThickness = 4
        lmsScroll.Parent = parentFrame
        Instance.new("UICorner", lmsScroll).CornerRadius = UDim.new(0,8)

        local lmsLayout = Instance.new("UIListLayout")
        lmsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        lmsLayout.Padding = UDim.new(0,5)
        lmsLayout.Parent = lmsScroll

        local selectedLms = nil
        local lmsCards = {}
        local settings = loadSettings()
        local savedOption = settings["Sonic"]

        local function deselectAll()
            for _, card in ipairs(lmsCards) do
                card.indicator.BackgroundColor3 = Color3.fromRGB(60,60,60)
                card.indicator.Text = ""
            end
        end

        local mod = getSonicLms()
        local options = mod and mod.Options or {}

        for _, opt in ipairs(options) do
            local option = opt
            local card = Instance.new("TextButton")
            card.Size = UDim2.new(1,-10,0,70)
            card.BackgroundColor3 = Color3.fromRGB(45,45,45)
            card.Text = ""
            card.Parent = lmsScroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0,6)

            local optImg = Instance.new("ImageLabel")
            optImg.Size = UDim2.new(0,50,0,50)
            optImg.Position = UDim2.new(0,10,0.5,-25)
            optImg.BackgroundTransparency = 1
            optImg.ScaleType = Enum.ScaleType.Fit
            optImg.Image = getIcon("sonic") or ""
            optImg.Parent = card

            local optName = Instance.new("TextLabel")
            optName.Size = UDim2.new(0,180,0,20)
            optName.Position = UDim2.new(0,70,0,8)
            optName.BackgroundTransparency = 1
            optName.Text = option.name
            optName.TextXAlignment = Enum.TextXAlignment.Left
            optName.Font = Enum.Font.GothamBold
            optName.TextSize = 14
            optName.TextColor3 = Color3.new(1,1,1)
            optName.Parent = card

            local creds = Instance.new("TextLabel")
            creds.Size = UDim2.new(0,180,0,15)
            creds.Position = UDim2.new(0,70,0,28)
            creds.BackgroundTransparency = 1
            creds.Text = "by " .. (option.credits or "Unknown")
            creds.TextXAlignment = Enum.TextXAlignment.Left
            creds.Font = Enum.Font.Gotham
            creds.TextSize = 11
            creds.TextColor3 = Color3.fromRGB(180,180,180)
            creds.Parent = card

            local tag = Instance.new("TextLabel")
            tag.Size = UDim2.new(0,60,0,18)
            tag.Position = UDim2.new(0,260,0,8)
            tag.BackgroundColor3 = tagColors["Official"] or Color3.fromRGB(150,150,150)
            tag.Text = "Official"
            tag.Font = Enum.Font.GothamBold
            tag.TextSize = 10
            tag.TextColor3 = Color3.new(1,1,1)
            tag.BackgroundTransparency = 0.3
            tag.Parent = card
            Instance.new("UICorner", tag).CornerRadius = UDim.new(0,4)

            local indicator = Instance.new("TextButton")
            indicator.Size = UDim2.new(0,30,0,30)
            indicator.Position = UDim2.new(1,-40,0.5,-15)
            indicator.BackgroundColor3 = Color3.fromRGB(60,60,60)
            indicator.Text = ""
            indicator.Font = Enum.Font.GothamBold
            indicator.TextSize = 18
            indicator.TextColor3 = Color3.new(1,1,1)
            indicator.Parent = card
            Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)

            card.indicator = indicator

            if savedOption and option.name == savedOption then
                indicator.BackgroundColor3 = Color3.fromRGB(0,170,255)
                indicator.Text = "✓"
                selectedLms = option
            end

            card.MouseButton1Click:Connect(function()
                deselectAll()
                indicator.BackgroundColor3 = Color3.fromRGB(0,170,255)
                indicator.Text = "✓"
                selectedLms = option
            end)

            table.insert(lmsCards, card)
        end

        -- Botones Aceptar / Rechazar
        local acceptBtn = Instance.new("TextButton")
        acceptBtn.Size = UDim2.new(0,100,0,35)
        acceptBtn.Position = UDim2.new(0,10,1,-45)
        acceptBtn.BackgroundColor3 = Color3.fromRGB(0,170,100)
        acceptBtn.Text = "Accept"
        acceptBtn.TextColor3 = Color3.new(1,1,1)
        acceptBtn.Font = Enum.Font.GothamBold
        acceptBtn.TextSize = 14
        acceptBtn.Parent = parentFrame
        Instance.new("UICorner", acceptBtn).CornerRadius = UDim.new(0,6)
        acceptBtn.MouseButton1Click:Connect(function()
            if selectedLms then
                local settings = loadSettings()
                settings["Sonic"] = selectedLms.name
                saveSettings(settings)
                local mod = getSonicLms()
                if mod then mod.Apply("Sonic", selectedLms.name) end
            end
        end)

        local rejectBtn = Instance.new("TextButton")
        rejectBtn.Size = UDim2.new(0,100,0,35)
        rejectBtn.Position = UDim2.new(0,120,1,-45)
        rejectBtn.BackgroundColor3 = Color3.fromRGB(170,60,60)
        rejectBtn.Text = "Reject"
        rejectBtn.TextColor3 = Color3.new(1,1,1)
        rejectBtn.Font = Enum.Font.GothamBold
        rejectBtn.TextSize = 14
        rejectBtn.Parent = parentFrame
        Instance.new("UICorner", rejectBtn).CornerRadius = UDim.new(0,6)
        rejectBtn.MouseButton1Click:Connect(function()
            deselectAll()
            selectedLms = nil
        end)

        lmsScroll.CanvasSize = UDim2.fromOffset(0, lmsLayout.AbsoluteContentSize.Y + 10)
        lmsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            lmsScroll.CanvasSize = UDim2.fromOffset(0, lmsLayout.AbsoluteContentSize.Y + 10)
        end)
    end
end

return module