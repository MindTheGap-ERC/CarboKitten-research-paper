function Cite(el)
    if #el.citations > 1 then
        return
    end
    local plain_ref = pandoc.write(pandoc.Pandoc { table.unpack(el.content) }, "plain")
    local pre = string.match(plain_ref, "%[([^@]*)@.*%]")
    if pre then
        pre = pre:gsub("%s+", "") .. "~"
    else
        pre = ""
    end
    local m = string.match(el.citations[1].id, "(fig:.*)")
    if m ~= nil then
        return pandoc.RawInline("tex", pre .. "\\ref{" .. m .. "}")
    end
    local m = string.match(el.citations[1].id, "(tbl:.*)")
    if m ~= nil then
        return pandoc.RawInline("tex", pre .. "\\ref{" .. m .. "}")
    end
    local m = string.match(el.citations[1].id, "(sec:.*)")
    if m ~= nil then
        return pandoc.RawInline("tex", pre .. "\\ref{" .. m .. "}")
    end
end

function Table(el)
    if el.caption.long == nil then
        return
    end
    local tag = el.caption.long[1].content[#el.caption.long[1].content].text
    local m = string.match(tag, "{#(tbl:.*)}")
    el.attr.identifier = m
    table.remove(el.caption.long[1].content, #el.caption.long[1].content)
    return el
end
