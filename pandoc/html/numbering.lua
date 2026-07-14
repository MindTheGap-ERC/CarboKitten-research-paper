--- HTML equivalent of `fignos.lua` + `figref.lua` + `eqnos.lua` +
--- `wide_figures.lua` + `plain_tables.lua`. Where the LaTeX filters lean
--- on LaTeX's own `\ref`/`\label`/counter machinery, here we have to do
--- the figure/table/equation/section numbering and cross-referencing by
--- hand, and copy (and where needed convert) the referenced figures into
--- the site's `fig/` directory.
---
--- Assumes `fignos.lua` and `wide_tables.lua` have already run, so that
--- Figure blocks carry their final `fig:...` identifier and caption, and
--- wide tables already carry the `wide-table` class.

local site_dir = "build/site"
local fig_dir = site_dir .. "/fig"

local fig_count = 0
local fig_ids = {}
local tbl_count = 0
local tbl_ids = {}
local eq_count = 0
local eq_ids = {}
local sec_ids = {}

local sec_counters = { 0, 0, 0, 0, 0, 0 }
local appendix_counters = { 0, 0, 0, 0, 0, 0 }

local mkdir_done = false
local function ensure_fig_dir()
    if not mkdir_done then
        os.execute("mkdir -p \"" .. fig_dir .. "\"")
        mkdir_done = true
    end
end

--- Copies (and converts PDF to SVG) a figure source into build/site/fig,
--- returning the path relative to the generated HTML file.
local function copy_or_convert_image(src)
    local full_src = pandoc.path.join { "md", src }
    local base = pandoc.path.filename(src)
    local name, ext = pandoc.path.split_extension(base)
    ensure_fig_dir()
    if ext == ".pdf" then
        local target_rel = pandoc.path.join { "fig", name .. ".svg" }
        local target = pandoc.path.join { site_dir, target_rel }
        local ok = os.execute("pdftocairo -svg \"" .. full_src .. "\" \"" .. target .. "\"")
        if not ok then
            io.stderr:write("WARNING: could not convert " .. full_src ..
                " to SVG (is poppler-utils/pdftocairo installed?)\n")
        end
        return target_rel
    else
        local target_rel = pandoc.path.join { "fig", base }
        local target = pandoc.path.join { site_dir, target_rel }
        os.execute("cp \"" .. full_src .. "\" \"" .. target .. "\"")
        return target_rel
    end
end

