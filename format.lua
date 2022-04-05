--[[
    Citation formatting class for bibtex, MLA, and APA
--]]

local Format = {
    authors = "",
    title = "",
    container = "",
    edition = "",
    publisher = "",
    year = "",
    id = ""
}

-- Constructor
--function Format:new(authors, title, container, edition, publisher, year, id)
function Format:new(tab)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.authors = tab[1]
    self.title = tab[2]
    self.container = tab[3]
    self.edition = tab[4]
    self.publisher = tab[5]
    self.year = tab[6]
    self.id = tab[7]
    return o
end


-- Pseudo-private output function for spacing MLA and APA
local output = function(self, tab)
    if self.container then
        table.insert(tab, 3, self.container)
    end
    if self.edition then
        table.insert(tab, 4, self.edition)
    end
    local new_line = true
    local output = ""
    for i,_ in pairs(tab) do
        if string.len(output) > 80 and new_line then
            output = output .. "\n\t"
            new_line = false
        end
       output = output .. tab[i]
    end
    return output
end

-- Bibtex format
-- Format id: Split the author string, loop through to find last name, format id
-- Return a bibtex string
local function bibtex(self)
    return "@book{" .. self.id .. ",\n" ..
    "author = " .. string.format("\"%s\"", self.authors) .. "\n" ..
    "title = " .. string.format("\"%s\"", self.title) .. "\n" ..
    "year = " .. string.format("\"%s\"", self.year) .. "\n" ..
    "publisher = " .. string.format("\"%s\"", self.publisher) .. "\n" ..
    "}"
end

-- MLA Citation
-- TODO: Implement container
local function mla(self)
    local tab = {self.authors .. ". \"", self.title .. ".\" ", self.publisher .. ", ", self.year .. "."}
    return output(self, tab)
end

-- APA Citation
local function apa(self)
    local tab = {self.authors, "(" .. self.year .. "). ", self.title .. ". ", string.upper(self.publisher) .. "."}
    return output(self, tab)
end

-- Public function to choose citation
function Format:cite(style)
    -- Declare output and Format object
    local output

    -- Choose a citation style
    if style == "bibtex" then
        print("\nBibtex selected")
        output = bibtex(self)
    elseif style == "MLA" then
        print("\nMLA Selected")
        output = mla(self)
    elseif style == "APA" then
        print("\nAPA Selected")
        output = apa(self)
    end

    return output
end

return Format
