local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")

local lobby = workspace:WaitForChild("Lobby", 15)
local lobbyMus = lobby and lobby:WaitForChild("LobbyMus", 15)
if not lobbyMus or not lobbyMus:IsA("Sound") then
	lobbyMus = nil
end

local function applyMuteSetting(muted)
	if lobbyMus then
		lobbyMus.Volume = muted and 0 or 1
	end
end

local savedMuted = Menu.Settings.lobby_muted or false
if not Menu.Settings.lobby_muted then
	Menu.Settings.lobby_muted = false
end
applyMuteSetting(savedMuted)

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

local muteSectionFrame = Instance.new("Frame")
muteSectionFrame.Size = UDim2.new(1, 0, 0, 0)
muteSectionFrame.BackgroundColor3 = T.Tertiary
muteSectionFrame.BackgroundTransparency = 0.3
muteSectionFrame.BorderSizePixel = 0
muteSectionFrame.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(muteSectionFrame, 6)
muteSectionFrame.Parent = mainContainer

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = muteSectionFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = muteSectionFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 22)
header.BackgroundTransparency = 1
header.Font = T.FontBold
header.TextSize = 15
header.TextColor3 = T.Text
header.TextXAlignment = Enum.TextXAlignment.Left
header.Text = "🔇 Silencio"
header.Parent = muteSectionFrame

local muteFrame = Instance.new("Frame")
muteFrame.Size = UDim2.new(1, 0, 0, 50)
muteFrame.BackgroundColor3 = T.Tertiary
muteFrame.BackgroundTransparency = 0.3
muteFrame.BorderSizePixel = 0
roundFrame(muteFrame, 6)
muteFrame.Parent = muteSectionFrame

local muteLabel = Instance.new("TextLabel")
muteLabel.Size = UDim2.new(0, 120, 0, 26)
muteLabel.Position = UDim2.new(0, 12, 0, 12)
muteLabel.BackgroundTransparency = 1
muteLabel.TextColor3 = T.Text
muteLabel.Font = T.Font
muteLabel.TextSize = 14
muteLabel.Text = "Silenciar lobby"
muteLabel.Parent = muteFrame

local muteSwitchBg = Instance.new("Frame")
muteSwitchBg.Size = UDim2.new(0, 44, 0, 22)
muteSwitchBg.Position = UDim2.new(1, -56, 0, 14)
muteSwitchBg.BackgroundColor3 = savedMuted and T.Green or T.Red
muteSwitchBg.BorderSizePixel = 0
roundFrame(muteSwitchBg, 11)
muteSwitchBg.Parent = muteFrame

local muteKnob = Instance.new("Frame")
muteKnob.Size = UDim2.new(0, 18, 0, 18)
muteKnob.Position = savedMuted and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
muteKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
muteKnob.BorderSizePixel = 0
roundFrame(muteKnob, 9)
muteKnob.Parent = muteSwitchBg

local function updateMuteSwitch(muted)
	muteSwitchBg.BackgroundColor3 = muted and T.Green or T.Red
	local targetX = muted and 24 or 2
	muteKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

muteSwitchBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newMuted = not (Menu.Settings.lobby_muted or false)
		Menu.Settings.lobby_muted = newMuted
		applyMuteSetting(newMuted)
		updateMuteSwitch(newMuted)
		if Menu.SaveSettings then Menu.SaveSettings() end
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end