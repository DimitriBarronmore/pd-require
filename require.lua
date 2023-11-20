--[[
    Require module for Playdate SDK
    © Dimitri Barronmore
    License: MIT/X11
    https://mit-license.org/
--]]

package = {}
--package.preload = {}
package.loaded = {}
package.path = "./?.lua;./?/init.lua"

local pdz_filepath = function(filepath)
    for dirpath in package.path:gmatch("[^;]+") do
        local fixed_name = filepath:gsub("%.", "/")
        local fixed_path = dirpath:gsub("%.lua", ".pdz")
        fixed_path = fixed_path:gsub("%?", fixed_name)
        if playdate.file.exists(fixed_path) then
            return fixed_path
        end
    end
end

local pdz_searcher = function(modulepath)
    local filepath = pdz_filepath(modulepath)
    if not filepath then
        return ("\n\tno file '%s.pdz' in package.path"):format(modulepath, 2)
    end
    -- Shortcutting because I'm lazy.
--    return function(reqpath)
        return playdate.file.load(filepath)
--    end
end

package.searchers = { pdz_searcher }

function require(modulename)
    if package.loaded[modulename] then
        return table.unpack(package.loaded[modulename])
    end
    local loader
    local errors = {}
    for _, searcher in ipairs(package.searchers) do
        local res = searcher(modulename)
        if type(res) == "function" then
            loader = res
            break
        else
            table.insert(errors, res)
        end
     end
     if not loader then
        error(table.concat(errors))
     end
     -- shortcutting because I'm lazy.
     local res = { pcall(loader, modulename) }
     local status = table.remove(res, 1)
     if status == false then
        error("error loading module '" .. modulename .. "'\n" .. res[1], 2)
     end
     if #res == 0 then
        res = {true}
     end
     package.loaded[modulename] = res
     return table.unpack(res)
end


