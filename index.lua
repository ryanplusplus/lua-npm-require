local filename = debug.getinfo(1, 'S').source:sub(2)
local path = filename:match('(.*/)') or './'

local previous_path = package.path
package.path = path .. 'src/?.lua;' .. package.path

local require = require 'require'

package.path = previous_path

return require
