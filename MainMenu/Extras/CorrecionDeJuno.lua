local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local activeCorrection = false
local creditCorrectionConn = nil
local originalCredits = {}

if not Menu.Settings.shop_credit_correction_enabled then
	Menu.Settings.shop_credit_correction_enabled = false
end

local function getShopMusFolder()
	local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
	if not clientAssets then return nil end
	local sounds = clientAssets:WaitForChild("Sounds", 10)
	if not sounds then return nil end
	local mus = sounds:WaitForChild("mus", 10)
	if not mus then return nil end
	local menu = mus:WaitForChild("Menu", 10)
	if not menu then return nil end
	return menu:WaitForChild("ShopMus", 10)
end

local function applyCreditCorrection(enabled)
	if creditCorrectionConn then
		creditCorrectionConn:Disconnect()
		creditCorrectionConn = nil
	end

	local function correctShopMus(shopMus)
		if not shopMus then return end
		local function correct(buscar, nuevos)
			local lower = buscar:lower()
			for _, s in ipairs(shopMus:GetChildren()) do
				if s:IsA("Sound") then
					local titulo = (s:GetAttribute("Title") or ""):lower()
					local nombre = s.Name:lower()
					if (titulo:find(lower, 1, true) or nombre:find(lower, 1, true)) and not titulo:find("v2", 1, true) then
						if enabled then
							if not originalCredits[s] then
								originalCredits[s] = s:GetAttribute("Title")
							end
							s:SetAttribute("Title", nuevos)
						else
							local original = originalCredits[s]
							if original then
								s:SetAttribute("Title", original)
								originalCredits[s] = nil
							end
						end
					end
				end
			end
		end
		correct("Of Another Dream", "Of Another Dream v1 by Juno!")
		correct("Dissonance", "Dissonance by Juno!")
	end

	local function findAndCorrect()
		local shopMus = getShopMusFolder()
		correctShopMus(shopMus)
	end

	findAndCorrect()

	if enabled then
		creditCorrectionConn = PlayerGui.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "ShopMus" and not descendant:IsA("Sound") then
				task.wait(0.1)
				correctShopMus(descendant)
			end
		end)
	end
end

if Menu.Settings.shop_credit_correction_enabled then
	applyCreditCorrection(true)
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local T = {
	Bg = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(30, 30, 38),
	Tertiary = Color3.fromRGB(42, 42, 50),
	Hover = Color3.fromRGB(55, 55, 65),
	Text = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(180, 180, 195),
	Accent = Color3.fromRGB(70, 150, 255),
	Green = Color3.fromRGB(70, 210, 110),
	Red = Color3.fromRGB(220, 80, 80),
	Border = Color3.fromRGB(60, 60, 75),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
}

local function roundFrame(frame, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = frame
end

local mainContainer = page.Frame:FindFirstChildWhichIsA("Frame") or page.Frame

local creditsSubFrame = Instance.new("Frame")
creditsSubFrame.Size = UDim2.new(1, 0, 0, 0)
creditsSubFrame.BackgroundTransparency = 1
creditsSubFrame.AutomaticSize = Enum.AutomaticSize.Y
creditsSubFrame.Parent = mainContainer

local creditsSubLayout = Instance.new("UIListLayout")
creditsSubLayout.Padding = UDim.new(0, 4)
creditsSubLayout.SortOrder = Enum.SortOrder.LayoutOrder
creditsSubLayout.Parent = creditsSubFrame

local creditsSubHeader = Instance.new("TextLabel")
creditsSubHeader.Size = UDim2.new(1, 0, 0, 18)
creditsSubHeader.BackgroundTransparency = 1
creditsSubHeader.Font = T.FontBold
creditsSubHeader.TextSize = 14
creditsSubHeader.TextColor3 = T.TextDim
creditsSubHeader.TextXAlignment = Enum.TextXAlignment.Left
creditsSubHeader.Text = "Créditos de Juno!"
creditsSubHeader.Parent = creditsSubFrame

local creditsEnabled = Menu.Settings.shop_credit_correction_enabled

local creditsToggleFrame = Instance.new("Frame")
creditsToggleFrame.Size = UDim2.new(1, 0, 0, 50)
creditsToggleFrame.BackgroundColor3 = T.Tertiary
creditsToggleFrame.BackgroundTransparency = 0.3
creditsToggleFrame.BorderSizePixel = 0
roundFrame(creditsToggleFrame, 6)
creditsToggleFrame.Parent = creditsSubFrame

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(0, 200, 0, 26)
creditsLabel.Position = UDim2.new(0, 12, 0, 12)
creditsLabel.BackgroundTransparency = 1
creditsLabel.TextColor3 = T.Text
creditsLabel.Font = T.Font
creditsLabel.TextSize = 14
creditsLabel.Text = "Corregir créditos originales"
creditsLabel.Parent = creditsToggleFrame

local creditsToggleBg = Instance.new("Frame")
creditsToggleBg.Size = UDim2.new(0, 44, 0, 22)
creditsToggleBg.Position = UDim2.new(1, -56, 0, 14)
creditsToggleBg.BackgroundColor3 = creditsEnabled and T.Green or T.Red
creditsToggleBg.BorderSizePixel = 0
roundFrame(creditsToggleBg, 11)
creditsToggleBg.Parent = creditsToggleFrame

local creditsToggleKnob = Instance.new("Frame")
creditsToggleKnob.Size = UDim2.new(0, 18, 0, 18)
creditsToggleKnob.Position = creditsEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
creditsToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
creditsToggleKnob.BorderSizePixel = 0
roundFrame(creditsToggleKnob, 9)
creditsToggleKnob.Parent = creditsToggleBg

local function updateCreditsVisual(state)
	creditsToggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	creditsToggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

creditsToggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.shop_credit_correction_enabled
		Menu.Settings.shop_credit_correction_enabled = newState
		updateCreditsVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyCreditCorrection(newState)
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end