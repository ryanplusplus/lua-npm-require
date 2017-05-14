describe('require', function()
  local r = require
  _G.require = require 'require'

  it('should load modules from node_modules in the current directory', function()
    assert.are.equal('abc', require 'a')
  end)

  it('should load modules from node_modules in a parent directory', function()
    assert.are.equal('abc', require './node_modules/a/node_modules/b/node_modules/c/depends_on_a')
  end)

  it('should load modules from node_modules in a parent directory', function()
    assert.are.equal('abc', require './node_modules/a/node_modules/b/node_modules/c/depends_on_a')
  end)
end)
