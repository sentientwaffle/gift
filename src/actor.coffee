crypto = require 'crypto'

module.exports = class Actor
  constructor: (@name, @email) ->
    if @email
      @hash = crypto.createHash("md5").update(@email, "ascii").digest("hex")
  
  # Public: Get a string representation of the Actor.
  toString: ->
    "#{@name} <#{@email}>"
  
  # Public: Parse an Actor from a "bla <bla@example.com>" string.
  # 
  # Returns Actor.
  @from_string: (str) ->
    if /<.+>/.test str
      [m, name, email] = /(.*) <(.+?)>/.exec str
      return new Actor(name, email)
    else
      return new Actor(str, null)
