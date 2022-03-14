--[[
    Citation formatting class for bibtex, MLA, and APA
--]]

local Format = {
    authors = "",
    title = "",
    container = "",
    edition = "",
    publisher = "",
    year = ""
}

-- Constructor
function Format:new(authors, title, container, edition, publisher, year)
    o = {}
    setmetatable(o, self)
    self.__index = self
    self.authors = authors
    self.title = title
    self.container = container
    self.edition = edition
    self.publisher = publisher
    self.year = year
    return o
end

-- Bibtex format
-- Format id: Split the author string, loop through to find last name, format id
-- Return a bibtex string
function Format:bibtex(id)
    return "@book{" .. id .. ",\n" ..
    "author = " .. string.format("\"%s\"", self.authors) .. "\n" ..
    "title = " .. string.format("\"%s\"", self.title) .. "\n" ..
    "year = " .. string.format("\"%s\"", self.year) .. "\n" ..
    "publisher = " .. string.format("\"%s\"", self.publisher) .. "\n" ..
    "}"
end

--[[
-- MLA Citation
function format.mla(authors, title, container, edition, publisher, year)
    local tab = {authors .. ". \"", title .. ".\" ", publisher .. ", ", year .. "."}
    if container then
        table.insert(tab, 3, container)
    end
    if edition then
        table.insert(tab, 4, edition)
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

function format.apa(authors, title, container, edition, publisher, year)
    publisher = string.upper(publisher)
    local tab = {authors, "(" .. year .. "). ", title .. ". ", publisher .. "."}
    if container then
        table.insert(tab, 3, container)
    end
    if edition then
        table.insert(tab, 4, edition)
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
--]]

return Format

