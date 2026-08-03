local FOLDER = "ScriptedMemories/cache"

local hasFS = pcall(function() return isfolder end) and isfolder ~= nil
local canAsset = pcall(function() return getcustomasset end) and getcustomasset ~= nil

local function ensureFolder()
    if hasFS and makefolder and not isfolder(FOLDER) then
        pcall(makefolder, FOLDER)
    end
end
ensureFolder()

local Assets = {}

function Assets:Path(name)
    return FOLDER .. "/" .. name
end

function Assets:GetCached(filename)
    if not (hasFS and canAsset and isfile and isfile(filename)) then return nil end
    local ok, asset = pcall(getcustomasset, filename)
    return ok and asset or nil
end

function Assets:Download(url, filename)
    if not canAsset or not url then return nil end
    local ok, result = pcall(function()
        if hasFS and isfile and isfile(filename) then
            return getcustomasset(filename)
        end
        if hasFS and writefile then
            local dok, data = pcall(game.HttpGet, game, url)
            if dok and data and #data > 0 then
                writefile(filename, data)
                return getcustomasset(filename)
            end
        end
        return nil
    end)
    return ok and result or nil
end

function Assets:GetIcon(url)
    if not url or url == "" then return nil end
    local name = url:match("([^/]+)$") or tostring(math.random(100000))
    return self:Download(url, self:Path("icon_" .. name))
end

function Assets:LoadScript(url, filename)
    local path = self:Path(filename)
    local source = nil

    if hasFS and isfile and isfile(path) then
        local ok, data = pcall(readfile, path)
        if ok and data and #data > 0 then source = data end
    end

    if not source then
        local ok, data = pcall(game.HttpGet, game, url)
        if ok and data and #data > 0 then
            source = data
            if hasFS and writefile then pcall(writefile, path, data) end
        end
    end

    if not source then return false, "no se pudo obtener el módulo" end

    local fn, compileErr = loadstring(source)
    if not fn then return false, compileErr end

    local ok, runErr = pcall(fn)
    if not ok then return false, runErr end

    return true
end

_G.MenuAssets = Assets
return Assets