local json = require ("dkjson")
local lfs = require("lfs")

local output = {
    packages = {}
}

local function iterateFolder(path)
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
                    table.insert(output.packages, {
                        pkg_name = formula.name,
                        pkg_description = formula.description,
                        pkg_homepage = formula.homepage,
                        pkg_repository = formula.repository,
                        pkg_authors = formula.authors,
                        pkg_license = formula.license,
                        pkg_target = formula.target,
                        pkg_versions = formula.versions,
                        pkg_stableVersion = formula.stable()
                    })
                else
                    error("Could not execute formula")
                end
            else
                error("Could not compile formula")
            end
        end
    end
end

iterateFolder("./formula")
local fh = assert(io.open("./masterfile.json", "w"))
fh:write(json.encode(output, { indent = true }))
