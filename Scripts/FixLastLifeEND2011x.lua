local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.spawn(function()

	local success, chaseThemes = pcall(function()
		return ReplicatedStorage
			:WaitForChild("ClientAssets",15)
			:WaitForChild("Sounds",15)
			:WaitForChild("mus",15)
			:WaitForChild("Game",15)
			:WaitForChild("Round",15)
			:WaitForChild("ChaseThemes",15)
			:WaitForChild("2011x",15)
			:WaitForChild("Default",15)
	end)

	if not success or not chaseThemes then
		warn("Couldn't find ChaseThemes.")
		return
	end

	local lastLife = chaseThemes:FindFirstChild("LastLifeChase")

	if not lastLife or not lastLife:IsA("Sound") then
		warn("LastLifeChase not found.")
		return
	end

	pcall(function()
		lastLife:SetAttribute("Eliminated", false)
	end)

	pcall(function()
		lastLife.PlaybackRegionsEnabled = false
	end)

	print("[2011x Fix] Applied successfully.")

end)