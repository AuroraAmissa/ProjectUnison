local html = HTML.select_one(page, "#gen-toc>ul")
if html then
    if Table.length(HTML.children(html)) == 0 then
        HTML.delete(HTML.select_one(page, "#nav-hr"))
    end
end