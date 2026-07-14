--- For HTML output, code blocks marked with the `hide` class are not
--- dropped (as they are for LaTeX/PDF output), but wrapped in a
--- collapsed `<details>` element instead, so readers can still open and
--- inspect the source. The `<summary>` text is taken from the `id` or
--- `file` attribute found in the first code block's YAML header.

local function escape_html(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function find_label(code_text)
    for line in code_text:gmatch("[^\r\n]+") do
        local id = line:match("^#|%s*id:%s*(.-)%s*$")
        if id then
            return id
        end
    end
    for line in code_text:gmatch("[^\r\n]+") do
        local file = line:match("^#|%s*file:%s*(.-)%s*$")
        if file then
            return (file:gsub('^"(.*)"$', "%1"))
        end
    end
    return nil
end

local function first_label(blocks)
    for _, b in ipairs(blocks) do
        if b.t == "CodeBlock" then
            local label = find_label(b.text)
            if label then
                return label
            end
        end
    end
    return nil
end

function Div(el)
    if el.classes[1] ~= "hide" then
        return
    end

    local label = first_label(el.content) or "code"
    local out = pandoc.List()
    out:insert(pandoc.RawBlock("html",
        "<details class=\"hide-code\"><summary><code>" .. escape_html(label) .. "</code></summary>"))
    for _, b in ipairs(el.content) do
        out:insert(b)
    end
    out:insert(pandoc.RawBlock("html", "</details>"))
    return out
end
