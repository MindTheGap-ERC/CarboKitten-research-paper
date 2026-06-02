local figure_num = 1

function Figure(el)
    local source = pandoc.path.join{"md", el.content[1].content[1].src}
    local _, ext = pandoc.path.split_extension(source)
    local target_name = "Fig" .. figure_num .. ext
    local target = pandoc.path.join{"build", target_name}
    print("Copying " .. source .. " to " .. target)
    os.execute("cp \"" .. source .. "\" \"" .. target .."\"")
    el.content[1].content[1].src = target_name
    figure_num = figure_num + 1
    return el
end
