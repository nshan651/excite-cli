--[[
    Utility functions
--]]

local Utils = {}

-- Split function (no string split function in standard lua)
function Utils.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- Slice a table
function Utils.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

-- Recurse through a table of unknown dimensions
function Utils.recurse_table(e)
    -- if e is a table, we should iterate over its elements
    if type(e) == "table" then
        for k,v in pairs(e) do -- for every element in the table
            print(k)
            Utils.recurse_table(v)       -- recursively repeat the same procedure
        end
    else
        print("     ", e)
    end
end



return Utils
