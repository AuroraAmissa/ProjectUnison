-- Delete the `#nav-hr` if there is no table of contents
local html = HTML.select_one(page, "#gen-toc>ul")
if html then
    if Table.length(HTML.children(html)) == 0 then
        HTML.delete(HTML.select_one(page, "#nav-hr"))
        HTML.delete(HTML.select_one(page, "#nav-banner-toc"))
    end
end

-- Allows anchors for all headings, but exclude any after the second level from the TOC.
Table.iter_values(HTML.delete, HTML.select(page, "#gen-toc>ul>ul>ul"))

-- Functions
function process_heading_text(element)
    -- Heading contents
    local children = HTML.children(element)
    text = Regex.replace(HTML.to_string(children[1]), "^\\$+[0-9]* ", "")
    HTML.delete(children[1])
    HTML.prepend_child(element, HTML.create_text(text))
end

-- Process excluded headings
local headings = HTML.select_all_of(page, {"h2", "h3", "h4", "h5", "h6"})
function process_heading(element)
    local text = HTML.inner_text(element)
    if String.starts_with(text, "$") then
        process_heading_text(element)
    end
end
Table.iter_values(process_heading, headings)

-- Delete the `#nav-hr` if there is no table of contents
local html = HTML.select_one(page, "#gen-toc")
function process_entries(element)
    local link = HTML.select_one(element, "a")
    local text = HTML.inner_text(link)

    if String.starts_with(text, "$$") then
        HTML.delete(element)
        return
    end

    if String.starts_with(text, "$") then
        process_heading_text(text)
    end
end
if html then
    Table.iter_values(process_entries, HTML.select(html, "li"))
end
