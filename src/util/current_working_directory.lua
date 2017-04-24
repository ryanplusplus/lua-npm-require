return function()
  local f = io.popen('pwd')
  local current_working_directory = f:read('*l')
  f:close()
  return current_working_directory .. '/'
end
