local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local songsFolder = workspace:WaitForChild("Assets"):WaitForChild("Songs")

local function swapToLastLife(folder)
	if folder:IsA("Folder") and folder.Name:find("Chases$") then
		local normal, lastLife = folder:FindFirstChild("NormalChase"), folder:FindFirstChild("LastLifeChase")
		if normal and lastLife then normal.SoundId = lastLife.SoundId end
	end
end

local function applyIfMetal()
	local char = LocalPlayer.Character
	if char and char:GetAttribute("Character") == "MetalSonic" then
		for _, child in ipairs(songsFolder:GetChildren()) do swapToLastLife(child) end
	end
end

songsFolder.ChildAdded:Connect(function(child)
	task.wait()
	local char = LocalPlayer.Character
	if char and char:GetAttribute("Character") == "MetalSonic" then swapToLastLife(child) end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	if char:GetAttribute("Character") == "MetalSonic" then
		for _, child in ipairs(songsFolder:GetChildren()) do swapToLastLife(child) end
	end
end)

applyIfMetal()