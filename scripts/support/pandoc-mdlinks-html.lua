local common = require 'scripts.support.pandoc-common'

local pages = pandoc.json.decode(common.read_file("build/pages.json"))

function Link(el)
    if el.target and not el.target:startswith("http") then
        local components = el.target:split("#")

        local target = components[1]
        local section = components[2]

        if target and target == "" then
        	local linkName = pandoc.utils.stringify(el.content)
        	if pages[linkName:lower()] then
        		target = linkName:lower()
        	end
        end
        if target and pages[target:lower()] then
            target = "../" .. pages[target:lower()]:gsub("%.md", ".html")
        end

        if section then
            section = section:lower():gsub("%%20", "-")
            target = target .. "#" .. section
        end

        el.target = target
    end

    return el
end