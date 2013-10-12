module.exports = C = (repo, callback) ->
  repo.git "config", {list: true}, (err, stdout, stderr) ->
    config = new Config repo
    config.parse stdout
    callback err, config

C.Config = class Config
  constructor: (@repo) ->

  # Internal: Parse the config from stdout of a `git config` command
  parse: (text)->
    @items = {}
    for line in text.split("\n")
      if line.length == 0
        continue
      [key, value] = line.split('=')
      @items[key] = value
