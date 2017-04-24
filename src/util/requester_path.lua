return function(level)
  local str = debug.getinfo(level + 1, 'S').source:sub(2)
  return str:match('(.*/)') or './'
end
