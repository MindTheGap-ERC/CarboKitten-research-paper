local function make_set(lst)
    local result = {}
    for _, v in ipairs(lst) do
        result[v] = true
    end
    return result
end

function Div(el)
    local cls = make_set(el.classes)
    if cls["wide-table"] then
        table.insert(el.content[1].classes, "wide-table")
    end
    return el
end
