function make_set(lst)
    result = {}
    for _, k in ipairs(lst) do
        result[k] = true
    end
    return result
end

function Div(el)
    cls = make_set(el.classes)
    if cls["abstract"] then
        return {
            pandoc.RawBlock("latex", "\\begin{abstract}"),
            el,
            pandoc.RawBlock("latex", "\\end{abstract}")
        }
    end
    if cls["acknowledgements"] then
        return {
            pandoc.RawBlock("latex", "\\begin{acknowledgements}"),
            el,
            pandoc.RawBlock("latex", "\\end{acknowledgements}")
        }
    end
end
