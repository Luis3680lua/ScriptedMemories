local function loadScript(url)
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

--- placeholder de meintras
--- loadScript("https://raw.githubusercontent.com/Luis3680lua/OMStuff/main/Scripts/Load.lua")