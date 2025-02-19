--- Find figures and set subsequent paragraph as caption.
function Pandoc(doc, meta)
  local blocks =  {}
  local prev = false
  for i, el in pairs(doc.blocks) do
    if prev and (prev.t == "Figure") and (el.content[1] == pandoc.Str("Figure:")) then
      -- print("ammending Figure ", prev, "\n")
      table.remove(el.content,  1)
      local last = el.content[#el.content]
      local tag = string.match(last.text, "{#(.*)}")
      table.remove(el.content, #el.content)
      -- print("found tag ", tag, "\n")
      prev.caption = {long=el}
      prev.identifier = tag
    else
      -- print("setting prev ", el, "\n")
      prev = el
      table.insert(blocks, el)
    end
  end
  return pandoc.Pandoc(blocks, doc.meta)
end
