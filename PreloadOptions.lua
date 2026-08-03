local FALLBACK_THEME = {
    Secondary = Color3.fromRGB(30, 30, 38), Tertiary = Color3.fromRGB(42, 42, 50),
    Hover = Color3.fromRGB(55, 55, 65), Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(180, 180, 195), Green = Color3.fromRGB(70, 210, 110),
    Red = Color3.fromRGB(220, 80, 80), Font = Enum.Font.Gotham, FontBold = Enum.Font.GothamBold,
    Radius = 6, TitleSize = 22, SmallSize = 12,
}

local function getTheme()
    return (_G.Menu and _G.Menu.THEME) or FALLBACK_THEME
end

local UI = {}

function UI.RoundFrame(frame, radius)
    local T = getTheme()
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or T.Radius or 6)
    c.Parent = frame
    return c
end

function UI.Card(parent, padding)
    local T = getTheme()
    padding = padding or 12
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundColor3 = T.Secondary
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Parent = parent
    UI.RoundFrame(f)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, padding)
    pad.PaddingRight = UDim.new(0, padding)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = f

    return f
end

function UI.InfoText(parent, text, opts)
    opts = opts or {}
    local T = getTheme()
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.Font = opts.Bold and T.FontBold or (opts.Font or T.Font)
    l.TextSize = opts.Size or 14
    l.TextColor3 = opts.Color or T.Text
    l.TextXAlignment = opts.Align or Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Text = text
    l.Parent = parent
    return l
end

-- Cabecera estándar de página: título grande + descripción, LayoutOrder = -1
function UI.PageHeader(page, title, description)
    local T = getTheme()
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 0)
    headerFrame.BackgroundTransparency = 1
    headerFrame.AutomaticSize = Enum.AutomaticSize.Y
    headerFrame.LayoutOrder = -1
    headerFrame.Parent = page.Frame

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.Padding = UDim.new(0, 2)
    headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    headerLayout.Parent = headerFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 32)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = T.FontBold
    titleLabel.TextSize = T.TitleSize or 22
    titleLabel.TextColor3 = T.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = headerFrame

    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.BackgroundTransparency = 1
        descLabel.Font = T.Font
        descLabel.TextSize = T.SmallSize or 13
        descLabel.TextWrapped = true
        descLabel.TextColor3 = T.TextDim
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.Text = description
        descLabel.Parent = headerFrame
    end

    page.HeaderFrame = headerFrame
    return headerFrame
end

-- Interruptor completo: texto + switch, ya conectado a Menu.Settings.
-- opts = { Parent, SettingKey, Name, Description, Default, OnChange(state), SwitchWidth }
function UI.Toggle(opts)
    local T = getTheme()
    local Menu = _G.Menu
    local SWITCH_WIDTH = opts.SwitchWidth or 36
    local SWITCH_HEIGHT = 20
    local KNOB_SIZE = 14
    local KNOB_OFFSET = 2

    if Menu and Menu.Settings and Menu.Settings[opts.SettingKey] == nil then
        Menu.Settings[opts.SettingKey] = opts.Default or false
    end

    local sectionFrame = UI.Card(opts.Parent)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.Parent = sectionFrame

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Padding = UDim.new(0, 10)
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Parent = row

    local textFrame = Instance.new("Frame")
    textFrame.Size = UDim2.new(1, -(SWITCH_WIDTH + 10), 0, 0)
    textFrame.AutomaticSize = Enum.AutomaticSize.Y
    textFrame.BackgroundTransparency = 1
    textFrame.Parent = row

    local textLayout = Instance.new("UIListLayout")
    textLayout.Padding = UDim.new(0, 2)
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Parent = textFrame

    UI.InfoText(textFrame, opts.Name, { Bold = true, Size = 14, Color = T.Text })
    if opts.Description then
        UI.InfoText(textFrame, opts.Description, { Size = 12, Color = T.TextDim })
    end

    local enabled = Menu and Menu.Settings and Menu.Settings[opts.SettingKey] or false

    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
    switchFrame.BackgroundColor3 = enabled and T.Green or T.Red
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = row
    UI.RoundFrame(switchFrame, SWITCH_HEIGHT / 2)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
    knob.Position = enabled and
        UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
        UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switchFrame
    UI.RoundFrame(knob, KNOB_SIZE / 2)

    local TweenService = game:GetService("TweenService")

    local function setVisual(state)
        switchFrame.BackgroundColor3 = state and T.Green or T.Red
        local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
        }):Play()
    end

    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newState = not (Menu.Settings[opts.SettingKey] or false)
            Menu.Settings[opts.SettingKey] = newState
            setVisual(newState)
            if Menu.SaveSettings then Menu.SaveSettings() end
            if opts.OnChange then opts.OnChange(newState) end
        end
    end)

    return {
        Get = function() return Menu.Settings[opts.SettingKey] end,
        Set = function(state)
            Menu.Settings[opts.SettingKey] = state
            setVisual(state)
        end
    }
end

_G.MenuUI = UI
return UI