--- Strips a trailing `{#tag}` from the last inline of a caption's first
--- block, returning the tag (or nil).
local function extract_tag(caption_long, pattern)
    if not caption_long or not caption_long[1] or not caption_long[1].content then
        return nil
    end
    local content = caption_long[1].content
    local last = content[#content]
    if not last or not last.text then
        return nil
    end
    local tag = string.match(last.text, pattern)
    if tag then
        table.remove(content, #content)
        -- drop a trailing space left behind, if any
        local new_last = content[#content]
        if new_last and new_last.t == "Space" then
            table.remove(content, #content)
        end
    end
    return tag
end

local function flatten_inlines(blocks)
    local out = pandoc.List()
    for _, blk in ipairs(blocks or {}) do
        if blk.content then
            for _, inl in ipairs(blk.content) do
                out:insert(inl)
            end
        end
    end
    return out
end

local function process_figure(el)
    local plain = el.content[1]
    local img = plain and plain.content and plain.content[1]
    if not img or img.t ~= "Image" then
        return el
    end

    fig_count = fig_count + 1
    if el.identifier ~= "" then
        fig_ids[el.identifier] = fig_count
    end

    local target_rel = copy_or_convert_image(img.src)
    local is_wide = img.classes:includes("wide")

    local new_img = pandoc.Image(img.caption, target_rel, img.title, pandoc.Attr("", {}, {}))

    local caption_inlines = flatten_inlines(el.caption.long)
    local number_span = pandoc.Span({ pandoc.Str("Figure " .. fig_count .. ": ") },
        pandoc.Attr("", { "fig-number" }))
    local caption_content = pandoc.List { number_span }
    caption_content:extend(caption_inlines)

    local classes = { "figure" }
    if is_wide then
        table.insert(classes, "wide")
    end

    return pandoc.Div({
        pandoc.Plain { new_img },
        pandoc.Para(caption_content),
    }, pandoc.Attr(el.identifier, classes))
end

local function process_table(el)
    local tag = extract_tag(el.caption.long, "{#(tbl:[%w%-_]+)}")
    if tag then
        el.identifier = tag
    end
    tbl_count = tbl_count + 1
    if el.identifier ~= "" then
        tbl_ids[el.identifier] = tbl_count
    end

    local number_span = pandoc.Span({ pandoc.Str("Table " .. tbl_count .. ": ") },
        pandoc.Attr("", { "tbl-number" }))
    local caption_inlines = flatten_inlines(el.caption.long)
    local caption_content = pandoc.List { number_span }
    caption_content:extend(caption_inlines)
    el.caption.long = { pandoc.Plain(caption_content) }
    return el
end

local function letter(n)
    return string.char(64 + n)
end

local function number_header(el, in_appendix)
    if el.classes:includes("unnumbered") then
        return el
    end

    local counters = in_appendix and appendix_counters or sec_counters
    local lvl = math.min(el.level, #counters)
    counters[lvl] = counters[lvl] + 1
    for i = lvl + 1, #counters do
        counters[i] = 0
    end

    local parts = {}
    for i = 1, lvl do
        if counters[i] > 0 then
            if in_appendix and i == 1 then
                table.insert(parts, letter(counters[i]))
            else
                table.insert(parts, tostring(counters[i]))
            end
        end
    end
    local label = table.concat(parts, ".")
    if el.identifier ~= "" then
        sec_ids[el.identifier] = label
    end

    table.insert(el.content, 1, pandoc.Space())
    table.insert(el.content, 1, pandoc.Span({ pandoc.Str(label) }, pandoc.Attr("", { "secnum" })))
    return el
end

--- Detects a display equation immediately followed by `{#eq:...}`,
--- i.e. the pattern produced by `$$...$$${#eq:tag}` in the markdown
--- source, and numbers it.
local function process_para(el)
    local content = el.content
    for i, inl in ipairs(content) do
        if inl.t == "Math" and inl.mathtype == "DisplayMath" then
            local nxt = content[i + 1]
            if nxt and nxt.t == "Str" then
                local tag = string.match(nxt.text, "^{#(eq:[%w%-_]+)}$")
                if tag then
                    eq_count = eq_count + 1
                    eq_ids[tag] = eq_count
                    return pandoc.Div({
                        pandoc.Plain {
                            pandoc.Span({ inl }, pandoc.Attr("", { "eq-body" })),
                            pandoc.Span({ pandoc.Str("(" .. eq_count .. ")") }, pandoc.Attr("", { "eq-number" })),
                        },
                    }, pandoc.Attr(tag, { "equation" }))
                end
            end
        end
    end
    return el
end

local process_blocks

local function process_div(el, in_appendix)
    local cls = {}
    for _, c in ipairs(el.classes) do
        cls[c] = true
    end
    local inner_appendix = in_appendix or cls["appendix"]
    local content = process_blocks(el.content, inner_appendix)
    if cls["wide-table"] then
        -- the table itself already carries the wide-table class (set by
        -- wide_tables.lua), so the wrapping div is redundant for HTML
        return content
    end
    el.content = content
    return el
end

process_blocks = function(blocks, in_appendix)
    local out = pandoc.List()
    for _, el in ipairs(blocks) do
        if el.t == "Div" then
            local result = process_div(el, in_appendix)
            if result.t then
                out:insert(result)
            else
                out:extend(result)
            end
        elseif el.t == "Header" then
            out:insert(number_header(el, in_appendix))
        elseif el.t == "Figure" then
            out:insert(process_figure(el))
        elseif el.t == "Table" then
            out:insert(process_table(el))
        elseif el.t == "Para" then
            out:insert(process_para(el))
        else
            out:insert(el)
        end
    end
    return out
end

local function label_for(id)
    if fig_ids[id] then
        return tostring(fig_ids[id])
    end
    if tbl_ids[id] then
        return tostring(tbl_ids[id])
    end
    if eq_ids[id] then
        return tostring(eq_ids[id])
    end
    if sec_ids[id] then
        return sec_ids[id]
    end
    return nil
end

local function resolve_cite(el)
    if #el.citations ~= 1 then
        return nil
    end
    local id = el.citations[1].id
    local label = label_for(id)
    if not label then
        return nil
    end

    local plain_ref = pandoc.write(pandoc.Pandoc { table.unpack(el.content) }, "plain")
    local pre = string.match(plain_ref, "%[([^@]*)@.*%]")
    local text
    if pre then
        text = (pre:gsub("%s+$", "")) .. " " .. label
    else
        text = label
    end
    return pandoc.Link({ pandoc.Str(text) }, "#" .. id)
end

function Pandoc(doc)
    doc.blocks = process_blocks(doc.blocks, false)
    return doc:walk { Cite = resolve_cite }
end
