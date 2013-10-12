should   = require 'should'
Config   = require '../src/config'

GIT_CONFIG = """
user.name=John Doe
user.email=john.doe@git-scm.com
core.editor=pico
"""

GIT_CONFIG_DUPLICATE_KEYS = """
user.name=John Doe
user.email=john.doe@git-scm.com
core.editor=pico
user.email=john.doe@github.com
core.editor=emacs
"""

describe "Config", ->
  describe "()", ->
    describe "when there are no overlapping keys", ->
      config = new Config.Config 'mock repo'
      config.parse GIT_CONFIG

      it "read the keys and values", ->
        config.items['user.name'].should.equal 'John Doe'
        config.items['user.email'].should.equal 'john.doe@git-scm.com'
        config.items['core.editor'].should.equal 'pico'

    describe "with overlapping keys", ->
      config = new Config.Config 'mock repo'
      config.parse GIT_CONFIG_DUPLICATE_KEYS

      it "read the keys and values", ->
        config.items['user.name'].should.equal 'John Doe'
        config.items['user.email'].should.equal 'john.doe@github.com'
        config.items['core.editor'].should.equal 'emacs'
