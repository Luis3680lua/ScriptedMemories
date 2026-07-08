local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

local CONFIG_FOLDER = "ScriptedMemories/config"
local CACHE_FOLDER = "ScriptedMemories/cache"

if makefolder then
    if not isfolder("ScriptedMemories") then
        makefolder("ScriptedMemories")
    end
    if not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
    if not isfolder(CACHE_FOLDER) then
        makefolder(CACHE_FOLDER)
    end
end

local MemoryMenu = {
    Modules = {},
    Tabs = {},
    ActiveTab = nil,
    GUI = nil,
    MainFrame = nil,
    ContentFrame = nil,
    TabScroller = nil,
    TabContainer = nil,
    EventListeners = {},
    DeferredSave = {
        dirtyModules = {},
        timer = nil,
    }
}

_G.MemoryMenu = MemoryMenu

function MemoryMenu:GetConfigPath(moduleName)
    return CONFIG_FOLDER .. "/" .. moduleName .. ".json"
end

function MemoryMenu:SaveModule(moduleName)
    local mod = self.Modules[moduleName]
    if not mod then return end
    local path = self:GetConfigPath(moduleName)
    local json = HttpService:JSONEncode(mod.values)
    if writefile then
        writefile(path, json)
    end
end

function MemoryMenu:LoadModule(moduleName)
    local mod = self.Modules[moduleName]
    if not mod then return nil end
    local path = self:GetConfigPath(moduleName)
    if not isfile or not isfile(path) then
        for _, setting in ipairs(mod.settingsDef) do
            if setting.default ~= nil then
                mod.values[setting.id] = setting.default
            end
        end
        self:SaveModule(moduleName)
        return mod.values
    end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if success and type(data) == "table" then
        for _, setting in ipairs(mod.settingsDef) do
            if data[setting.id] ~= nil then
                mod.values[setting.id] = data[setting.id]
            else
                mod.values[setting.id] = setting.default
            end
        end
    else
        for _, setting in ipairs(mod.settingsDef) do
            mod.values[setting.id] = setting.default
        end
        self:SaveModule(moduleName)
    end
    return mod.values
end

function MemoryMenu:MarkDirty(moduleName)
    self.DeferredSave.dirtyModules[moduleName] = true
    if not self.DeferredSave.timer then
        self.DeferredSave.timer = task.spawn(function()
            task.wait(1.5)
            local dirty = {}
            for name in pairs(self.DeferredSave.dirtyModules) do
                table.insert(dirty, name)
            end
            self.DeferredSave.dirtyModules = {}
            self.DeferredSave.timer = nil
            for _, name in ipairs(dirty) do
                self:SaveModule(name)
            end
        end)
    end
end

function MemoryMenu:OnSettingChanged(moduleName, settingId, callback)
    if not self.EventListeners[moduleName] then
        self.EventListeners[moduleName] = {}
    end
    if not self.EventListeners[moduleName][settingId] then
        self.EventListeners[moduleName][settingId] = {}
    end
    table.insert(self.EventListeners[moduleName][settingId], callback)
end

function MemoryMenu:FireEvent(moduleName, settingId, value)
    local listeners = self.EventListeners[moduleName] and self.EventListeners[moduleName][settingId]
    if listeners then
        for _, cb in ipairs(listeners) do
            task.spawn(cb, value)
        end
    end
end

function MemoryMenu:RegisterModule(moduleName, category, settingsDef)
    if self.Modules[moduleName] then
        return
    end
    local mod = {
        category = category,
        settingsDef = settingsDef,
        values = {},
    }
    self.Modules[moduleName] = mod
    if self.GUI then
    end
end

