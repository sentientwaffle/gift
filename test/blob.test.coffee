should   = require 'should'
fixtures = require './fixtures'
git      = require '../src'
Blob     = require '../src/blob'

describe "Blob", ->
  describe "constructor", ->
    repo = fixtures.branched
    blob = new Blob repo, {name: "X", mode: "Y", id: "abc"}
    it "assigns @name", ->
      blob.name.should.eql "X"
    it "assigns @mode", ->
      blob.mode.should.eql "Y"
    it "assigns @id", ->
      blob.id.should.eql "abc"


  describe "#data", ->
    describe "of a file off the root", ->
      repo = git "#{__dirname}/fixtures/branched"
      data = null
      before (done) ->
        repo.tree().blobs (err, blobs) ->
          blobs[0].data (err, _data) ->
            data = _data
            done err

      it "is a string", ->
        data.should.be.type "string"
        data.should.containEql "Bla"

    describe "of a file in a subdir", ->
      repo = git "#{__dirname}/fixtures/branched"
      data = null
      before (done) ->
        repo.tree().trees (err, trees) ->
          trees[0].blobs (err, blobs) ->
            blobs[0].data (err, _data) ->
              data = _data
              done err

      it "is a string", ->
        data.should.be.type "string"
        data.should.containEql "!!!"

  describe "#dataStream", ->
    describe "of a file off the root", ->
      repo = git "#{__dirname}/fixtures/branched"
      data = ""
      before (done) ->
        repo.tree().blobs (err, blobs) ->
          [dataStream, _] = blobs[0].dataStream()
          dataStream.on 'data', (buf) ->
            data += buf.toString()
          .on 'end', ->
            done()

      it "is a string", ->
        data.should.be.type "string"
        data.should.containEql "Bla"

    describe "of a file in a subdir", ->
      repo = git "#{__dirname}/fixtures/branched"
      data = ""
      before (done) ->
        repo.tree().trees (err, trees) ->
          trees[0].blobs (err, blobs) ->
            [dataStream, _] = blobs[0].dataStream()
            dataStream.on 'data', (buf) ->
              data += buf.toString()
            .on 'end', ->
              done()

      it "is a string", ->
        data.should.be.type "string"
        data.should.containEql "!!!"


