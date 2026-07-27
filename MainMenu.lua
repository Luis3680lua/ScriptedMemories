local UIS, TS, Players = game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

local Menu = {Pages = {}, ActivePage = nil, Visible = false}
_G.Menu = Menu

local FallbackTheme = {
    Background = Color3.fromRGB(20,20,25), Secondary = Color3.fromRGB(30,30,38),
    Tertiary = Color3.fromRGB(42,42,50), Hover = Color3.fromRGB(55,55,65),
    Text = Color3.fromRGB(240,240,245), TextDim = Color3.fromRGB(180,180,195),
    Accent = Color3.fromRGB(70,150,255), Green = Color3.fromRGB(70,210,110),
    Red = Color3.fromRGB(220,80,80), Border = Color3.fromRGB(60,60,75),
    Font = Enum.Font.Gotham, FontBold = Enum.Font.GothamBold,
    TitleSize = 22, TextSize = 14, SmallSize = 12, Radius = 6,
    Width = 560, Height = 440, Alpha = 0.7, Speed = 0.3,
}

local ThemeModule = _G.MenuThemeModule or { Themes = { Default = FallbackTheme }, Active = "Default" }
Menu.ThemeModule = ThemeModule
Menu.THEME = ThemeModule.Themes[ThemeModule.Active] or FallbackTheme

local THEME = Menu.THEME

function Menu:SetTheme(name)
    local t = self.ThemeModule.Themes[name]
    if not t then return false end
    self.ThemeModule.Active = name
    self.THEME = t
    self.Settings.active_theme = name
    self.SaveSettings()
    self:Notify("Tema cambiado a " .. name .. ". Reabre el menú para aplicarlo.", "info")
    return true
end

local BASE_DIR = "ScriptedMemories"
local CONFIG_DIR = BASE_DIR.."/config"
local MODULES_DIR = BASE_DIR.."/modules"
local SETTINGS_FILE = CONFIG_DIR.."/settings.json"
local hasFS = pcall(function() return isfolder end) and isfolder ~= nil

local function ensureDirs()
    if not hasFS then return end
    for _, d in ipairs({BASE_DIR, CONFIG_DIR, MODULES_DIR}) do
        if not isfolder(d) then makefolder(d) end
    end
end
ensureDirs()

local function loadSettings()
    local raw
    if hasFS and isfile and isfile(SETTINGS_FILE) then
        raw = readfile(SETTINGS_FILE)
    else
        local c = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
        raw = c and c.Value
    end
    if raw and raw ~= "" then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(data) == "table" then return data end
    end
    return {}
end

local function saveSettings()
    local ok, json = pcall(HttpService.JSONEncode, HttpService, Menu.Settings)
    if not ok then return end
    if hasFS and writefile then
        pcall(writefile, SETTINGS_FILE, json)
    else
        local c = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
        if not c then
            c = Instance.new("StringValue")
            c.Name, c.ResetOnSpawn, c.Parent = "ScriptedMemoriesSettings", false, PlayerGui
        end
        c.Value = json
    end
end
Menu.SaveSettings = saveSettings
Menu.Settings = loadSettings()

if ThemeModule.Active == "Default" and Menu.Settings.active_theme then
    if ThemeModule.Themes[Menu.Settings.active_theme] then
        ThemeModule.Active = Menu.Settings.active_theme
        Menu.THEME = ThemeModule.Themes[Menu.Settings.active_theme]
        THEME = Menu.THEME
    end
end

-- ===== CARGA DE MÓDULOS =====
local function safeLoadString(content)
    if type(content) ~= "string" or #content < 10 then return nil end
    if not content:match("^%s*[%a_%(]") then return nil end
    return loadstring(content)
end

function Menu:LoadRemoteModule(url)
    xpcall(function()
        local ok, source = pcall(game.HttpGet, game, url)
        if not ok or not source or source == "" then return end
        local fn = safeLoadString(source)
        if fn then pcall(fn) end
    end, function() end)
