return function(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    f:close()
    return true
  else
    return false
  end
end
