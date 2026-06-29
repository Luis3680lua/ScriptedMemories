local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.spawn(function()
    local success, chase2011x = pcall(function()
        return ReplicatedStorage
            :WaitForChild("ClientAssets",15)
            :WaitForChild("Sounds",15)
            :WaitForChild("mus",15)
            :WaitForChild("Game",15)
            :WaitForChild("Round",15)
            :WaitForChild("ChaseThemes",15)
            :WaitForChild("2011x",15)
    end)
    if not success or not chase2011x then return end
    for _, skinFolder in ipairs(chase2011x:GetChildren()) do
        if skinFolder:IsA("Folder") then
            local lastLife = skinFolder:FindFirstChild("LastLifeChase")
            if lastLife and lastLife:IsA("Sound") then
                pcall(function() lastLife:SetAttribute("Eliminated", false) end)
                pcall(function() lastLife.PlaybackRegionsEnabled = false end)
            end
        end
    end
end)