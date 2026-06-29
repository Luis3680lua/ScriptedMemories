local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local exeName = char:GetAttribute("Character")
local exeSkin = char:GetAttribute("Skin") or "Default"
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

local chaseThemes = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("ChaseThemes")
local exeFolder = chaseThemes:FindFirstChild(exeName)
if not exeFolder then return end
local skinFolder = exeFolder:FindFirstChild(exeSkin) or exeFolder:FindFirstChild("Default")
if not skinFolder then return end

local terrorSource = skinFolder:FindFirstChild("TerrorRadius") or skinFolder:FindFirstChild("NormalChase")
if not terrorSource then return end

local terrorSound = terrorSource:Clone()
terrorSound.Parent = workspace
terrorSound.Looped = true
terrorSound.PlaybackRegionsEnabled = true
terrorSound.Volume = 0
terrorSound:Play()

RunService.RenderStepped:Connect(function()
	local minDist = 200
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local other = plr.Character
			if other:GetAttribute("Team") == "Survivor" and other:GetAttribute("State") ~= "downed" and not other:HasTag("Invisible-2011") then
				local otherRoot = other:FindFirstChild("HumanoidRootPart")
				if otherRoot then
					local dist = (humanoidRootPart.Position - otherRoot.Position).Magnitude
					if dist < minDist then minDist = dist end
				end
			end
		end
	end
	local maxRadius = 140
	terrorSound.Volume = math.clamp(1 - minDist / maxRadius, 0, 1)
end)