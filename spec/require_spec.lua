describe('require', function()
  local proxyquire = require 'proxyquire'
  local mach = require 'mach'

  local current_working_directory
  local requester_path
  local files
  local fake = mach.mock_table({
    loadfile = load''
  }, 'fake')

  local require = proxyquire('require', {
    current_working_directory = function()
      return current_working_directory
    end,
    requester_path = function()
      return requester_path
    end,
    file_exists = function(file)
      return files[file]
    end
  })

  local function given_that_the_current_working_directory_is(dir)
    current_working_directory = dir
  end

  local function given_that_the_requester_path_is(path)
    requester_path = path
  end

  local function given_that_the_filesystem_contains_files(_files)
    for _, file in ipairs(_files) do
      files[file] = true
    end
  end

  before_each(function()
    _G._loadfile = _G.loadfile
    _G.loadfile = fake.loadfile
    files = {}
    require.cache = {}
  end)

  after_each(function()
    _G.loadfile = _G._loadfile
  end)

  it('should load a relative module that exists when the requester path is .', function()
    given_that_the_current_working_directory_is('/hello/goodbye/')
    given_that_the_requester_path_is('./')
    given_that_the_filesystem_contains_files({ '/hello/goodbye/world.lua' })

    local module = load([[
      return 3
    ]])

    fake.loadfile:should_be_called_with('/hello/goodbye/world.lua'):and_will_return(module):
      when(function()
        local module = require './world'
        assert.are.equal(3, module)
      end)
  end)

  it('should load a relative module that exists when the requester path is relative', function()
    given_that_the_current_working_directory_is('/hello/')
    given_that_the_requester_path_is('./goodbye/')
    given_that_the_filesystem_contains_files({ '/hello/goodbye/world.lua' })

    local module = load([[
      return 5
    ]])

    fake.loadfile:should_be_called_with('/hello/goodbye/world.lua'):and_will_return(module):
      when(function()
        local module = require './world'
        assert.are.equal(5, module)
      end)
  end)

  it('should load a relative module that exists when the requester path is absolute (was loaded with require)', function()
    given_that_the_current_working_directory_is('/does/not/matter/')
    given_that_the_requester_path_is('/hello/')
    given_that_the_filesystem_contains_files({ '/hello/world.lua' })

    local module = load([[
      return 7
    ]])

    fake.loadfile:should_be_called_with('/hello/world.lua'):and_will_return(module):
      when(function()
        local module = require './world'
        assert.are.equal(7, module)
      end)
  end)

  it('should load a relative module that uses .. to traverse through a parent directory', function()
    given_that_the_current_working_directory_is('/does/not/matter/')
    given_that_the_requester_path_is('/foo/hello/')
    given_that_the_filesystem_contains_files({ '/foo/src/world.lua' })

    local module = load([[
      return 'lua'
    ]])

    fake.loadfile:should_be_called_with('/foo/src/world.lua'):and_will_return(module):
      when(function()
        local module = require '../src/world'
        assert.are.equal('lua', module)
      end)
  end)

  it('should load a module from ./node_modules when the requester path is .', function()
    given_that_the_current_working_directory_is('/foo/bar/')
    given_that_the_requester_path_is('./')
    given_that_the_filesystem_contains_files({ '/foo/bar/node_modules/baz/index.lua' })

    local module = load([[
      return 9
    ]])

    fake.loadfile:should_be_called_with('/foo/bar/node_modules/baz/index.lua'):and_will_return(module):
      when(function()
        local module = require 'baz'
        assert.are.equal(9, module)
      end)
  end)

  it('should load a module from ./node_modules when the requester path is relative', function()
    given_that_the_current_working_directory_is('/foo/')
    given_that_the_requester_path_is('./bar/')
    given_that_the_filesystem_contains_files({ '/foo/bar/node_modules/baz/index.lua' })

    local module = load([[
      return 11
    ]])

    fake.loadfile:should_be_called_with('/foo/bar/node_modules/baz/index.lua'):and_will_return(module):
      when(function()
        local module = require 'baz'
        assert.are.equal(11, module)
      end)
  end)

  it('should load a module from ./node_modules when the requester path is absolute ((was loaded with require)', function()
    given_that_the_current_working_directory_is('/does/not/matter')
    given_that_the_requester_path_is('/foo/bar/')
    given_that_the_filesystem_contains_files({ '/foo/bar/node_modules/baz/index.lua' })

    local module = load([[
      return 13
    ]])

    fake.loadfile:should_be_called_with('/foo/bar/node_modules/baz/index.lua'):and_will_return(module):
      when(function()
        local module = require 'baz'
        assert.are.equal(13, module)
      end)
  end)

  it('should load a module from ./node_modules even when the module exists in ../node_modules', function()
    given_that_the_current_working_directory_is('/does/not/matter')
    given_that_the_requester_path_is('/foo/bar/')
    given_that_the_filesystem_contains_files({
      '/foo/node_modules/baz/index.lua',
      '/foo/bar/node_modules/baz/index.lua'
    })

    local module = load([[
      return 15
    ]])

    fake.loadfile:should_be_called_with('/foo/bar/node_modules/baz/index.lua'):and_will_return(module):
      when(function()
        local module = require 'baz'
        assert.are.equal(15, module)
      end)
  end)


  it('should load a module from ../node_modules when the module does not exist in ./node_modules', function()
    given_that_the_current_working_directory_is('/does/not/matter')
    given_that_the_requester_path_is('/foo/bar/')
    given_that_the_filesystem_contains_files({ '/foo/node_modules/baz/index.lua' })

    local module = load([[
      return 17
    ]])

    fake.loadfile:should_be_called_with('/foo/node_modules/baz/index.lua'):and_will_return(module):
      when(function()
        local module = require 'baz'
        assert.are.equal(17, module)
      end)
  end)

  it('should load a module from /node_modules if the module does not exist in any parent of the requester', function()
    given_that_the_current_working_directory_is('/does/not/matter')
    given_that_the_requester_path_is('/foo/bar/')
    given_that_the_filesystem_contains_files({ '/node_modules/baz/index.lua' })

    local module = load([[
      return 19
    ]])

    fake.loadfile:should_be_called_with('/node_modules/baz/index.lua'):and_will_return(module):
      when(function()
        local module = require 'baz'
        assert.are.equal(19, module)
      end)
  end)

  it('should load a module as true when no value is returned', function()
    given_that_the_current_working_directory_is('/hello/goodbye/')
    given_that_the_requester_path_is('./')
    given_that_the_filesystem_contains_files({ '/hello/goodbye/world.lua' })

    local module = load('')

    fake.loadfile:should_be_called_with('/hello/goodbye/world.lua'):and_will_return(module):
      when(function()
        local module = require './world'
        assert.are.equal(true, module)
      end)
  end)

  it('should raise an error when a relative module cannot be found', function()
    given_that_the_current_working_directory_is('/hello/goodbye/')
    given_that_the_requester_path_is('./')
    given_that_the_filesystem_contains_files({})

    assert.has_error(function()
      require './world'
    end, "Could not find module './world'")
  end)

  it('should raise an error when a module cannot be found', function()
    given_that_the_current_working_directory_is('/does/not/matter')
    given_that_the_requester_path_is('/foo/bar/')
    given_that_the_filesystem_contains_files({})

    assert.has_error(function()
      require 'baz'
    end, "Could not find module 'baz'")
  end)
end)
