local current_working_directory = require 'current_working_directory'
local requester_path = require 'requester_path'
local file_exists = require 'file_exists'

local function get_directories(path)
  local directories = {}
  while path and path ~= '' do
    table.insert(directories, path)
    path = path:match('^(.*/)[^%/]+')
  end
  return directories
end

local function is_relative(path)
  return path:match('^%.')
end

local function normalize(path)
  return path:gsub('/%./', '/'):gsub('/[^/]+/../', '/')
end

local function find_module(module_name)
  local requester_path = requester_path(3)
  local current_path = is_relative(requester_path) and
    current_working_directory() .. requester_path or
    requester_path

  current_path = normalize(current_path)

  if is_relative(module_name) then
    local file = normalize(current_path .. module_name .. '.lua')
    if file_exists(file) then return file end
  else
    for _, directory in ipairs(get_directories(current_path)) do
      local file = directory .. 'node_modules/' .. module_name .. '/index.lua'
      if file_exists(file) then return file end
    end
  end
end

local m = {
  cache = {}
}

return setmetatable(m, {
  __call = function(_, module_name)
    local module = find_module(module_name)
    assert(module, "Could not find module '" .. module_name .. "'")

    if not m.cache[module] then
      local loaded = loadfile(module)()
      m.cache[module] = loaded == nil or loaded
    end

    return m.cache[module]
  end
})
