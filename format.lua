-- Citation Formatting

local format = {}

-- Bibtex format
function format.bibtex(id, authors, title, year, publisher)
    -- Format id: Split the author string, loop through to find last name, format id
    -- Return a bibtex string
    return "@book{" .. id .. ",\n" ..
    "author = " .. string.format("\"%s\"", authors) .. "\n" ..
    "title = " .. string.format("\"%s\"", title) .. "\n" ..
    "year = " .. string.format("\"%s\"", year) .. "\n" ..
    "publisher = " .. string.format("\"%s\"", publisher) .. "\n" ..
    "}"
end

function format.mla(authors, title, container, edition, publisher, year)
    return authors .. ". \"" .. title .. ".\" \n\t" .. edition .. ", " .. publisher .. ", \t" .. year .. ", Accessed 08 March 2022."
end

function format.apa()
    print("APA selected")
end

return format

