local current_working_directory = require 'util.current_working_directory'
local requester_path = require 'util.requester_path'
local file_exists = require 'util.file_exists'
local require = require

package.path = package.path .. '?.lua;'

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
    if file_exists(current_path .. module_name .. '.lua') then
      return require(normalize(current_path .. module_name))
    end
  else
    for _, directory in ipairs(get_directories(current_path)) do
      if file_exists(directory .. 'node_modules/' .. module_name .. '/index.lua') then
        return require(directory .. 'node_modules/' .. module_name .. '/index')
      end
    end

    local found, module = pcall(function()
      return require(module_name)
    end)

    if found then return module end
  end
end

return function(module_name)
  local module = find_module(module_name)
  assert(module, "Could not find module '" .. module_name .. "'")
  return module
end
