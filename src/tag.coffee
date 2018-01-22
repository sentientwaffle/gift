_      = require 'underscore'
Commit = require './commit'
Actor  = require './actor'
{Ref}  = require './ref'

module.exports = class Tag extends Ref
  @find_all: (repo, callback) ->
    Ref.find_all repo, "tag", Tag, callback


  # Public: Get the tag message.
  #
  # Returns String.
  message: (callback) ->
    @lazy (err, data) ->
      return callback err if err
      return callback null, data.message

  # Public: Get the tag author.
  #
  # Returns Actor.
  tagger: (callback) ->
    @lazy (err, data) ->
      return callback err if err
      return callback null, data.tagger

  # Public: Get the date that the tag was created.
  #
  # Returns Date.
  tag_date: (callback) ->
    @lazy (err, data) ->
      return callback err if err
      return callback null, data.tag_date

  # Internal: Load the tag data.
  lazy: (callback) ->
    return callback null, @_lazy_data if @_lazy_data
    @repo.git "cat-file", {}, ["tag", @name]
    , (err, stdout, stderr) =>
      return callback err if err
      lines = stdout.split "\n"
      data  = {}

      lines.shift() # object 4ae1cc5e6c7bb85b14ecdf221030c71d0654a42e
      lines.shift() # type commit
      lines.shift() # tag v0.0.2

      # bob <bob@example.com>
      author_line       = lines.shift()
      [m, author, epoch] = /^.+? (.*) (\d+) .*$/.exec author_line

      data.tagger   = Actor.from_string author
      data.tag_date = new Date epoch

      lines.shift()
      message = []
      while line = lines.shift()
        message.push line
      data.message = message.join("\n")

      return callback null, (@_lazy_data = data)

