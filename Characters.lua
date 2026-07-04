-- Characters.lua
_G.OutcomeSections.Characters = function(ControlsFrame)
	-- Aquí construyes toda la interfaz de la sección "Characters"
	-- Usa 'ControlsFrame' como contenedor principal (no crees un ScreenGui nuevo)
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 100)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.Parent = ControlsFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = "Character Selection"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = frame
end