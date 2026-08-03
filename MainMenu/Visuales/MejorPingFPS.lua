-- ===== NUEVA SECCIÓN DE POSICIÓN =====

local POSITIONS = {
    SuperiorDerecha = {
        label = "Superior Derecha",
        anchor = Vector2.new(1, 0),
        pos = UDim2.new(1, -10, 0, 10),
        textAlign = Enum.TextXAlignment.Right
    },
    InferiorDerecha = {
        label = "Inferior Derecha",
        anchor = Vector2.new(1, 1),
        pos = UDim2.new(1, -10, 1, -10),
        textAlign = Enum.TextXAlignment.Right
    },
    SuperiorIzquierda = {
        label = "Superior Izquierda",
        anchor = Vector2.new(0, 0),
        pos = UDim2.new(0, 10, 0, 10),
        textAlign = Enum.TextXAlignment.Left
    },
    InferiorIzquierda = {
        label = "Inferior Izquierda",
        anchor = Vector2.new(0, 1),
        pos = UDim2.new(0, 10, 1, -10),
        textAlign = Enum.TextXAlignment.Left
    }
}
local POS_NAMES = {"SuperiorDerecha", "InferiorDerecha", "SuperiorIzquierda", "InferiorIzquierda"}

local function getPositionData()
    local posKey = Menu.Settings[CONFIG.PositionKey]
    if posKey == "Personalizada" then
        return {
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.new(0, Menu.Settings[CONFIG.CustomXKey], 0, Menu.Settings[CONFIG.CustomYKey]),
            TextAlign = Enum.TextXAlignment.Right
        }
    end
    local cfg = POSITIONS[posKey]
    if cfg then
        return {
            AnchorPoint = cfg.anchor,
            Position = cfg.pos,
            TextAlign = cfg.textAlign
        }
    end
    -- fallback a SuperiorDerecha
    local def = POSITIONS.SuperiorDerecha
    return {
        AnchorPoint = def.anchor,
        Position = def.pos,
        TextAlign = def.textAlign
    }
end

-- Actualizar la función updateStatsDisplay para usar el nuevo getPositionData y también ajustar TextXAlignment
-- Reemplaza la función updateStatsDisplay completa con esta versión:

local function updateStatsDisplay()
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
    if StatsGui then
        StatsGui:Destroy()
        StatsGui = nil
    end
    if descendantConnection then
        descendantConnection:Disconnect()
        descendantConnection = nil
    end

    if not Menu.Settings[CONFIG.SettingKey] then
        restoreOriginalLabels()
        return
    end

    scanAndHideAll()
    descendantConnection = PlayerGui.DescendantAdded:Connect(hideSingleLabel)

    local posData = getPositionData()
    local gui = Instance.new("ScreenGui")
    gui.Name = "RealStatsGuiLeft"
    gui.ResetOnSpawn = false
    gui.ScreenInsets = Enum.ScreenInsets.None
    gui.DisplayOrder = 1000000
    gui.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Name = "StatsLabel"
    label.Size = UDim2.new(0.35, 0, 0.035, 0)
    label.SizeConstraint = Enum.SizeConstraint.RelativeXY
    label.AnchorPoint = posData.AnchorPoint
    label.Position = posData.Position
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.TextSize = 14
    label.Font = Enum.Font.RobotoMono
    label.TextXAlignment = posData.TextAlign or Enum.TextXAlignment.Right
    label.RichText = true
    label.Parent = gui

    local textSizeConstraint = Instance.new("UITextSizeConstraint")
    textSizeConstraint.MaxTextSize = 15
    textSizeConstraint.MinTextSize = 11
    textSizeConstraint.Parent = label

    StatsGui = gui

    local frameCount = 0
    local elapsedTime = 0

    HeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        frameCount = frameCount + 1
        elapsedTime = elapsedTime + deltaTime

        if elapsedTime >= 1 then
            local currentFps = math.round(frameCount / elapsedTime)
            frameCount = 0
            elapsedTime = 0

            local realPing = math.round(LocalPlayer:GetNetworkPing() * 1000)
            local pingColor = GetPingColor(realPing)
            local fpsColor = GetFpsColor(currentFps)

            label.Text = string.format(
                "<font color=\"%s\">%s MS</font>  |  <font color=\"%s\">FPS: %s</font>",
                pingColor, realPing, fpsColor, currentFps
            )
        end
    end)
