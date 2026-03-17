local function make_set(lst)
    local result = {}
    for _, v in ipairs(lst) do
        result[v] = true
    end
    return result
end

local function join(lst, sep)
    if #lst == 0 then
        return ""
    end
    local result = lst[1]
    for i = 2, #lst do
        result = result .. sep .. lst[i]
    end
    return result
end

function Table(el)
    cls = make_set(el.classes)
    local caption_tex = pandoc.write(pandoc.Pandoc{ table.unpack(el.caption.long) }, "latex")
    local col_spec = ""
    local align_table = {
        AlignLeft = "l", AlignRight = "r", AlignCenter = "c", AlignDefault = "l"
    }
    for _, s in ipairs(el.colspecs) do
        col_spec = col_spec .. align_table[s[1]]
    end

    local header = {}
    for _, h in ipairs(el.head.rows[1].cells) do
        table.insert(header, pandoc.write(pandoc.Pandoc{ table.unpack(h.content) }, "latex"))
    end

    local body = {}
    for _, row in ipairs(el.bodies[1].body) do
        local row_items = {}
        for _, i in ipairs(row.cells) do
            table.insert(row_items, pandoc.write(pandoc.Pandoc{ table.unpack(i.content) }, "latex"))
        end
        table.insert(body, join(row_items, " & ") .. "\\\\")
    end

    local open_tag
    local close_tag
    if not cls["wide-table"] then
        open_tag = "\\begin{table}"
        close_tag = "\\end{table}"
    else
        open_tag = "\\begin{table*}[t]"
        close_tag = "\\end{table*}"
    end

    return pandoc.RawBlock("latex", open_tag .. "\n" ..
        "\\caption{" .. caption_tex .. "}\n" ..
        "\\label{" .. el.identifier .. "}\n" ..
        "\\begin{tabular}{" .. col_spec .. "}\n" ..
        "\\tophline\n" ..
        join(header, " & ") .. "\\\\\n" ..
        "\\middlehline\n" ..
        join(body, "\n") .. "\n" ..
        "\\bottomhline\n" ..
        "\\end{tabular}\n" ..
        close_tag)
end
