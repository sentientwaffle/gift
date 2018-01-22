should   = require 'should'
fixtures = require './fixtures'
git      = require '../src'
Tag      = require '../src/tag'

describe "Tag", ->
  describe ".find_all", ->
    repo = fixtures.tagged
    tags = null
    before (done) ->
      Tag.find_all repo, (err, _tags) ->
        tags = _tags
        done err

    it "is an Array of Tags", ->
      tags.should.be.an.instanceof Array
      tags[0].should.be.an.instanceof Tag

    pref = "the tag"
    it "#{pref} has the correct name", ->
      tags[0].name.should.eql "tag-1"

    it "#{pref} has the correct commit", ->
      tags[0].commit.id.should.eql "32bbb351de16c3e404b3b7c77601c3d124e1e1a1"


  describe "#message", ->
    repo    = fixtures.tagged
    tags    = null
    message = null
    before (done) ->
      repo.tags (err, _tags) ->
        tags = _tags
        done err if err
        tags[0].message (err, _message) ->
          message = _message
          done err

    it "is the correct message", ->
      message.should.containEql "the first tag"

    it "has the correct commit", ->
      tags[0].commit.message.should.eql "commit 5"

