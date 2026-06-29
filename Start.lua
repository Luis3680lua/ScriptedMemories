local scripts = {
	"BetterPing",
	"LobbyRandom",
	"TerrorRadiusChaseLastLifeRage",
	"SoDontBlink",
	"FixGodsTrickeryFailLaugh",
	"ShopUltimate",
	"SurvivorIconShop",
	"FixLastLifeEND2011x",
	"Load"
}

for _, name in ipairs(scripts) do
	local url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/" .. name .. ".lua"

	print("Loading:", name)

	local ok, err = pcall(function()
		loadstring(game:HttpGet(url))()
	end)

	if ok then
		print("✓", name)
	else
		warn("✗", name)
		warn(err)
		break
	end
end