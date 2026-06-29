local function loadScript(url)
	local success, err = pcall(function()
		local source = game:HttpGet(url)

		assert(source and #source > 0, "Empty script received.")

		local compiled, compileErr = loadstring(source)
		assert(compiled, compileErr)

		compiled()
	end)

	if success then
		print("[ScriptedMemories] Loaded:", url)
	else
		warn("[ScriptedMemories] Failed:", url)
		warn(err)
	end
end

local scripts = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SoDontBlink.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixLastLifeEND2011x.lua"
}

local finalScript = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua"
for _, url in ipairs(scripts) do
	loadScript(url)
	task.wait(0.1)os
end

task.wait(1)

loadScript(finalScript)

print("[ScriptedMemories] All scripts loaded.")