end

-- ===== CONSTRUCCIÓN DE LA INTERFAZ DE POSICIÓN =====

local positionSection = card(sectionFrame)
positionSection.Visible = enabled

infoText(positionSection, CONFIG.PositionSectionHeader, T.FontBold, 14, T.Text)

local posGrid = Instance.new("Frame")
posGrid.Size = UDim2.new(1, 0, 0, 0)
posGrid.AutomaticSize = Enum.AutomaticSize.Y
posGrid.BackgroundTransparency = 1
posGrid.Parent = positionSection

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 120, 0, 32)
gridLayout.CellPadding = UDim.new(0, 8)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
gridLayout.Parent = posGrid

local function makePosButton(text, posKey, isCustom)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 32)
    btn.BackgroundColor3 = T.Tertiary
    btn.TextColor3 = T.Text
    btn.Font = T.FontBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text
    btn.Parent = posGrid
    roundFrame(btn, 4)

    local isActive = (not isCustom and Menu.Settings[CONFIG.PositionKey] == posKey) or
                     (isCustom and Menu.Settings[CONFIG.PositionKey] == "Personalizada")
    if isActive then
        btn.BackgroundColor3 = T.Hover
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if (not isCustom and Menu.Settings[CONFIG.PositionKey] ~= posKey) or
           (isCustom and Menu.Settings[CONFIG.PositionKey] ~= "Personalizada") then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
        end
    end)

    return btn
end

local posButtons = {}
for _, key in ipairs(POS_NAMES) do
    local btn = makePosButton(POSITIONS[key].label, key, false)
    btn.MouseButton1Click:Connect(function()
        Menu.Settings[CONFIG.PositionKey] = key
        if Menu.SaveSettings then Menu.SaveSettings() end
        -- Actualizar resaltado
        for _, b in ipairs(posButtons) do
            b.BackgroundColor3 = T.Tertiary
        end
        btn.BackgroundColor3 = T.Hover
        -- Si estaba en modo personalizado, asegurarse de cerrar cualquier editor
        if _G._posEditorActive then
            _G._posEditorActive = false
            if _G._posEditorGui then _G._posEditorGui:Destroy() end
            MainFrame.Visible = true
        end
        updateStatsDisplay()
        if Menu.UpdateCanvas then Menu.UpdateCanvas() end
    end)
    table.insert(posButtons, btn)
end

-- Botón Personalizada
local customBtn = makePosButton("✎ Personalizada", nil, true)
customBtn.MouseButton1Click:Connect(function()
    if Menu.Settings[CONFIG.PositionKey] == "Personalizada" then
        -- Si ya está en personalizada, no hacer nada o abrir el editor de nuevo
        -- Mejor abrir el editor
    end
    -- Activar editor visual
    startPositionEditor()
end)
table.insert(posButtons, customBtn)

-- ===== EDITOR VISUAL DE POSICIÓN =====

