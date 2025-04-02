function Cite(elem)
  if next(elem.citations) == nil then
    return
  end
  local c = elem.citations[1]
  local id = string.match(c.id, "eq:.*")
  if id == nil then
    return
  end
  return pandoc.RawInline("tex", "\\ref{" .. id .. "}")
end

function Para(elem)
  local prev = false
  for i, el in pairs(elem.content) do
    if prev and (prev.t == "Math") and (el.t == "Str") then
      local tag = string.match(el.text, "{#(eq:.*)}")
      if tag ~= nil then
	return pandoc.RawBlock("tex", "\\begin{equation}" ..
	  prev.text ..
	  "\\label{" .. tag .. "}\n" ..
	  "\\end{equation}")
      end
    else
      -- print("setting prev ", el, "\n")
      prev = el
    end
  end
end