function MemoryMenu:BuildUI()
    if self.GUI then return end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ScriptedMemoriesMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    self.GUI = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 550, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    self.MainFrame = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "Scripted Memories | Framework"
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    local TabScroller = Instance.new("ScrollingFrame")
    TabScroller.Size = UDim2.new(1, 0, 0, 25)
    TabScroller.Position = UDim2.new(0, 0, 0, 30)
    TabScroller.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabScroller.BorderSizePixel = 0
    TabScroller.ScrollBarThickness = 3
    TabScroller.CanvasSize = UDim2.new(0, 0, 0, 25)
    TabScroller.ScrollingDirection = Enum.ScrollingDirection.X
    TabScroller.VerticalScrollBarInset = Enum.ScrollBarInset.None
    TabScroller.Parent = MainFrame
    self.TabScroller = TabScroller

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 0, 1, 0)
    TabContainer.AutomaticSize = Enum.AutomaticSize.X
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = TabScroller
    self.TabContainer = TabContainer

    local UIListTabs = Instance.new("UIListLayout")
    UIListTabs.FillDirection = Enum.FillDirection.Horizontal
    UIListTabs.SortOrder = Enum.SortOrder.LayoutOrder
    UIListTabs.Parent = TabContainer

    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -10, 1, -60)
    ContentFrame.Position = UDim2.new(0, 5, 0, 60)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.XY
    ContentFrame.Parent = MainFrame
    self.ContentFrame = ContentFrame

    self:AddInfoTab()

    local categories = {}
    local orderedModules = {}
    for moduleName, mod in pairs(self.Modules) do
        table.insert(orderedModules, moduleName)
    end
    table.sort(orderedModules)
    if not self.RegistrationOrder then
        self.RegistrationOrder = {}
    end
    for _, modName in ipairs(self.RegistrationOrder) do
        local mod = self.Modules[modName]
        if mod then
            if not categories[mod.category] then
                categories[mod.category] = {}
            end
            table.insert(categories[mod.category], modName)
        end
    end

    for category, modNames in pairs(categories) do
        self:AddCategoryTab(category, modNames)
    end

    self.TabScroller.CanvasSize = UDim2.new(0, TabContainer.AbsoluteSize.X, 0, 25)

    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

function MemoryMenu:AddInfoTab()
    local colTab = Color3.fromRGB(40, 40, 40)
    local colTabSel = Color3.fromRGB(60, 60, 60)
    local colWhite = Color3.new(1,1,1)

    local tabButton = Instance.new("TextButton")
    tabButton.Text = "Info"
    tabButton.Size = UDim2.new(0, 0, 1, 0)
    tabButton.AutomaticSize = Enum.AutomaticSize.X
    tabButton.BackgroundColor3 = colTab
    tabButton.TextColor3 = colWhite
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 14
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer

    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -10, 0, 80)
    infoFrame.Position = UDim2.new(0, 5, 0, 5)
    infoFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    infoFrame.BorderSizePixel = 0
    infoFrame.Visible = false
    infoFrame.Parent = self.ContentFrame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Text = "Scripted Memories\nEs un paquete de scripts que buscan mejorar la experiencia de Outcome Memories sin dañar la experiencia a los demas."
    infoLabel.Size = UDim2.new(1, -20, 1, -10)
    infoLabel.Position = UDim2.new(0, 10, 0, 5)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = colWhite
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 14
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    infoLabel.Parent = infoFrame

    local tabData = {
        Button = tabButton,
        Frame = infoFrame,
    }
    table.insert(self.Tabs, tabData)

    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tabData)
    end)

    if #self.Tabs == 1 then
        self:SwitchTab(tabData)
    end
end

