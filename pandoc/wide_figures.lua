local function make_set(lst)
    local result = {}
    for _, v in ipairs(lst) do
        result[v] = true
    end
    return result
end

function Figure(el)
    cls = make_set(el.content[1].content[1].classes)
    if cls.wide then
        -- caption_tex = pandoc.write(pandoc.Pandoc{ table.unpack(el.caption.long) }, "latex")
        table.insert(el.caption.long[1].content, 1, pandoc.RawInline("latex", "\\caption{"))
        table.insert(el.caption.long[1].content, pandoc.RawInline("latex", "}"))
        return {
            pandoc.RawBlock("latex", "\\begin{figure*}\n" ..
                "\\includegraphics[width=\\textwidth]{" .. el.content[1].content[1].src .. "}\n"),
            -- caption_tex,
            table.unpack(el.caption.long),
            pandoc.RawBlock("latex",
                "\\label{" .. el.identifier .. "}\n" ..
                "\\end{figure*}")
        }
    else
        caption_tex = pandoc.write(pandoc.Pandoc{ table.unpack(el.caption.long) }, "latex")
        return pandoc.RawBlock("latex", "\\begin{figure}\n" ..
            "\\includegraphics[width=8.3cm]{" .. el.content[1].content[1].src .. "}\n" ..
            "\\caption{" .. caption_tex .. "}\n" ..
            "\\label{" .. el.identifier .. "}\n" ..
            "\\end{figure}")
    end
end