end

function Menu:LoadLocalModules()
    if not hasFS or not listfiles then return end
    for _, file in ipairs(listfiles(MODULES_DIR)) do
        if file:match("%.lua$") then
            xpcall(function()
                local chunk = readfile(file)
                if chunk and #chunk > 10 then
                    local fn = safeLoadString(chunk)
                    if fn then pcall(fn) end
                end
            end, function() end)
        end
    end
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    inst.Parent = parent
    return inst
end

local function corner(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 4)}, parent)
end

local function frame(parent, size, pos, color, trans)
    return new("Frame", {
        Size = size, Position = pos or UDim2.new(),
        BackgroundColor3 = color or THEME.Background,
        BackgroundTransparency = trans or 0, BorderSizePixel = 0,
    }, parent)
end

local function label(parent, text, size, color, font, alignX, alignY)
    return new("TextLabel", {
        Text = text, Size = size or UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        TextColor3 = color or THEME.Text, Font = font or THEME.Font, TextSize = THEME.TextSize,
        TextXAlignment = alignX or Enum.TextXAlignment.Left,
        TextYAlignment = alignY or Enum.TextYAlignment.Center,
    }, parent)
end

local function button(parent, text, size, pos, color, callback)
    local b = new("TextButton", {
        Text = text, Size = size or UDim2.new(0,100,0,30), Position = pos or UDim2.new(),
        BackgroundColor3 = color or THEME.Tertiary, TextColor3 = THEME.Text,
        Font = THEME.FontBold, TextSize = THEME.TextSize, BorderSizePixel = 0,
    }, parent)
    corner(b)
    if callback then b.MouseButton1Click:Connect(callback) end
    return b
end

local function hoverColor(btn, normal, hover)
    btn.MouseEnter:Connect(function() TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play() end)
end

local existing = PlayerGui:FindFirstChild("ScriptedMemoriesUI")
if existing then
    existing:Destroy()
end

local ScreenGui = new("ScreenGui", {Name = "ScriptedMemoriesUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PlayerGui)

local MainFrame = frame(ScreenGui, UDim2.new(0, THEME.Width, 0, THEME.Height), UDim2.new(0.5, -THEME.Width/2, 0.5, -THEME.Height/2), THEME.Background, 1 - THEME.Alpha)
MainFrame.Name, MainFrame.Visible, MainFrame.ZIndex = "MainWindow", false, 10
corner(MainFrame, THEME.Radius)
new("UIStroke", {Color = THEME.Border, Thickness = 1, Transparency = 0.4}, MainFrame)

local TitleBar = frame(MainFrame, UDim2.new(1,0,0,38), UDim2.new(), THEME.Secondary, 1 - THEME.Alpha)
corner(TitleBar, THEME.Radius)

local TitleLabel = label(TitleBar, "Scripted Memories | Main Menu", UDim2.new(1,-38,1,0), THEME.Text, THEME.FontBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
TitleLabel.TextSize = THEME.TitleSize

local CloseButton = button(TitleBar, "X", UDim2.new(0,38,0,38), UDim2.new(1,-38,0,0), THEME.Tertiary, function() Menu:Toggle(false) end)
CloseButton.TextSize = 20
hoverColor(CloseButton, THEME.Tertiary, THEME.Red)

local TabBar = frame(MainFrame, UDim2.new(1,0,0,34), UDim2.new(0,0,0,38), THEME.Secondary, 1 - THEME.Alpha)
local TabScroller = new("ScrollingFrame", {
    Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,6,0,0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0,0,0,34),
    ScrollingDirection = Enum.ScrollingDirection.X, VerticalScrollBarInset = Enum.ScrollBarInset.None,
}, TabBar)
local TabContainer = new("Frame", {Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1}, TabScroller)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)}, TabContainer)

