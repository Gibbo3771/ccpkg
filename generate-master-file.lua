local json = require ("dkjson")
local lfs = require("lfs")

local function iterateFolder(path)
    local output = {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            print ("\t "..f)
            local fh = assert(io.open(f, "rb"))
            local content = fh:read("*all")
            fh:close()
            local func, err = load(content)
            if func then
                local ok, formula = pcall(func)
                if ok then
                    table.insert(output, formula)
                else
                    error("Could not execute formula")
                end
            else
                error("Could not compile formula")
            end
        end
    end
end

local output = iterateFolder("./formula")
print(json.encode(output, { indent = true }))

