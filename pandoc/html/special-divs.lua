--- HTML equivalent of `special-divs.lua`. Instead of wrapping content in
--- LaTeX/Copernicus macros, we prepend an (unnumbered) heading so the
--- section reads sensibly in the HTML output. The original class is kept
--- on the div so it can be styled through CSS, and so that `numbering.lua`
--- can still recognise the `appendix` div further down the filter chain.

function Div(el)
    local cls = {}
    for _, c in ipairs(el.classes) do
        cls[c] = true
    end

    local function with_heading(level, text)
        local heading = pandoc.Header(level, { pandoc.Str(text) }, pandoc.Attr("", { "unnumbered" }))
        table.insert(el.content, 1, heading)
        return el
    end

    if cls["abstract"] then
        return with_heading(2, "Abstract")
    end
    if cls["code-availability"] then
        return with_heading(2, "Code and Data Availability")
    end
    if cls["appendix"] then
        return with_heading(1, "Appendix")
    end
    if cls["author-contribution"] then
        return with_heading(2, "Author Contributions")
    end
    if cls["competing-interests"] then
        return with_heading(2, "Competing Interests")
    end
    if cls["acknowledgements"] then
        return with_heading(2, "Acknowledgements")
    end
    if cls["disclaimer"] then
        return with_heading(2, "Disclaimer")
    end
end
