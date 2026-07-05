local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.Library = {
	Sections = {},
	WindowVisible = false,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptedMemoriesMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Scripted Memories"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 25)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -60)
ContentFrame.Position = UDim2.new(0, 5, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = MainFrame

local colTab = Color3.fromRGB(40, 40, 40)
local colTabSel = Color3.fromRGB(60, 60, 60)
local colBg1 = Color3.fromRGB(45, 45, 45)
local colBg2 = Color3.fromRGB(50, 50, 50)
local colBg3 = Color3.fromRGB(35, 35, 35)
local colGreen = Color3.fromRGB(0, 170, 0)
local colRed = Color3.fromRGB(170, 0, 0)
local colWhite = Color3.new(1, 1, 1)
local fontGotham = Enum.Font.Gotham
local fontGothamBold = Enum.Font.GothamBold

local Tabs = {}

local function SwitchTab(tab)
	for _, t in ipairs(Tabs) do
		t.Button.BackgroundColor3 = colTab
		t.Frame.Visible = false
	end
	tab.Button.BackgroundColor3 = colTabSel
	tab.Frame.Visible = true
end

function _G.Library.CreateSection(name)
	if _G.Library.Sections[name] then
		return _G.Library.Sections[name]
	end

	local tabButton = Instance.new("TextButton")
	tabButton.Text = name
	tabButton.Size = UDim2.new(0, 100, 1, 0)
	tabButton.BackgroundColor3 = colTab
	tabButton.TextColor3 = colWhite
	tabButton.Font = fontGotham
	tabButton.TextSize = 14
	tabButton.BorderSizePixel = 0
	tabButton.Parent = TabContainer

	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, -10, 0, 0)
	sectionFrame.Position = UDim2.new(0, 5, 0, 5)
	sectionFrame.BackgroundColor3 = colBg3
	sectionFrame.BorderSizePixel = 0
	sectionFrame.Visible = false
	sectionFrame.Parent = ContentFrame

	local sectionData = {
		Name = name,
		Button = tabButton,
		Frame = sectionFrame,
		Elements = {},
	}

	function sectionData:AddButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Text = text
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = colBg2
		btn.TextColor3 = colWhite
		btn.Font = fontGotham
		btn.TextSize = 14
		btn.BorderSizePixel = 0
		btn.Parent = self.Frame

		btn.MouseButton1Click:Connect(callback)

		self.Frame.Size = UDim2.new(1, -10, 0, (#self.Elements + 1) * 35 + 10)
		table.insert(self.Elements, btn)
		ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.Frame.Size.Y.Offset + 20)
		return btn
	end

	function sectionData:AddToggle(text, default, callback)
		local toggle = Instance.new("Frame")
		toggle.Size = UDim2.new(1, -10, 0, 30)
		toggle.BackgroundColor3 = colBg1
		toggle.BorderSizePixel = 0
		toggle.Parent = self.Frame

		local label = Instance.new("TextLabel")
		label.Text = text
		label.Size = UDim2.new(0.7, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = colWhite
		label.Font = fontGotham
		label.TextSize = 14
		label.Parent = toggle

		local button = Instance.new("TextButton")
		button.Text = default and "ON" or "OFF"
		button.Size = UDim2.new(0, 50, 0, 20)
		button.Position = UDim2.new(0.8, 0, 0.5, -10)
		button.BackgroundColor3 = default and colGreen or colRed
		button.TextColor3 = colWhite
		button.Font = fontGothamBold
		button.TextSize = 14
		button.BorderSizePixel = 0
		button.Parent = toggle

		local state = default
		button.MouseButton1Click:Connect(function()
			state = not state
			button.Text = state and "ON" or "OFF"
			button.BackgroundColor3 = state and colGreen or colRed
			callback(state)
		end)
		callback(state)

		self.Frame.Size = UDim2.new(1, -10, 0, (#self.Elements + 1) * 35 + 10)
		table.insert(self.Elements, toggle)
		ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.Frame.Size.Y.Offset + 20)
		return toggle
	end

	function sectionData:AddSlider(text, min, max, default, callback)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(1, -10, 0, 50)
		sliderFrame.BackgroundColor3 = colBg1
		sliderFrame.BorderSizePixel = 0
		sliderFrame.Parent = self.Frame

		local label = Instance.new("TextLabel")
		label.Text = text .. ": " .. default
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.TextColor3 = colWhite
		label.Font = fontGotham
		label.TextSize = 14
		label.Parent = sliderFrame

		local slider = Instance.new("TextBox")
		slider.Size = UDim2.new(0, 100, 0, 20)
		slider.Position = UDim2.new(0, 0, 0, 25)
		slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		slider.TextColor3 = colWhite
		slider.Font = fontGotham
		slider.TextSize = 14
		slider.Text = tostring(default)
		slider.Parent = sliderFrame

		slider.FocusLost:Connect(function()
			local num = tonumber(slider.Text)
			if num then
				num = math.clamp(num, min, max)
				slider.Text = tostring(num)
				label.Text = text .. ": " .. num
				callback(num)
			else
				slider.Text = tostring(default)
			end
		end)

		self.Frame.Size = UDim2.new(1, -10, 0, (#self.Elements + 1) * 55 + 10)
		table.insert(self.Elements, sliderFrame)
		ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.Frame.Size.Y.Offset + 20)
		return sliderFrame
	end

	function sectionData:AddDropdown(text, options, defaultIndex, callback)
		local currentIndex = defaultIndex or 1
		local dropdownFrame = Instance.new("Frame")
		dropdownFrame.Size = UDim2.new(1, -10, 0, 30)
		dropdownFrame.BackgroundColor3 = colBg1
		dropdownFrame.BorderSizePixel = 0
		dropdownFrame.Parent = self.Frame

		local btn = Instance.new("TextButton")
		btn.Text = text .. ": " .. options[currentIndex]
		btn.Size = UDim2.new(1, -10, 0, 25)
		btn.Position = UDim2.new(0, 5, 0, 2)
		btn.BackgroundColor3 = colBg2
		btn.TextColor3 = colWhite
		btn.Font = fontGotham
		btn.TextSize = 14
		btn.BorderSizePixel = 0
		btn.Parent = dropdownFrame

		btn.MouseButton1Click:Connect(function()
			currentIndex = (currentIndex % #options) + 1
			btn.Text = text .. ": " .. options[currentIndex]
			callback(options[currentIndex], currentIndex)
		end)

		self.Frame.Size = UDim2.new(1, -10, 0, (#self.Elements + 1) * 35 + 10)
		table.insert(self.Elements, dropdownFrame)
		ContentFrame.CanvasSize = UDim2.new(0, 0, 0, self.Frame.Size.Y.Offset + 20)
		return dropdownFrame
	end

	tabButton.MouseButton1Click:Connect(function()
		SwitchTab(sectionData)
	end)

	_G.Library.Sections[name] = sectionData
	table.insert(Tabs, sectionData)

	if #Tabs == 1 then
		SwitchTab(sectionData)
	end

	return sectionData
end

local infoSection = _G.Library.CreateSection("Info")
infoSection.Frame.Size = UDim2.new(1, -10, 0, 150)

local infoLabel = Instance.new("TextLabel")
infoLabel.Text = "Bienvenido al menu de Scripted Memories\nPresiona Shift Derecho para abrir/cerrar este menú."
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = colWhite
infoLabel.Font = fontGotham
infoLabel.TextSize = 16
infoLabel.TextWrapped = true
infoLabel.Parent = infoSection.Frame

local charSection = _G.Library.CreateSection("Characters")
charSection.Frame.Size = UDim2.new(1, -10, 0, 100)

local subMenuFrame = Instance.new("Frame")
subMenuFrame.Size = UDim2.new(1, -10, 0, 95)
subMenuFrame.BackgroundTransparency = 1
subMenuFrame.Parent = charSection.Frame

local subMenuLayout = Instance.new("UIListLayout")
subMenuLayout.Padding = UDim.new(0, 5)
subMenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
subMenuLayout.Parent = subMenuFrame

local survButton = Instance.new("TextButton")
survButton.Text = "Survivors"
survButton.Size = UDim2.new(0, 200, 0, 40)
survButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
survButton.TextColor3 = Color3.new(1, 1, 1)
survButton.Font = Enum.Font.GothamBold
survButton.TextSize = 16
survButton.BorderSizePixel = 0
survButton.Parent = subMenuFrame

local killButton = Instance.new("TextButton")
killButton.Text = "Killers"
killButton.Size = UDim2.new(0, 200, 0, 40)
killButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.Font = Enum.Font.GothamBold
killButton.TextSize = 16
killButton.BorderSizePixel = 0
killButton.Parent = subMenuFrame

local survFrame = Instance.new("Frame")
survFrame.Size = UDim2.new(1, -10, 0, 120)
survFrame.BackgroundTransparency = 1
survFrame.Visible = false
survFrame.Parent = charSection.Frame

local backBtn1 = Instance.new("TextButton")
backBtn1.Text = "< Volver"
backBtn1.Size = UDim2.new(0, 100, 0, 25)
backBtn1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
backBtn1.TextColor3 = Color3.new(1, 1, 1)
backBtn1.Font = Enum.Font.Gotham
backBtn1.TextSize = 14
backBtn1.BorderSizePixel = 0
backBtn1.Position = UDim2.new(0, 5, 0, 5)
backBtn1.Parent = survFrame

backBtn1.MouseButton1Click:Connect(function()
	survFrame.Visible = false
	subMenuFrame.Visible = true
end)

local sonicBtn = Instance.new("TextButton")
sonicBtn.Text = "Sonic LMS"
sonicBtn.Size = UDim2.new(0, 200, 0, 40)
sonicBtn.Position = UDim2.new(0.5, -100, 0, 40)
sonicBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
sonicBtn.TextColor3 = Color3.new(1, 1, 1)
sonicBtn.Font = Enum.Font.GothamBold
sonicBtn.TextSize = 16
sonicBtn.BorderSizePixel = 0
sonicBtn.Parent = survFrame

sonicBtn.MouseButton1Click:Connect(function()
	local function loadSonic()
		local ok, src = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Menu/Sonic.lua")
		if ok and src then
			local f = loadstring(src)
			if f then
				pcall(f)
			end
		end
	end
	spawn(loadSonic)
end)

local killFrame = Instance.new("Frame")
killFrame.Size = UDim2.new(1, -10, 0, 120)
killFrame.BackgroundTransparency = 1
killFrame.Visible = false
killFrame.Parent = charSection.Frame

local backBtn2 = Instance.new("TextButton")
backBtn2.Text = "< Volver"
backBtn2.Size = UDim2.new(0, 100, 0, 25)
backBtn2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
backBtn2.TextColor3 = Color3.new(1, 1, 1)
backBtn2.Font = Enum.Font.Gotham
backBtn2.TextSize = 14
backBtn2.BorderSizePixel = 0
backBtn2.Position = UDim2.new(0, 5, 0, 5)
backBtn2.Parent = killFrame

backBtn2.MouseButton1Click:Connect(function()
	killFrame.Visible = false
	subMenuFrame.Visible = true
end)

local killerPlaceholder = Instance.new("TextLabel")
killerPlaceholder.Text = "Próximamente..."
killerPlaceholder.Size = UDim2.new(0, 200, 0, 30)
killerPlaceholder.Position = UDim2.new(0.5, -100, 0.5, -15)
killerPlaceholder.BackgroundTransparency = 1
killerPlaceholder.TextColor3 = Color3.new(1, 1, 1)
killerPlaceholder.Font = Enum.Font.Gotham
killerPlaceholder.TextSize = 16
killerPlaceholder.Parent = killFrame

survButton.MouseButton1Click:Connect(function()
	subMenuFrame.Visible = false
	survFrame.Visible = true
end)

killButton.MouseButton1Click:Connect(function()
	subMenuFrame.Visible = false
	killFrame.Visible = true
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		_G.Library.WindowVisible = not _G.Library.WindowVisible
		MainFrame.Visible = _G.Library.WindowVisible
	end
end)