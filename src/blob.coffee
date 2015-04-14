path = require 'path'

module.exports = class Blob
  constructor: (@repo, attrs) ->
    {@id, @name, @mode} = attrs

  # Public: Get the blob contents.
  #
  # callback - Receives `(err, data)`.
  #
  # Warning, this only returns files less than 200k, the standard buffer size for
  # node's exec(). If you need to get bigger files, you should use dataStream() to
  # get a stream for the file's data
  #
  data: (callback) ->
    @repo.git "cat-file", {p: true}, @id
    , (err, stdout, stderr) ->
      return callback err, stdout
    , 'binary'

  # Public: Get the blob contents as a stream
  #
  # returns - [dataStream, errstream]
  #
  # Usage:
  #   [blobstream, _] = blob.dataStream()
  #   blobstream.pipe(res)
  #
  dataStream: () ->
    streams = @repo.git.streamCmd "cat-file", {p: true}, [@id]
    return streams

  toString: ->
    "#<Blob '#{@id}'>"