local ContentFrame = new("ScrollingFrame", {
    Size = UDim2.new(1,-12,1,-84), Position = UDim2.new(0,6,0,78), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(0,0,0,0),
    ScrollingDirection = Enum.ScrollingDirection.Y, VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
}, MainFrame)
new("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder}, ContentFrame)

local function updateCanvas()
    task.wait(0.05)
    local visible
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Visible then visible = child break end
    end
    local h = visible and (visible.AbsoluteSize.Y + 10) or ContentFrame.AbsoluteSize.Y
    ContentFrame.CanvasSize = UDim2.new(0, ContentFrame.AbsoluteSize.X, 0, math.max(h, ContentFrame.AbsoluteSize.Y))
end
Menu.UpdateCanvas = updateCanvas

function Menu:Toggle(state)
    if state == nil then state = not self.Visible end
    self.Visible = state
    MainFrame.Visible = state
    if state then
        updateCanvas()
        MainFrame:TweenSize(UDim2.new(0, THEME.Width, 0, THEME.Height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, THEME.Speed, true)
    end
end

function Menu:Notify(text, kind)
    local colors = {info = THEME.Accent, success = THEME.Green, error = THEME.Red}
    local f = frame(MainFrame, UDim2.new(1,-24,0,38), UDim2.new(0,12,1,-48), THEME.Secondary, 0.2)
    corner(f)
    label(f, text, UDim2.new(1,-50,1,0), colors[kind or "info"] or THEME.Text, THEME.Font).Position = UDim2.new(0,8,0,0)
    local close = new("TextButton", {
        Text = "✕", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-34,0,5),
        BackgroundTransparency = 1, TextColor3 = THEME.TextDim, Font = THEME.FontBold,
        TextSize = 14, BorderSizePixel = 0,
    }, f)
    close.MouseButton1Click:Connect(function() f:Destroy() end)
    task.wait(3.5)
    f:Destroy()
end

function Menu:RegisterPage(name, icon)
    icon = icon or ""
    local page = {Name = name, Icon = icon, Elements = {}}
    local btn = button(TabContainer, icon.." "..name, UDim2.new(0,0,1,0), UDim2.new(), THEME.Tertiary)
    btn.AutomaticSize, btn.TextColor3, btn.Font, btn.TextSize = Enum.AutomaticSize.X, THEME.TextDim, THEME.Font, THEME.SmallSize
    btn.MouseEnter:Connect(function() if self.ActivePage ~= page then TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Hover}):Play() end end)
    btn.MouseLeave:Connect(function() if self.ActivePage ~= page then TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Tertiary}):Play() end end)

    local f = new("Frame", {Size = UDim2.new(1,-4,0,10), BackgroundTransparency = 1, Visible = false}, ContentFrame)
    new("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    page.Frame, page.Button = f, btn

    btn.MouseButton1Click:Connect(function() self:SwitchPage(page) end)
    table.insert(self.Pages, page)
    if not self.ActivePage then self:SwitchPage(page) end
    TabScroller.CanvasSize = UDim2.new(0, TabContainer.AbsoluteSize.X, 0, 34)
    return page
end

function Menu:SwitchPage(page)
    if self.ActivePage == page then return end
    if self.ActivePage then
        self.ActivePage.Frame.Visible = false
        TS:Create(self.ActivePage.Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Tertiary, TextColor3 = THEME.TextDim}):Play()
    end
    page.Frame.Visible = true
    TS:Create(page.Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Hover, TextColor3 = THEME.Text}):Play()
    self.ActivePage = page
    updateCanvas()
end

function Menu:AddComponent(page, builder)
    local comp = builder()
    comp.Parent = page.Frame
    table.insert(page.Elements, comp)
    updateCanvas()
    return comp
end

