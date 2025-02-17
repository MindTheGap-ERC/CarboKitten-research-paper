--- Removes divs with `hide` class from the document
function Div(elem)
  if elem.classes[1] == "hide" then
    return {}
  end  
end