function MemoryMenu:AddCategoryTab(category, moduleNames)
    local colTab = Color3.fromRGB(40, 40, 40)
    local colTabSel = Color3.fromRGB(60, 60, 60)
    local colWhite = Color3.new(1,1,1)
    local colBg1 = Color3.fromRGB(45, 45, 45)
    local colBg2 = Color3.fromRGB(50, 50, 50)
    local colGreen = Color3.fromRGB(0, 170, 0)
    local colRed = Color3.fromRGB(170, 0, 0)

    local tabButton = Instance.new("TextButton")
    tabButton.Text = category
    tabButton.Size = UDim2.new(0, 0, 1, 0)
    tabButton.AutomaticSize = Enum.AutomaticSize.X
    tabButton.BackgroundColor3 = colTab
    tabButton.TextColor3 = colWhite
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 14
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer

    local categoryFrame = Instance.new("ScrollingFrame")
    categoryFrame.Size = UDim2.new(1, -10, 1, 0)
    categoryFrame.Position = UDim2.new(0, 5, 0, 0)
    categoryFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    categoryFrame.BorderSizePixel = 0
    categoryFrame.ScrollBarThickness = 4
    categoryFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    categoryFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    categoryFrame.Visible = false
    categoryFrame.Parent = self.ContentFrame

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 8)
    uiList.Parent = categoryFrame

    for _, moduleName in ipairs(moduleNames) do
        local mod = self.Modules[moduleName]
        if mod then
            local moduleTitle = Instance.new("TextLabel")
            moduleTitle.Text = moduleName
            moduleTitle.Size = UDim2.new(1, -10, 0, 22)
            moduleTitle.BackgroundTransparency = 1
            moduleTitle.TextColor3 = colWhite
            moduleTitle.Font = Enum.Font.GothamBold
            moduleTitle.TextSize = 16
            moduleTitle.TextXAlignment = Enum.TextXAlignment.Left
            moduleTitle.Parent = categoryFrame

            for _, setting in ipairs(mod.settingsDef) do
                local control
                if setting.type == "toggle" then
                    control = self:CreateToggle(moduleName, setting)
                elseif setting.type == "slider" then
                    control = self:CreateSlider(moduleName, setting)
                elseif setting.type == "dropdown" then
                    control = self:CreateDropdown(moduleName, setting)
                elseif setting.type == "button" then
                    control = self:CreateButton(moduleName, setting)
                elseif setting.type == "color" then
                    control = self:CreateColorPicker(moduleName, setting)
                end
                if control then
                    control.Parent = categoryFrame
                end
            end
        end
    end

    task.defer(function()
        local totalHeight = 0
        for _, child in ipairs(categoryFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                totalHeight = totalHeight + child.AbsoluteSize.Y
            end
        end
        totalHeight = totalHeight + (#categoryFrame:GetChildren() - 1) * 8
        categoryFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, categoryFrame.AbsoluteSize.Y))
    end)

    local tabData = {
        Button = tabButton,
        Frame = categoryFrame,
    }
    table.insert(self.Tabs, tabData)

    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tabData)
    end)

    if #self.Tabs == 2 and self.ActiveTab == nil then
        self:SwitchTab(tabData)
    end
end

function MemoryMenu:SwitchTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        self.ActiveTab.Frame.Visible = false
    end
    tabData.Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabData.Frame.Visible = true
    self.ActiveTab = tabData
end

function MemoryMenu:CreateToggle(moduleName, setting)
    local mod = self.Modules[moduleName]
    local id = setting.id
    local text = setting.text
    local defaultValue = setting.default or false
    local current = mod.values[id]
    if current == nil then current = defaultValue end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    container.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container

    local button = Instance.new("TextButton")
    button.Text = current and "ON" or "OFF"
    button.Size = UDim2.new(0, 60, 0, 28)
    button.Position = UDim2.new(0.8, 0, 0.5, -14)
    button.BackgroundColor3 = current and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = container

    button.MouseButton1Click:Connect(function()
        local newVal = not mod.values[id]
        mod.values[id] = newVal
        button.Text = newVal and "ON" or "OFF"
        button.BackgroundColor3 = newVal and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        self:MarkDirty(moduleName)
        self:FireEvent(moduleName, id, newVal)
    end)

    return container
end

