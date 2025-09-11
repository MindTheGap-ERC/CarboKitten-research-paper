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

    if cls["code-availability"] then
        return {
            pandoc.RawBlock("latex", "\\codeavailability{"),
            el,
            pandoc.RawBlock("latex", "}")
        }
    end

    if cls["appendix"] then
        return {
            pandoc.RawBlock("latex", "\\appendix"),
            el
        }
    end
end
