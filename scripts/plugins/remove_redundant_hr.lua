-- Delete the `#nav-hr` if there is no table of contents
local html = HTML.select_one(page, "#gen-toc>ul")
if html then
    if Table.length(HTML.children(html)) == 0 then
        HTML.delete(HTML.select_one(page, "#nav-hr"))
    end
end

-- Allows anchors for all headings, but exclude any after the second level from the TOC.
Table.iter_values(HTML.delete, HTML.select(page, "#gen-toc>ul>ul>ul"))