local function startPositionEditor()
    if _G._posEditorActive then return end
    _G._posEditorActive = true

    -- Ocultar menú
    MainFrame.Visible = false

    -- Crear fondo semitransparente
    local editorGui = Instance.new("ScreenGui")
    editorGui.Name = "PositionEditorGui"
    editorGui.ResetOnSpawn = false
    editorGui.DisplayOrder = 999999
    editorGui.Parent = PlayerGui
    _G._posEditorGui = editorGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.6
    bg.BorderSizePixel = 0
    bg.Parent = editorGui

    -- Botón Guardar y Aceptar
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 150, 0, 40)
    saveBtn.Position = UDim2.new(1, -170, 1, -60)
    saveBtn.AnchorPoint = Vector2.new(1, 1)
    saveBtn.BackgroundColor3 = T.Green
    saveBtn.TextColor3 = T.Text
    saveBtn.Font = T.FontBold
    saveBtn.TextSize = 16
    saveBtn.Text = "Guardar y Aceptar"
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = editorGui
    roundFrame(saveBtn, 6)

    saveBtn.MouseEnter:Connect(function()
        TweenService:Create(saveBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 220, 120)}):Play()
    end)
    saveBtn.MouseLeave:Connect(function()
        TweenService:Create(saveBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Green}):Play()
    end)

    -- Asegurar que el label de estadísticas esté por encima del fondo
    local statsLabel = StatsGui and StatsGui:FindFirstChild("StatsLabel")
    if statsLabel then
        statsLabel.Parent = editorGui -- moverlo al editor para que esté por encima del fondo
        statsLabel.Parent = StatsGui -- pero StatsGui está por debajo? Mejor mover el StatsGui entero a DisplayOrder mayor
        -- O simplemente asegurar que StatsGui tenga DisplayOrder mayor que editorGui
        if StatsGui then
            StatsGui.DisplayOrder = 1000001
        end
    end

    -- Variables de arrastre
    local dragging = false
    local dragStart, startPos

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local label = StatsGui and StatsGui:FindFirstChild("StatsLabel")
            if label and label.AbsoluteSize.X > 0 then
                local mousePos = input.Position
                local labelPos = label.AbsolutePosition
                local labelSize = label.AbsoluteSize
                if mousePos.X >= labelPos.X and mousePos.X <= labelPos.X + labelSize.X and
                   mousePos.Y >= labelPos.Y and mousePos.Y <= labelPos.Y + labelSize.Y then
                    dragging = true
                    dragStart = input.Position
                    startPos = label.Position
                end
            end
        end
    end

    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local label = StatsGui and StatsGui:FindFirstChild("StatsLabel")
            if label then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                label.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end

    local connections = {}
    connections[1] = UIS.InputBegan:Connect(onInputBegan)
    connections[2] = UIS.InputChanged:Connect(onInputChanged)
    connections[3] = UIS.InputEnded:Connect(onInputEnded)

    -- Guardar
    saveBtn.MouseButton1Click:Connect(function()
        local label = StatsGui and StatsGui:FindFirstChild("StatsLabel")
        if label then
            local pos = label.Position
            Menu.Settings[CONFIG.CustomXKey] = math.round(pos.X.Offset)
            Menu.Settings[CONFIG.CustomYKey] = math.round(pos.Y.Offset)
            Menu.Settings[CONFIG.PositionKey] = "Personalizada"
            if Menu.SaveSettings then Menu.SaveSettings() end
            for _, b in ipairs(posButtons) do
                b.BackgroundColor3 = T.Tertiary
            end
            customBtn.BackgroundColor3 = T.Hover
            updateStatsDisplay()
        end

        -- Limpiar editor
        _G._posEditorActive = false
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        if _G._posEditorGui then
            _G._posEditorGui:Destroy()
            _G._posEditorGui = nil
        end
        if StatsGui then
            StatsGui.DisplayOrder = 1000000
        end
        MainFrame.Visible = true
        if Menu.UpdateCanvas then Menu.UpdateCanvas() end
    end)

    -- Si se cierra la GUI de alguna manera, limpiar
    editorGui.AncestryChanged:Connect(function()
        if not editorGui.Parent then
            _G._posEditorActive = false
            for _, conn in ipairs(connections) do
                conn:Disconnect()
            end
            if StatsGui then
                StatsGui.DisplayOrder = 1000000
            end
            MainFrame.Visible = true
        end
    end)
end