function MemoryMenu:CreateSlider(moduleName, setting)
    local mod = self.Modules[moduleName]
    local id = setting.id
    local text = setting.text
    local min = setting.min or 0
    local max = setting.max or 100
    local default = setting.default or min
    local current = mod.values[id]
    if current == nil then current = default end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    container.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. tostring(current)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 120, 0, 24)
    textBox.Position = UDim2.new(0, 0, 0, 28)
    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    textBox.TextColor3 = Color3.new(1,1,1)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 14
    textBox.Text = tostring(current)
    textBox.Parent = container

    textBox.FocusLost:Connect(function()
        local num = tonumber(textBox.Text)
        if num then
            num = math.clamp(num, min, max)
            textBox.Text = tostring(num)
            label.Text = text .. ": " .. num
            mod.values[id] = num
            self:MarkDirty(moduleName)
            self:FireEvent(moduleName, id, num)
        else
            textBox.Text = tostring(mod.values[id])
        end
    end)

    return container
end

function MemoryMenu:CreateDropdown(moduleName, setting)
    local mod = self.Modules[moduleName]
    local id = setting.id
    local text = setting.text
    local options = setting.options or {"Opción 1"}
    local defaultIndex = setting.default or 1
    local currentIndex = mod.values[id]
    if currentIndex == nil then currentIndex = defaultIndex end
    if currentIndex < 1 or currentIndex > #options then currentIndex = 1 end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    container.BorderSizePixel = 0

    local button = Instance.new("TextButton")
    button.Text = text .. ": " .. options[currentIndex]
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = container

    button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        button.Text = text .. ": " .. options[currentIndex]
        mod.values[id] = currentIndex
        self:MarkDirty(moduleName)
        self:FireEvent(moduleName, id, currentIndex)
    end)

    return container
end

function MemoryMenu:CreateButton(moduleName, setting)
    local text = setting.text or "Botón"
    local callback = setting.callback or function() end

    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.AutoButtonColor = true

    button.MouseButton1Click:Connect(function()
        callback()
    end)

    return button
end

function MemoryMenu:CreateColorPicker(moduleName, setting)
    local mod = self.Modules[moduleName]
    local id = setting.id
    local default = setting.default or Color3.new(1,1,1)
    local current = mod.values[id]
    if current == nil then current = default end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    container.BorderSizePixel = 0

    local label = Instance.new("TextLabel")
    label.Text = setting.text or "Color"
    label.Size = UDim2.new(0, 100, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container

    local colorBox = Instance.new("Frame")
    colorBox.Size = UDim2.new(0, 60, 0, 28)
    colorBox.Position = UDim2.new(0.8, 0, 0.5, -14)
    colorBox.BackgroundColor3 = current
    colorBox.BorderSizePixel = 0
    colorBox.Parent = container

    local pickButton = Instance.new("TextButton")
    pickButton.Size = UDim2.new(1, 0, 1, 0)
    pickButton.BackgroundTransparency = 1
    pickButton.Text = ""
    pickButton.Parent = colorBox
    pickButton.MouseButton1Click:Connect(function()
    end)

    return container
end

MemoryMenu.RegistrationOrder = {}
function MemoryMenu:RegisterModule(moduleName, category, settingsDef)
    if self.Modules[moduleName] then
        return
    end
    local mod = {
        category = category,
        settingsDef = settingsDef,
        values = {},
    }
    self.Modules[moduleName] = mod
    table.insert(self.RegistrationOrder, moduleName)
    self:LoadModule(moduleName)
    if self.GUI then
        self:AddCategoryTab(category, {moduleName})
        self.TabScroller.CanvasSize = UDim2.new(0, self.TabContainer.AbsoluteSize.X, 0, 25)
    end
end

local remoteScripts = {
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Characters.lua",
}

local function loadScript(url)
    local success, source = pcall(game.HttpGet, game, url)
    if not success or not source then return false end
    local f, err = loadstring(source)
    if not f then return false end
    local scriptSuccess, scriptErr = pcall(f)
    if not scriptSuccess then return false end
    return true
end

for _, url in ipairs(remoteScripts) do
    task.spawn(function()
        loadScript(url)
    end)
end

task.wait(2)
MemoryMenu:BuildUI()

return MemoryMenu