function Menu:AddToggle(page, id, text, default)
    default = (self.Settings[id] ~= nil) and self.Settings[id] or default
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,36), UDim2.new(), THEME.Secondary, 0.3)
        corner(c)
        label(c, text, UDim2.new(0.7,0,1,0)).Position = UDim2.new(0,8,0,0)
        local btn = button(c, default and "ON" or "OFF", UDim2.new(0,60,0,28), UDim2.new(0.8,0,0.5,-14), default and THEME.Green or THEME.Red)
        btn.Font, btn.TextSize = THEME.FontBold, 13
        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and "ON" or "OFF"
            btn.BackgroundColor3 = state and THEME.Green or THEME.Red
            self.Settings[id] = state
            saveSettings()
        end)
        return c
    end)
end

function Menu:AddSlider(page, id, text, min, max, default)
    default = (self.Settings[id] ~= nil) and self.Settings[id] or default
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,60), UDim2.new(), THEME.Secondary, 0.3)
        corner(c)
        local lbl = label(c, text..": "..tostring(default), UDim2.new(1,-16,0,22))
        lbl.Position = UDim2.new(0,8,0,2)
        local box = new("TextBox", {
            Size = UDim2.new(0,100,0,28), Position = UDim2.new(0,8,0,28), BackgroundColor3 = THEME.Tertiary,
            TextColor3 = THEME.Text, Font = THEME.Font, TextSize = THEME.TextSize, Text = tostring(default),
        }, c)
        corner(box)
        box.FocusLost:Connect(function()
            local num = tonumber(box.Text)
            if num then
                num = math.clamp(num, min, max)
                box.Text = tostring(num)
                lbl.Text = text..": "..num
                self.Settings[id] = num
                saveSettings()
            else
                box.Text = tostring(self.Settings[id] or default)
            end
        end)
        return c
    end)
end

function Menu:AddDropdown(page, id, text, options, defaultIndex)
    defaultIndex = (self.Settings[id] ~= nil) and self.Settings[id] or defaultIndex
    if defaultIndex < 1 or defaultIndex > #options then defaultIndex = 1 end
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,40), UDim2.new(), THEME.Secondary, 0.3)
        corner(c)
        local btn = button(c, text..": "..options[defaultIndex], UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0.5,-15), THEME.Tertiary)
        btn.Font, btn.TextColor3 = THEME.Font, THEME.Text
        local current = defaultIndex
        btn.MouseButton1Click:Connect(function()
            current = current % #options + 1
            btn.Text = text..": "..options[current]
            self.Settings[id] = current
            saveSettings()
        end)
        return c
    end)
end

function Menu:AddButton(page, text, callback)
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,38), UDim2.new(), THEME.Background, 1)
        local btn = button(c, text, UDim2.new(1,0,1,0), UDim2.new(), THEME.Tertiary, callback)
        btn.Font, btn.TextColor3 = THEME.FontBold, THEME.Text
        hoverColor(btn, THEME.Tertiary, THEME.Hover)
        return c
    end)
end

function Menu:AddLabel(page, text)
    return self:AddComponent(page, function()
        return new("TextLabel", {
            Text = text, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1,
            TextColor3 = THEME.TextDim, Font = THEME.Font, TextSize = THEME.SmallSize,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end)
end

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

local dragConn = UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Loader.lua?v=" .. tostring(os.time()))

local function getKey(settingName, default)
    return Enum.KeyCode[Menu.Settings[settingName] or default] or Enum.KeyCode[default]
end

local lastToggle = 0
Menu._capturingKey = false

local toggleConn
toggleConn = UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or Menu._capturingKey then return end
    if input.KeyCode == getKey("menu_keybind", "M") or input.KeyCode == getKey("menu_controller_keybind", "ButtonL3") then
        local now = tick()
        if now - lastToggle < 1 then return end
        lastToggle = now
        Menu:Toggle()
    end
end)

ScreenGui.Destroying:Connect(function()
    dragConn:Disconnect()
    toggleConn:Disconnect()
end)

if Menu.Settings.menu_autostart then
    task.wait(0.5)
    Menu:Toggle(true)
end

updateCanvas()